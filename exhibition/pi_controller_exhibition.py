#!/usr/bin/env python3
"""
Pi control node — exhibition build.
Reads Firebase commands -> drives actuators via GPIO.
Captures image + runs TFLite inference when gantry arrives at plant.
Unified pump_action: app sends {plant, state} -> Pi moves gantry then pumps.
Auto mode: scans all plants, captures+infers, pumps where soil is dry.
"""

import collections
import json
import subprocess
import threading
import time
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import RPi.GPIO as GPIO
import firebase_admin
from firebase_admin import credentials, db
from PIL import Image

try:
    from ai_edge_litert.interpreter import Interpreter
except ImportError:
    try:
        import tflite_runtime.interpreter as _tfl
        Interpreter = _tfl.Interpreter
    except ImportError:
        import tensorflow as tf
        Interpreter = tf.lite.Interpreter

# ── Constants ────────────────────────────────────────────────────────────────
FIREBASE_CRED        = "/home/akai/Final_Project/firebase-key.json"
FIREBASE_DB_URL      = "https://embedded-project-32dca-default-rtdb.firebaseio.com"

MODEL_PATH           = "/home/akai/Final_Project/model.tflite"
ENTROPY_CFG          = "/home/akai/Final_Project/entropy_threshold.json"
INPUT_SIZE           = 224
CLASS_NAMES          = ["Early_Blight", "Healthy", "Late_Blight"]
NUM_CLASSES          = len(CLASS_NAMES)
SMOOTHING_WINDOW     = 5

STEPS_PER_PLANT      = 3200
PLANTS_COUNT         = 2
STEP_DELAY_S         = 0.001

AUTO_SOIL_THRESHOLD  = 30
AUTO_PUMP_DURATION_S = 5
AUTO_SCAN_INTERVAL_S = 120
AUTO_SETTLE_S        = 3

POLL_INTERVAL_S      = 1.0

# ── GPIO pins (BCM) — matches smart_irrigation_pinout_reference.md ──────────
# Pump relay moved to ESP32 GPIO16 — Pi sends commands via Firebase
PIN_STEP    = 20   # A4988 STEP (Pin 38)
PIN_DIR     = 21   # A4988 DIR (Pin 40)
PIN_BUZZER  = 22   # Buzzer NPN base (Pin 15)
PIN_GREEN   = 5    # Green LED (Pin 29)
PIN_RED     = 6    # Red LED (Pin 31)
PIN_YELLOW  = 13   # Yellow LED (Pin 33)
PIN_BLUE    = 27   # Blue LED NPN base (Pin 13)

_ALL_OUTPUTS = [
    PIN_STEP, PIN_DIR,
    PIN_BUZZER, PIN_GREEN, PIN_RED, PIN_YELLOW, PIN_BLUE,
]

# ── Buzzer patterns ──────────────────────────────────────────────────────────
_BUZZ_BOOT       = [(100, 80), (100, 0)]
_BUZZ_PUMP_ON    = [(80, 0)]
_BUZZ_FAULT_CLR  = [(400, 0)]
_BUZZ_DRY_SOIL   = [(200, 300), (200, 300), (200, 0)]
_BUZZ_ESTOP_UNIT = [(60, 60)] * 10

# ── State ────────────────────────────────────────────────────────────────────
_estop         = False
_pump_on       = False
_gantry_pos    = 0

_stepper_lock  = threading.Lock()
_stepper_abort = threading.Event()

_buzz_lock     = threading.Lock()
_buzz_stop     = threading.Event()
_buzz_thread   = None
_estop_buzzing = False

_auto_scan_lock    = threading.Lock()
_auto_scan_thread  = None
_auto_next_scan    = 0.0

_prev_pump_ts  = 0
_prev_estop    = False
_prev_mode     = "AUTOMATIC"

# AI state
_interpreter   = None
_inp_detail    = None
_out_detail    = None
_entropy_threshold = 0.5
_camera_ok     = False
_vote_window   = collections.deque(maxlen=SMOOTHING_WINDOW)
_CAPTURE_PATH  = "/tmp/pi_capture.jpg"

# ── Logging ──────────────────────────────────────────────────────────────────
def log(msg: str):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)

# ── GPIO ─────────────────────────────────────────────────────────────────────
def gpio_init():
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    for pin in _ALL_OUTPUTS:
        GPIO.setup(pin, GPIO.OUT, initial=GPIO.LOW)
    log("GPIO ready")

def gpio_cleanup():
    for led in (PIN_GREEN, PIN_RED, PIN_YELLOW, PIN_BLUE):
        GPIO.output(led, GPIO.LOW)
    GPIO.output(PIN_BUZZER, GPIO.LOW)
    GPIO.cleanup()

# ── Buzzer ───────────────────────────────────────────────────────────────────
def _run_pattern(pattern, stop_event):
    for on_ms, off_ms in pattern:
        if stop_event.is_set():
            break
        GPIO.output(PIN_BUZZER, GPIO.HIGH)
        time.sleep(on_ms / 1000)
        GPIO.output(PIN_BUZZER, GPIO.LOW)
        if off_ms > 0 and not stop_event.is_set():
            time.sleep(off_ms / 1000)
    GPIO.output(PIN_BUZZER, GPIO.LOW)

def _buzz_once(pattern):
    global _buzz_thread, _buzz_stop
    with _buzz_lock:
        if _estop_buzzing:
            return
        _buzz_stop.set()
        if _buzz_thread and _buzz_thread.is_alive():
            _buzz_thread.join(timeout=0.5)
        _buzz_stop = threading.Event()
        stop = _buzz_stop
    _buzz_thread = threading.Thread(
        target=_run_pattern, args=(pattern, stop), daemon=True
    )
    _buzz_thread.start()

def _buzz_estop_loop():
    while not _buzz_stop.is_set():
        _run_pattern(_BUZZ_ESTOP_UNIT, _buzz_stop)

def _start_estop_buzz():
    global _buzz_thread, _buzz_stop, _estop_buzzing
    with _buzz_lock:
        _buzz_stop.set()
        if _buzz_thread and _buzz_thread.is_alive():
            _buzz_thread.join(timeout=0.5)
        _buzz_stop = threading.Event()
        _estop_buzzing = True
    _buzz_thread = threading.Thread(target=_buzz_estop_loop, daemon=True)
    _buzz_thread.start()

def _stop_estop_buzz():
    global _estop_buzzing
    with _buzz_lock:
        _buzz_stop.set()
        _estop_buzzing = False
    GPIO.output(PIN_BUZZER, GPIO.LOW)

# ── LEDs ─────────────────────────────────────────────────────────────────────
def _update_leds(mode="AUTOMATIC"):
    GPIO.output(PIN_GREEN,  GPIO.LOW  if _estop else GPIO.HIGH)
    GPIO.output(PIN_RED,    GPIO.HIGH if _estop else GPIO.LOW)
    GPIO.output(PIN_YELLOW, GPIO.HIGH if mode == "AUTOMATIC" else GPIO.LOW)
    GPIO.output(PIN_BLUE,   GPIO.HIGH if _pump_on else GPIO.LOW)

# ── Pump ─────────────────────────────────────────────────────────────────────
def set_pump(on: bool, silent: bool = False):
    global _pump_on
    if _pump_on == on:
        return
    _pump_on = on
    GPIO.output(PIN_BLUE, GPIO.HIGH if on else GPIO.LOW)
    try:
        db.reference("commands").update({"pump_relay": on})
        db.reference("status").update({"pump": "ON" if on else "OFF"})
    except Exception:
        pass
    log(f"Pump {'ON' if on else 'OFF'}")
    if on and not silent:
        _buzz_once(_BUZZ_PUMP_ON)

# ── Stepper ──────────────────────────────────────────────────────────────────
def _do_move(target_steps: int):
    global _gantry_pos
    with _stepper_lock:
        _stepper_abort.clear()
        delta = target_steps - _gantry_pos
        if delta == 0:
            return

        GPIO.output(PIN_DIR, GPIO.HIGH if delta > 0 else GPIO.LOW)
        steps = abs(delta)
        sign  = 1 if delta > 0 else -1
        log(f"Stepper: {delta:+d} steps -> target {target_steps}")

        for _ in range(steps):
            if _stepper_abort.is_set() or _estop:
                log("Stepper: aborted mid-move")
                break
            GPIO.output(PIN_STEP, GPIO.HIGH)
            time.sleep(STEP_DELAY_S)
            GPIO.output(PIN_STEP, GPIO.LOW)
            time.sleep(STEP_DELAY_S)
            _gantry_pos += sign
        plant = round(_gantry_pos / STEPS_PER_PLANT) if STEPS_PER_PLANT else 0
        try:
            db.reference("status").update({"gantry_plant": plant})
        except Exception:
            pass
        log(f"Stepper: at step {_gantry_pos} (plant {plant})")

def move_to_plant_blocking(index: int):
    index  = max(0, min(index, PLANTS_COUNT - 1))
    target = index * STEPS_PER_PLANT
    _do_move(target)

def move_to_plant(index: int):
    index  = max(0, min(index, PLANTS_COUNT - 1))
    target = index * STEPS_PER_PLANT
    threading.Thread(target=_do_move, args=(target,), daemon=True).start()

# ── AI Inference ─────────────────────────────────────────────────────────────
def init_ai():
    global _interpreter, _inp_detail, _out_detail, _entropy_threshold, _camera_ok

    try:
        _interpreter = Interpreter(model_path=MODEL_PATH)
        _interpreter.allocate_tensors()
        _inp_detail = _interpreter.get_input_details()[0]
        _out_detail = _interpreter.get_output_details()[0]
        log(f"Model loaded: {MODEL_PATH}")
    except Exception as e:
        log(f"Model load FAILED: {e} — running without AI")
        return

    cfg_path = Path(ENTROPY_CFG)
    if cfg_path.exists():
        with open(cfg_path) as f:
            _entropy_threshold = json.load(f)["entropy_threshold"]
        log(f"Entropy threshold: {_entropy_threshold:.4f}")

    try:
        r = subprocess.run(
            ["fswebcam", "-r", "1920x1080", "--no-banner", _CAPTURE_PATH],
            capture_output=True, timeout=10,
        )
        if r.returncode == 0 and Path(_CAPTURE_PATH).exists():
            _camera_ok = True
            log("Camera ready (fswebcam)")
        else:
            raise RuntimeError(r.stderr.decode(errors="ignore"))
    except Exception as e:
        log(f"Camera init FAILED: {e} — running without AI")

def capture_and_infer():
    """Capture image, run inference, push result to Firebase. Returns predicted class."""
    if not _camera_ok or _interpreter is None:
        return None

    try:
        r = subprocess.run(
            ["fswebcam", "-r", "1920x1080", "--no-banner", _CAPTURE_PATH],
            capture_output=True, timeout=10,
        )
        if r.returncode != 0:
            log("Capture failed: fswebcam error")
            return None
        image = Image.open(_CAPTURE_PATH).convert("RGB")
    except Exception as e:
        log(f"Capture failed: {e}")
        return None

    img = image.resize((INPUT_SIZE, INPUT_SIZE))
    arr = np.array(img, dtype=np.float32)[np.newaxis]

    if _inp_detail["dtype"] == np.int8:
        s, z = _inp_detail["quantization"]
        arr = np.clip(np.round(arr / s + z), -128, 127).astype(np.int8)
    elif _inp_detail["dtype"] == np.uint8:
        s, z = _inp_detail["quantization"]
        arr = np.clip(np.round(arr / s + z), 0, 255).astype(np.uint8)

    t0 = time.monotonic()
    _interpreter.set_tensor(_inp_detail["index"], arr)
    _interpreter.invoke()
    raw = _interpreter.get_tensor(_out_detail["index"]).astype(np.float32)
    inference_ms = (time.monotonic() - t0) * 1000

    if _out_detail["dtype"] in (np.int8, np.uint8):
        s, z = _out_detail["quantization"]
        raw = (raw - z) * s

    logits = raw[0]
    exp_l = np.exp(logits - logits.max())
    probs = exp_l / exp_l.sum()

    idx = int(np.argmax(probs))
    conf = float(probs[idx])
    p = np.clip(probs, 1e-9, 1.0)
    entropy = float(-np.sum(p * np.log(p)) / np.log(NUM_CLASSES))

    raw_class = CLASS_NAMES[idx]

    if entropy > _entropy_threshold:
        final_class = "Unknown"
    else:
        _vote_window.append(raw_class)
        final_class = (
            collections.Counter(_vote_window).most_common(1)[0][0]
            if len(_vote_window) >= 3
            else raw_class
        )

    log(f"AI: {final_class} (raw={raw_class} conf={conf:.1%} ent={entropy:.3f} {inference_ms:.0f}ms)")

    try:
        db.reference("ai/latest_detection").set({
            "class":      final_class,
            "confidence": round(conf, 4),
            "entropy":    round(entropy, 4),
            "timestamp":  datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
            "source":     "pi_controller",
        })
    except Exception as e:
        log(f"AI Firebase push failed: {e}")

    return final_class

# ── Emergency stop ───────────────────────────────────────────────────────────
def apply_estop(active: bool):
    global _estop
    if active == _estop:
        return
    _estop = active
    if active:
        log("E-STOP — pump killed, stepper aborted")
        _stepper_abort.set()
        set_pump(False, silent=True)
        db.reference("status").update({"system_state": "FAULT"})
        _start_estop_buzz()
    else:
        log("E-stop cleared — NORMAL")
        db.reference("status").update({"system_state": "NORMAL"})
        _stop_estop_buzz()
        _buzz_once(_BUZZ_FAULT_CLR)
    _update_leds()

# ── Auto scan ────────────────────────────────────────────────────────────────
def _get_soil():
    try:
        val = db.reference("sensors/soil_moisture_pct").get()
        return int(val) if val is not None else 100
    except Exception:
        return 100

def _auto_scan():
    global _auto_next_scan
    log("Auto scan: starting plant sweep")

    for plant_idx in range(PLANTS_COUNT):
        if _estop or _prev_mode != "AUTOMATIC":
            log("Auto scan: aborted (estop or mode change)")
            return

        move_to_plant_blocking(plant_idx)

        if _estop:
            return

        time.sleep(AUTO_SETTLE_S)

        # Capture + infer at this plant
        capture_and_infer()

        soil = _get_soil()
        log(f"Auto scan: plant {plant_idx} soil={soil}%")

        if soil < AUTO_SOIL_THRESHOLD:
            _buzz_once(_BUZZ_DRY_SOIL)
            set_pump(True, silent=True)
            pump_start = time.time()
            while time.time() - pump_start < AUTO_PUMP_DURATION_S:
                if _estop:
                    set_pump(False, silent=True)
                    return
                time.sleep(0.2)
            set_pump(False)
            log(f"Auto scan: plant {plant_idx} watered {AUTO_PUMP_DURATION_S}s")

    move_to_plant_blocking(0)
    _auto_next_scan = time.time() + AUTO_SCAN_INTERVAL_S
    log(f"Auto scan: complete. Next in {AUTO_SCAN_INTERVAL_S}s")

def maybe_start_auto_scan():
    global _auto_scan_thread
    with _auto_scan_lock:
        if _auto_scan_thread and _auto_scan_thread.is_alive():
            return
        if time.time() < _auto_next_scan:
            return
        _auto_scan_thread = threading.Thread(target=_auto_scan, daemon=True)
        _auto_scan_thread.start()

# ── Firebase ─────────────────────────────────────────────────────────────────
def init_firebase():
    cred = credentials.Certificate(FIREBASE_CRED)
    firebase_admin.initialize_app(cred, {"databaseURL": FIREBASE_DB_URL})
    db.reference("status").update({
        "mode":         "AUTOMATIC",
        "pump":         "OFF",
        "gantry_plant": 0,
        "system_state": "NORMAL",
    })
    db.reference("commands").update({"emergency_stop": False, "pump_relay": False})
    log("Firebase ready — status seeded")

# ── Poll loop ────────────────────────────────────────────────────────────────
def poll_loop():
    global _prev_pump_ts, _prev_estop, _prev_mode

    while True:
        try:
            cmds   = db.reference("commands").get() or {}
            status = db.reference("status").get() or {}

            # E-stop (highest priority)
            estop = bool(cmds.get("emergency_stop", False))
            if estop != _prev_estop:
                _prev_estop = estop
                apply_estop(estop)

            if _estop:
                time.sleep(POLL_INTERVAL_S)
                continue

            # Mode
            mode = status.get("mode", "AUTOMATIC")
            if mode != _prev_mode:
                _prev_mode = mode
                _update_leds(mode)
                log(f"Mode -> {mode}")

            # Manual pump_action
            if mode == "MANUAL":
                pump_cmd = cmds.get("pump_action") or {}
                pump_ts  = int(pump_cmd.get("timestamp", 0))
                if pump_ts != _prev_pump_ts and pump_ts != 0:
                    _prev_pump_ts = pump_ts
                    plant = int(pump_cmd.get("plant", 0))
                    state = pump_cmd.get("state", "OFF")
                    log(f"Manual: plant={plant} state={state}")
                    move_to_plant_blocking(plant)
                    # Capture + infer after gantry settles
                    time.sleep(AUTO_SETTLE_S)
                    capture_and_infer()
                    if state == "ON":
                        set_pump(True)
                    else:
                        set_pump(False)

            # Auto scan
            if mode == "AUTOMATIC":
                maybe_start_auto_scan()

        except Exception as e:
            log(f"Poll error: {e}")

        time.sleep(POLL_INTERVAL_S)

# ── Entry point ──────────────────────────────────────────────────────────────
def main():
    gpio_init()
    init_firebase()
    init_ai()
    _update_leds("AUTOMATIC")
    _buzz_once(_BUZZ_BOOT)
    log("System ready — entering poll loop")

    try:
        poll_loop()
    except KeyboardInterrupt:
        log("KeyboardInterrupt — shutting down")
    finally:
        set_pump(False, silent=True)
        try:
            db.reference("commands").update({"pump_relay": False})
        except Exception:
            pass
        _stop_estop_buzz()
        gpio_cleanup()
        log("Clean exit")

if __name__ == "__main__":
    main()
