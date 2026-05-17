#!/usr/bin/env python3
"""
AI-Actuation Loop — 50 runs with real TFLite inference
Logs success rate, class predictions, confidence, and UART packets.
"""

import json
import time
import numpy as np
from pathlib import Path
from PIL import Image
import tflite_runtime.interpreter as tflite

# ─── CONFIG ──────────────────────────────────────────────────────────────────
MODEL_PATH      = "model.tflite"
CLASS_NAMES_PATH = "class_names.json"
SAMPLE_IMAGES   = "results/sample_images.png"  # fallback if no real images
RUNS            = 50
INPUT_SIZE      = 224

PROTOCOL_MAP = {
    "healthy":             0x01,
    "early_blight":        0x02,
    "late_blight":         0x03,
    "pest":                0x04,
    "nutrient_deficiency": 0x05,
    "unknown":             0xFF,
}

CONFIDENCE_THRESHOLDS = {
    "healthy":             0.90,
    "early_blight":        0.80,
    "late_blight":         0.75,
    "pest":                0.70,
    "nutrient_deficiency": 0.75,
}

START_BYTE = 0xBB
END_BYTE   = 0xEE

# ─── LOAD CLASS NAMES ────────────────────────────────────────────────────────
with open(CLASS_NAMES_PATH) as f:
    CLASS_NAMES = json.load(f)

# ─── LOAD MODEL ──────────────────────────────────────────────────────────────
interpreter = tflite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
input_details  = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print(f"✅ Model loaded: {MODEL_PATH}")
print(f"✅ Classes: {CLASS_NAMES}")

# ─── HELPERS ─────────────────────────────────────────────────────────────────
def preprocess(image_path: str) -> np.ndarray:
    img = Image.open(image_path).convert("RGB").resize((INPUT_SIZE, INPUT_SIZE))
    arr = np.array(img, dtype=np.float32)
    scale, zero_point = input_details[0]['quantization']
    if scale != 0:
        arr = (arr / scale + zero_point).astype(np.int8)
    else:
        arr = arr.astype(np.float32) / 255.0
    return np.expand_dims(arr, axis=0)

def run_inference(image_path: str):
    input_data = preprocess(image_path)
    interpreter.set_tensor(input_details[0]['index'], input_data)

    t0 = time.monotonic()
    interpreter.invoke()
    inference_ms = (time.monotonic() - t0) * 1000

    output = interpreter.get_tensor(output_details[0]['index'])

    if output_details[0]['dtype'] in (np.uint8, np.int8):
        scale, zero_point = output_details[0]['quantization']
        output = (output.astype(np.float32) - zero_point) * scale

    probs = output[0]
    if np.any(probs < 0) or not (0.99 <= np.sum(probs) <= 1.01):
        exp_p = np.exp(probs - np.max(probs))
        probs = exp_p / np.sum(exp_p)

    class_idx  = int(np.argmax(probs))
    confidence = float(probs[class_idx])
    class_name = CLASS_NAMES[class_idx] if class_idx < len(CLASS_NAMES) else "unknown"

    return class_name, confidence, inference_ms

def build_uart_packet(protocol_id: int, zone_x: int = 0x80) -> bytes:
    param_map = {
        0x01: (0,   1),
        0x02: (60,  1),
        0x03: (0,   1),
        0x04: (3,   6),
        0x05: (130, 1),
        0xFF: (0,   1),
    }
    param1, param2 = param_map.get(protocol_id, (0, 1))
    zone_y  = 0x00
    payload = bytes([START_BYTE, protocol_id, zone_x, zone_y, param1, param2])
    crc     = 0
    for b in payload[1:]:
        crc ^= b
    return payload + bytes([crc & 0xFF, END_BYTE])

# ─── FIND TEST IMAGES ────────────────────────────────────────────────────────
image_files = [Path("test.jpg")]

if not image_files:
    print("⚠️  No images found! Put some leaf images in the project folder.")
    exit(1)

print(f"📸 Found {len(image_files)} images for testing")

# ─── MAIN LOOP ───────────────────────────────────────────────────────────────
logs        = []
success     = 0
total_ms    = 0

print(f"\n🔁 Running {RUNS} inference loops...\n")

for i in range(RUNS):
    # cycle through available images
    img_path = str(image_files[i % len(image_files)])

    t_start = time.monotonic()

    predicted_class, confidence, inference_ms = run_inference(img_path)
    total_ms += inference_ms

    # Check threshold (normalize to lowercase for lookup)
    threshold = CONFIDENCE_THRESHOLDS.get(predicted_class.lower(), 0.70)
    if confidence < threshold:
        predicted_class = "unknown"

    protocol_id = PROTOCOL_MAP.get(predicted_class.lower(), 0xFF)
    packet      = build_uart_packet(protocol_id)

    latency_ms = (time.monotonic() - t_start) * 1000

    if predicted_class != "unknown":
        success += 1

    run_data = {
        "run":          i + 1,
        "image":        img_path,
        "class":        predicted_class,
        "confidence":   round(confidence, 4),
        "protocol":     f"0x{protocol_id:02X}",
        "uart_packet":  packet.hex(),
        "inference_ms": round(inference_ms, 1),
        "latency_ms":   round(latency_ms, 1),
    }
    logs.append(run_data)

    print(
        f"[{i+1:02d}/50] {predicted_class:<20} "
        f"conf={confidence:.2%}  "
        f"proto=0x{protocol_id:02X}  "
        f"infer={inference_ms:.0f}ms"
    )

# ─── RESULTS ─────────────────────────────────────────────────────────────────
success_rate = success / RUNS
avg_ms       = total_ms / RUNS

print(f"\n{'='*55}")
print(f"✅ Success Rate   : {success_rate:.2%} ({success}/{RUNS})")
print(f"⚡ Avg Inference  : {avg_ms:.1f}ms")
print(f"🎯 Target         : >95% success, <200ms inference")
print(f"{'='*55}\n")

# Save logs
Path("results").mkdir(exist_ok=True)
with open("results/run_logs.json", "w") as f:
    json.dump({
        "summary": {
            "success_rate": round(success_rate, 4),
            "successful_runs": success,
            "total_runs": RUNS,
            "avg_inference_ms": round(avg_ms, 1),
        },
        "runs": logs
    }, f, indent=4)

print("📄 Logs saved to results/run_logs.json")