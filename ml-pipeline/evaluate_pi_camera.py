#!/usr/bin/env python3
"""Evaluate TFLite model on Pi camera reference images (3-class)."""
import json, sys, os
import numpy as np
from pathlib import Path
from PIL import Image

try:
    from ai_edge_litert.interpreter import Interpreter
except ImportError:
    try:
        import tflite_runtime.interpreter as tflite_mod
        Interpreter = tflite_mod.Interpreter
    except ImportError:
        import tensorflow as tf
        Interpreter = tf.lite.Interpreter

MODEL_PATH = sys.argv[1] if len(sys.argv) > 1 else "model.tflite"
REF_DIR = sys.argv[2] if len(sys.argv) > 2 else "pi_camera_ref"
IMG_SIZE = 224
CLASS_NAMES = ['Early_Blight', 'Healthy', 'Late_Blight']

with open(Path(MODEL_PATH).parent / "entropy_threshold.json") as f:
    ENTROPY_THRESHOLD = json.load(f)["entropy_threshold"]
print(f"Entropy threshold: {ENTROPY_THRESHOLD:.4f}")

interpreter = Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
inp = interpreter.get_input_details()[0]
out = interpreter.get_output_details()[0]
in_scale, in_zp = inp['quantization']
out_scale, out_zp = out['quantization']

results = {cls: {'correct': 0, 'total': 0, 'preds': []} for cls in CLASS_NAMES}

for cls_dir in sorted(Path(REF_DIR).iterdir()):
    if not cls_dir.is_dir() or cls_dir.name not in CLASS_NAMES:
        continue
    true_class = cls_dir.name
    print(f"\n--- {true_class} ---")

    for img_path in sorted(cls_dir.glob("*")):
        if img_path.suffix.lower() not in ['.jpg', '.jpeg', '.png']:
            continue
        img = Image.open(img_path).convert("RGB").resize((IMG_SIZE, IMG_SIZE))
        arr = np.array(img, dtype=np.float32)
        arr_int8 = np.round(arr / in_scale + in_zp).clip(-128, 127).astype(np.int8)

        interpreter.set_tensor(inp['index'], arr_int8[np.newaxis])
        interpreter.invoke()
        raw = interpreter.get_tensor(out['index']).astype(np.float32)
        logits = (raw - out_zp) * out_scale
        exp_l = np.exp(logits - logits.max())
        probs = (exp_l / exp_l.sum()).flatten()

        pred_idx = int(np.argmax(probs))
        pred_class = CLASS_NAMES[pred_idx]
        conf = float(probs[pred_idx])

        p = np.clip(probs, 1e-9, 1.0)
        entropy = float(-np.sum(p * np.log(p)) / np.log(len(CLASS_NAMES)))

        if entropy > ENTROPY_THRESHOLD:
            final = "Unknown"
            correct = False
        else:
            final = pred_class
            correct = (pred_class == true_class)

        results[true_class]['total'] += 1
        if correct:
            results[true_class]['correct'] += 1
        results[true_class]['preds'].append({
            'file': img_path.name,
            'predicted': final,
            'raw_pred': pred_class,
            'confidence': round(conf, 3),
            'entropy': round(entropy, 3),
            'correct': correct,
        })

        tag = "OK" if correct else ("UNKNOWN" if final == "Unknown" else "WRONG")
        print(f"  [{tag}] {img_path.name}: {final} (conf={conf:.1%}, ent={entropy:.3f})")

print("\n" + "=" * 60)
total_correct = sum(r['correct'] for r in results.values())
total_images = sum(r['total'] for r in results.values())
overall_acc = total_correct / total_images if total_images else 0

print(f"OVERALL: {total_correct}/{total_images} = {overall_acc:.0%}\n")
for cls in CLASS_NAMES:
    r = results[cls]
    if r['total'] > 0:
        acc = r['correct'] / r['total']
        print(f"  {cls:<16}: {r['correct']}/{r['total']} = {acc:.0%}")

verdict = "PASS" if overall_acc >= 0.85 else "FAIL"
print(f"\n{verdict} (target: >=85%)")
if verdict == "FAIL":
    print("  -> Consider Task 6 (few-shot fine-tuning on Pi camera images)")

out_path = Path(REF_DIR) / "evaluation_results.json"
with open(out_path, "w") as f:
    json.dump({
        'overall_accuracy': round(overall_acc, 4),
        'per_class': {cls: {
            'accuracy': round(r['correct'] / r['total'], 4) if r['total'] else 0,
            'correct': r['correct'], 'total': r['total'],
            'predictions': r['preds'],
        } for cls, r in results.items()},
        'model': MODEL_PATH,
        'entropy_threshold': ENTROPY_THRESHOLD,
        'pass': overall_acc >= 0.85,
    }, f, indent=2)
print(f"\nResults saved: {out_path}")
