#!/usr/bin/env python3
"""
Pi AI Daemon — exhibition build.
Captures images -> TFLite inference -> entropy-based Unknown -> temporal smoothing -> Firebase.
No UART. 3 classes: Early_Blight, Healthy, Late_Blight.
"""

import argparse
import collections
import json
import logging
import signal
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import firebase_admin
from firebase_admin import credentials, db

try:
    from ai_edge_litert.interpreter import Interpreter
except ImportError:
    try:
        import tflite_runtime.interpreter as _tfl
        Interpreter = _tfl.Interpreter
    except ImportError:
        import tensorflow as tf
        Interpreter = tf.lite.Interpreter

# ── Config ──────────────────────────────────────────────────────────────
MODEL_PATH       = "/home/robox/Final_Project/model.tflite"
ENTROPY_CFG      = "/home/robox/Final_Project/entropy_threshold.json"
FIREBASE_KEY     = "/home/robox/Final_Project/firebase-service-key.json"
FIREBASE_DB      = "https://embedded-project-32dca-default-rtdb.firebaseio.com"
LOG_PATH         = "/tmp/irrigation_daemon.log"

INPUT_SIZE       = 224
CAPTURE_INTERVAL = 1.0

CLASS_NAMES      = ["Early_Blight", "Healthy", "Late_Blight"]
NUM_CLASSES      = len(CLASS_NAMES)

SMOOTHING_WINDOW = 5

# ── Logging ─────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_PATH),
        logging.StreamHandler(sys.stdout),
    ],
)
logger = logging.getLogger("pi_daemon")

# ── Shutdown ────────────────────────────────────────────────────────────
shutdown_flag = False

def _signal_handler(sig, _frame):
    global shutdown_flag
    logger.info(f"Signal {sig} — shutting down")
    shutdown_flag = True

signal.signal(signal.SIGTERM, _signal_handler)
signal.signal(signal.SIGINT, _signal_handler)

# ── Model ───────────────────────────────────────────────────────────────
def load_model(path):
    interp = Interpreter(model_path=path)
    interp.allocate_tensors()
    return interp, interp.get_input_details()[0], interp.get_output_details()[0]

def load_entropy_threshold(path):
    with open(path) as f:
        return json.load(f)["entropy_threshold"]

# ── Inference ───────────────────────────────────────────────────────────
def preprocess(image_array, inp_detail):
    from PIL import Image
    img = Image.fromarray(image_array).resize((INPUT_SIZE, INPUT_SIZE))
    arr = np.array(img, dtype=np.float32)
    arr = np.expand_dims(arr, axis=0)

    if inp_detail["dtype"] == np.int8:
        scale, zp = inp_detail["quantization"]
        arr = np.clip(np.round(arr / scale + zp), -128, 127).astype(np.int8)
    elif inp_detail["dtype"] == np.uint8:
        scale, zp = inp_detail["quantization"]
        arr = np.clip(np.round(arr / scale + zp), 0, 255).astype(np.uint8)

    return arr

def run_inference(interp, inp, out, image):
    tensor = preprocess(image, inp)
    interp.set_tensor(inp["index"], tensor)
    interp.invoke()
    raw = interp.get_tensor(out["index"]).astype(np.float32)

    if out["dtype"] in (np.int8, np.uint8):
        scale, zp = out["quantization"]
        raw = (raw - zp) * scale

    logits = raw[0]
    exp_l = np.exp(logits - logits.max())
    probs = exp_l / exp_l.sum()

    idx = int(np.argmax(probs))
    conf = float(probs[idx])

    p = np.clip(probs, 1e-9, 1.0)
    entropy = float(-np.sum(p * np.log(p)) / np.log(NUM_CLASSES))

    return CLASS_NAMES[idx], conf, entropy

# ── Temporal smoothing ──────────────────────────────────────────────────
def majority_vote(window):
    counts = collections.Counter(window)
    return counts.most_common(1)[0][0]

# ── Firebase ────────────────────────────────────────────────────────────
def push_detection(cls, conf, entropy):
    try:
        db.reference("ai/latest_detection").set({
            "class":      cls,
            "confidence": round(conf, 4),
            "entropy":    round(entropy, 4),
            "timestamp":  datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
            "source":     "pi_daemon",
        })
        logger.info(f"Firebase: {cls} conf={conf:.2%} ent={entropy:.3f}")
    except Exception as e:
        logger.error(f"Firebase push failed: {e}")

# ── Main ────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--test-image", type=str, help="Static image path (skip camera)")
    args = parser.parse_args()

    logger.info("=" * 50)
    logger.info("Pi AI Daemon — exhibition build")
    logger.info("=" * 50)

    cred = credentials.Certificate(FIREBASE_KEY)
    firebase_admin.initialize_app(cred, {"databaseURL": FIREBASE_DB})
    logger.info("Firebase ready")

    interp, inp, out = load_model(MODEL_PATH)
    logger.info(f"Model loaded: {MODEL_PATH}")

    entropy_threshold = load_entropy_threshold(ENTROPY_CFG)
    logger.info(f"Entropy threshold: {entropy_threshold:.4f}")

    test_image = None
    cam = None
    if args.test_image:
        from PIL import Image
        test_image = np.array(Image.open(args.test_image).convert("RGB"))
        logger.info(f"Test mode: {args.test_image}")
    else:
        import cv2
        cam = cv2.VideoCapture(0, cv2.CAP_V4L2)
        cam.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc('M','J','P','G'))
        cam.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
        if not cam.isOpened():
            logger.error("Camera not opened")
            return
        time.sleep(2)
        logger.info("Camera started (OpenCV V4L2 MJPG)")

    vote_window = collections.deque(maxlen=SMOOTHING_WINDOW)
    count = 0

    while not shutdown_flag:
        t0 = time.monotonic()

        if test_image is not None:
            image = test_image
        else:
            import cv2
            ret, frame = cam.read()
            if not ret:
                continue
            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        raw_class, confidence, entropy = run_inference(interp, inp, out, image)
        inference_ms = (time.monotonic() - t0) * 1000
        count += 1

        if entropy > entropy_threshold:
            final_class = "Unknown"
        else:
            vote_window.append(raw_class)
            final_class = majority_vote(vote_window) if len(vote_window) >= 3 else raw_class

        logger.info(
            f"[#{count}] raw={raw_class} final={final_class} "
            f"conf={confidence:.2%} ent={entropy:.3f} {inference_ms:.0f}ms"
        )

        push_detection(final_class, confidence, entropy)

        elapsed = time.monotonic() - t0
        sleep_time = max(0, CAPTURE_INTERVAL - elapsed)
        if sleep_time > 0:
            time.sleep(sleep_time)

    logger.info("Shutting down...")
    if cam:
        cam.release()
    logger.info("Daemon stopped")

if __name__ == "__main__":
    main()
