"""Convert model.tflite to model.onnx for Pi deployment."""
import subprocess
import sys

subprocess.check_call([sys.executable, "-m", "pip", "install", "tf2onnx", "tensorflow", "--quiet"])

import tf2onnx
import tensorflow as tf
import numpy as np

tflite_path = "model.tflite"
onnx_path = "model.onnx"

interpreter = tf.lite.Interpreter(model_path=tflite_path)
interpreter.allocate_tensors()

inp = interpreter.get_input_details()[0]
out = interpreter.get_output_details()[0]

print(f"Input: {inp['shape']} dtype={inp['dtype']}")
print(f"Output: {out['shape']} dtype={out['dtype']}")

import onnx
from tf2onnx import tfonnx

# Use tf2onnx CLI approach - most reliable for tflite
subprocess.check_call([
    sys.executable, "-m", "tf2onnx.convert",
    "--tflite", tflite_path,
    "--output", onnx_path,
    "--opset", "13"
])

print(f"Saved {onnx_path}")
