#!/usr/bin/env python3
"""
Quick test: Pi camera → TFLite model → print result.
No Firebase, no GPIO, no threads. Just verify model works with live camera.

Usage:
    python3 test_camera_inference.py                          # live camera loop
    python3 test_camera_inference.py --image leaf.jpg         # single image
    python3 test_camera_inference.py --model /path/model.tflite
"""

import argparse
import json
import time
from pathlib import Path

import numpy as np

try:
    from ai_edge_litert.interpreter import Interpreter
except ImportError:
    try:
        import tflite_runtime.interpreter as _tfl
        Interpreter = _tfl.Interpreter
    except ImportError:
        import tensorflow as tf
        Interpreter = tf.lite.Interpreter

CLASS_NAMES = ["Early_Blight", "Healthy", "Late_Blight"]
INPUT_SIZE  = 224


def load_model(path):
    interp = Interpreter(model_path=path)
    interp.allocate_tensors()
    inp = interp.get_input_details()[0]
    out = interp.get_output_details()[0]
    print(f"Model loaded: {path}")
    print(f"  Input:  {inp['shape']} {inp['dtype'].__name__}")
    print(f"  Output: {out['shape']} {out['dtype'].__name__}")
    return interp, inp, out


def infer(interp, inp, out, image_array):
    from PIL import Image
    img = Image.fromarray(image_array).resize((INPUT_SIZE, INPUT_SIZE))
    arr = np.array(img, dtype=np.float32)[np.newaxis]

    if inp["dtype"] == np.int8:
        s, z = inp["quantization"]
        arr = np.clip(np.round(arr / s + z), -128, 127).astype(np.int8)
    elif inp["dtype"] == np.uint8:
        s, z = inp["quantization"]
        arr = np.clip(np.round(arr / s + z), 0, 255).astype(np.uint8)

    interp.set_tensor(inp["index"], arr)
    interp.invoke()
    raw = interp.get_tensor(out["index"]).astype(np.float32)

    if out["dtype"] in (np.int8, np.uint8):
        s, z = out["quantization"]
        raw = (raw - z) * s

    logits = raw[0]
    exp_l = np.exp(logits - logits.max())
    probs = exp_l / exp_l.sum()

    idx = int(np.argmax(probs))
    conf = float(probs[idx])
    p = np.clip(probs, 1e-9, 1.0)
    entropy = float(-np.sum(p * np.log(p)) / np.log(len(CLASS_NAMES)))

    return CLASS_NAMES[idx], conf, entropy, probs


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="/home/robox/Final_Project/model.tflite")
    parser.add_argument("--image", default=None, help="Test with single image instead of camera")
    parser.add_argument("--interval", type=float, default=2.0, help="Seconds between captures")
    args = parser.parse_args()

    model_dir = Path(args.model).parent
    entropy_path = model_dir / "entropy_threshold.json"
    entropy_threshold = 0.5
    if entropy_path.exists():
        with open(entropy_path) as f:
            entropy_threshold = json.load(f)["entropy_threshold"]
        print(f"Entropy threshold: {entropy_threshold:.4f}")
    else:
        print(f"Warning: {entropy_path} not found, using default {entropy_threshold}")

    interp, inp, out = load_model(args.model)

    if args.image:
        from PIL import Image
        img = np.array(Image.open(args.image).convert("RGB"))
        cls, conf, ent, probs = infer(interp, inp, out, img)
        final = "Unknown" if ent > entropy_threshold else cls
        print(f"\nResult: {final}")
        print(f"  Raw class:  {cls}")
        print(f"  Confidence: {conf:.1%}")
        print(f"  Entropy:    {ent:.4f} {'(> threshold → Unknown)' if ent > entropy_threshold else ''}")
        print(f"  All probs:  {', '.join(f'{CLASS_NAMES[i]}={probs[i]:.3f}' for i in range(len(CLASS_NAMES)))}")
        return

    import cv2
    cam = cv2.VideoCapture(0, cv2.CAP_V4L2)
    cam.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc('M','J','P','G'))
    cam.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    if not cam.isOpened():
        print("ERROR: Camera not opened")
        return
    time.sleep(2)
    print(f"\nCamera started (OpenCV V4L2 MJPG) — capturing every {args.interval}s (Ctrl+C to stop)\n")

    count = 0
    try:
        while True:
            t0 = time.monotonic()
            ret, frame = cam.read()
            if not ret:
                print("Capture failed, retrying...")
                continue
            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            cls, conf, ent, probs = infer(interp, inp, out, image)
            ms = (time.monotonic() - t0) * 1000
            final = "Unknown" if ent > entropy_threshold else cls
            count += 1

            print(
                f"[{count:4d}] {final:<14s} "
                f"(raw={cls}, conf={conf:.1%}, ent={ent:.3f}) "
                f"{ms:.0f}ms"
            )

            elapsed = time.monotonic() - t0
            time.sleep(max(0, args.interval - elapsed))
    except KeyboardInterrupt:
        print(f"\nStopped after {count} captures")
    finally:
        cam.release()


if __name__ == "__main__":
    main()
