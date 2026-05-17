#!/bin/bash
# ─── Capture image from USB camera then run inference ───────────────────────

PHOTO_PATH="/home/akai2004/irrigation/capture_latest.jpg"
DAEMON_PATH="/home/akai2004/irrigation/pi_daemon.py"
VENV_PATH="/home/akai2004/irrigation/venv/bin/activate"

echo "📸 Capturing image..."
fswebcam \
    -d /dev/video0 \
    -r 1920x1080 \
    --no-banner \
    --jpeg 95 \
    --skip 30 \
    --delay 2 \
    "$PHOTO_PATH"

if [ $? -ne 0 ]; then
    echo "❌ Camera capture failed!"
    exit 1
fi

echo "✅ Image saved to $PHOTO_PATH"
echo "🤖 Running inference..."

source "$VENV_PATH"
python3 "$DAEMON_PATH" --test-image "$PHOTO_PATH"
