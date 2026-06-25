#!/usr/bin/env python3
"""Quick GPIO test — blinks STEP and DIR pins to verify Pi output works."""

import RPi.GPIO as GPIO
import time

STEP_PIN = 20
DIR_PIN = 21

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(STEP_PIN, GPIO.OUT)
GPIO.setup(DIR_PIN, GPIO.OUT)

print(f"Blinking GPIO {STEP_PIN} (STEP) and GPIO {DIR_PIN} (DIR)...")
print("Hook LED+resistor to either pin to verify output.")
print("Ctrl+C to stop.\n")

try:
    for i in range(20):
        GPIO.output(STEP_PIN, GPIO.HIGH)
        GPIO.output(DIR_PIN, GPIO.HIGH)
        print(f"  [{i+1}/20] HIGH")
        time.sleep(0.5)
        GPIO.output(STEP_PIN, GPIO.LOW)
        GPIO.output(DIR_PIN, GPIO.LOW)
        print(f"  [{i+1}/20] LOW")
        time.sleep(0.5)
    print("\nDone. If LED blinked → Pi GPIOs working fine.")
except KeyboardInterrupt:
    print("\nStopped.")
finally:
    GPIO.cleanup()
