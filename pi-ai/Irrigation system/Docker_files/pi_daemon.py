#!/usr/bin/env python3
"""
Pi Inference Daemon — Smart Precision Irrigation System
Captures images -> runs TFLite inference -> sends UART protocol to PIC -> pushes to Firebase.

Usage:
    python3 pi_daemon.py                       # Normal operation with camera
    python3 pi_daemon.py --test-image leaf.jpg # Test with a static image
"""

import argparse
import logging
import signal
import sys
import time
from datetime import datetime, timezone

import numpy as np
import serial
import firebase_admin
from firebase_admin import credentials, db
from ai_edge_litert.interpreter import Interpreter

# ─── CONFIG ──────────────────────────────────────────────────────────────
UART_PORT        = "/dev/ttyAMA0"
UART_BAUD        = 9600
MODEL_PATH       = "/home/akai2004/irrigation/model.tflite"
FIREBASE_KEY     = "/home/akai2004/irrigation/firebase-service-key.json"
FIREBASE_DB      = "https://embedded-project-32dca-default-rtdb.firebaseio.com"
LOG_PATH         = "/tmp/irrigation_daemon.log"

START_BYTE       = 0xBB
END_BYTE         = 0xEE

INPUT_SIZE       = 224
CAPTURE_INTERVAL = 1.0

CLASS_NAMES = ["Early_Blight", "Healthy", "Late_Blight", "Nutrient_Deficiency", "Pest"]

PROTOCOL_MAP = {
    "Early_Blight":        0x02,
    "Healthy":             0x01,
    "Late_Blight":         0x03,
    "Nutrient_Deficiency": 0x05,
    "Pest":                0x04,
}

CONFIDENCE_THRESHOLDS = {
    "Early_Blight":        0.80,
    "Healthy":             0.90,
    "Late_Blight":         0.75,
    "Nutrient_Deficiency": 0.75,
    "Pest":                0.70,
}

PROTOCOL_PARAMS = {
    0x01: (0,   1),
    0x02: (60,  1),
    0x03: (0,   1),
    0x04: (3,   6),
    0x05: (130, 1),
    0xFF: (0,   1),
}

MAX_RETRIES  = 3
RETRY_DELAY  = 0.5

# ─── LOGGING ─────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_PATH),
        logging.StreamHandler(sys.stdout),
    ],
)
logger = logging.getLogger("pi_daemon")

# ─── GRACEFUL SHUTDOWN ───────────────────────────────────────────────────
shutdown_flag = False

def signal_handler(sig, frame):
    global shutdown_flag
    logger.info(f"Received signal {sig}, shutting down...")
    shutdown_flag = True

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

# ─── UART ────────────────────────────────────────────────────────────────
def build_packet(protocol_id: int, zone_x: int, param1: int, param2: int) -> bytes:
    zone_y  = 0x00
    payload = bytes([START_BYTE, protocol_id, zone_x, zone_y, param1, param2])
    crc     = 0
    for b in payload[1:]:
        crc ^= b
    return payload + bytes([crc & 0xFF, END_BYTE])

def send_packet(ser: serial.Serial, packet: bytes) -> bool:
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            n = ser.write(packet)
            ser.flush()
            if n == len(packet):
                logger.info(f"UART TX OK (attempt {attempt}): {packet.hex()}")
                return True
            logger.warning(f"Partial write: {n}/{len(packet)}")
        except serial.SerialException as e:
            logger.error(f"UART error (attempt {attempt}): {e}")
            if attempt < MAX_RETRIES:
                time.sleep(RETRY_DELAY)
    logger.error(f"UART TX FAILED: {packet.hex()}")
    return False

# ─── FIREBASE ────────────────────────────────────────────────────────────
def push_to_firebase(cls: str, conf: float, proto: int, zone_x: int):
    try:
        db.reference("/ai/latest_detection").set({
            "class":      cls,
            "confidence": round(conf, 4),
            "protocol":   f"0x{proto:02X}",
            "zone_x":     zone_x,
            "timestamp":  datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
            "image_url":  "",
            "source":     "pi_daemon",
        })
        logger.info(f"Firebase push OK: {cls} ({conf:.2%})")
    except Exception as e:
        logger.error(f"Firebase push FAILED: {e}")

# ─── INFERENCE ───────────────────────────────────────────────────────────
def load_model(path: str):
    interpreter = Interpreter(model_path=path)
    interpreter.allocate_tensors()
    input_details  = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    return interpreter, input_details, output_details

def preprocess(image_array: np.ndarray, input_details) -> np.ndarray:
    from PIL import Image
    img = Image.fromarray(image_array).resize((INPUT_SIZE, INPUT_SIZE))
    arr = np.array(img, dtype=np.float32)  # raw [0-255], no normalization
    arr = np.expand_dims(arr, axis=0)

    if input_details[0]['dtype'] == np.int8:
        scale, zero_point = input_details[0]['quantization']
        arr = (arr / scale + zero_point).astype(np.int8)
    elif input_details[0]['dtype'] == np.uint8:
        scale, zero_point = input_details[0]['quantization']
        arr = (arr / scale + zero_point).astype(np.uint8)

    return arr

def run_inference(interpreter, input_details, output_details, image: np.ndarray):
    input_data = preprocess(image, input_details)
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])

    if output_details[0]['dtype'] in (np.uint8, np.int8):
        scale, zero_point = output_details[0]['quantization']
        output = (output.astype(np.float32) - zero_point) * scale

    probs = output[0]
    if np.any(probs < 0) or not (0.9 <= np.sum(probs) <= 1.1):
        exp_probs = np.exp(probs - np.max(probs))
        probs     = exp_probs / np.sum(exp_probs)

    class_idx  = int(np.argmax(probs))
    confidence = float(probs[class_idx])
    return CLASS_NAMES[class_idx], confidence

# ─── MAIN LOOP ───────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--test-image", type=str, help="Path to test image (skips camera)")
    args = parser.parse_args()

    logger.info("="*60)
    logger.info("Pi Inference Daemon starting")
    logger.info("="*60)

    logger.info("Initializing Firebase...")
    cred = credentials.Certificate(FIREBASE_KEY)
    firebase_admin.initialize_app(cred, {"databaseURL": FIREBASE_DB})

    logger.info(f"Loading model from {MODEL_PATH}...")
    interpreter, input_det, output_det = load_model(MODEL_PATH)
    logger.info("Model loaded OK")

    logger.info(f"Opening UART: {UART_PORT} @ {UART_BAUD}")
    try:
        ser = serial.Serial(UART_PORT, UART_BAUD, timeout=1)
        time.sleep(0.1)
        ser.reset_input_buffer()
        logger.info("UART OK")
    except Exception as e:
        logger.warning(f"UART init failed: {e} — continuing without UART")
        ser = None

    test_image = None
    cam        = None
    if args.test_image:
        from PIL import Image
        logger.info(f"Test mode: using image {args.test_image}")
        test_image = np.array(Image.open(args.test_image).convert("RGB"))
    else:
        from picamera2 import Picamera2
        cam = Picamera2()
        cam.configure(cam.create_still_configuration(main={"size": (640, 480)}))
        cam.start()
        time.sleep(2)
        logger.info("Camera started")

    logger.info("Entering main loop...")
    inference_count = 0

    while not shutdown_flag:
        loop_start = time.monotonic()

        image = test_image if test_image is not None else cam.capture_array()

        t0 = time.monotonic()
        predicted_class, confidence = run_inference(interpreter, input_det, output_det, image)
        inference_ms = (time.monotonic() - t0) * 1000
        inference_count += 1

        logger.info(
            f"[#{inference_count}] Class: {predicted_class} | "
            f"Conf: {confidence:.2%} | Inference: {inference_ms:.0f}ms"
        )

        threshold = CONFIDENCE_THRESHOLDS.get(predicted_class, 0.70)
        if confidence < threshold:
            logger.info(f"Below threshold ({threshold:.0%}), flagging for review")
            predicted_class = "Unknown"
            protocol_id     = 0xFF
        else:
            protocol_id = PROTOCOL_MAP[predicted_class]

        param1, param2 = PROTOCOL_PARAMS[protocol_id]
        zone_x         = 0x80
        packet         = build_packet(protocol_id, zone_x, param1, param2)

        if ser:
            send_packet(ser, packet)
        else:
            logger.info(f"UART skipped — packet would be: {packet.hex()}")

        push_to_firebase(predicted_class, confidence, protocol_id, zone_x)

        elapsed    = time.monotonic() - loop_start
        sleep_time = max(0, CAPTURE_INTERVAL - elapsed)
        if sleep_time > 0:
            time.sleep(sleep_time)

    logger.info("Shutting down...")
    if cam:
        cam.stop()
    if ser:
        ser.close()
    logger.info("Daemon stopped cleanly")

if __name__ == "__main__":
    main()
