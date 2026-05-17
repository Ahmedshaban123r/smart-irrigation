# ─── Smart Precision Irrigation System ───────────────────────────────────────
# Runs TFLite inference daemon on Raspberry Pi (ARM64) or any Linux machine.

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY model.tflite .
COPY class_names.json .
COPY pi_daemon.py .
COPY main.py .

# Results folder
RUN mkdir -p results

# Default: run the 50-loop test
CMD ["python3", "main.py"]