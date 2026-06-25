#!/usr/bin/env python3
"""Quick stepper motor test — DRV8825 on Pi GPIO."""
import time
import RPi.GPIO as GPIO

PIN_STEP = 20   # BCM 20, Pin 38
PIN_DIR  = 21   # BCM 21, Pin 40

STEPS = 3200         # 1 full revolution at 1/16 microstepping (200 * 16)
DELAY = 0.001        # seconds between pulses
DIRECTION = True     # True = forward, False = reverse

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(PIN_STEP, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(PIN_DIR, GPIO.OUT)

GPIO.output(PIN_DIR, GPIO.HIGH if DIRECTION else GPIO.LOW)

print(f"Moving {STEPS} steps {'forward' if DIRECTION else 'reverse'}...")

try:
    for i in range(STEPS):
        GPIO.output(PIN_STEP, GPIO.HIGH)
        time.sleep(DELAY)
        GPIO.output(PIN_STEP, GPIO.LOW)
        time.sleep(DELAY)
    print("Done.")
except KeyboardInterrupt:
    print("Stopped.")
finally:
    GPIO.cleanup()
