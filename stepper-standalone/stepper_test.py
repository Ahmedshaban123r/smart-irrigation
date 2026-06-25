#!/usr/bin/env python3
"""
Stepper motor control via DRV8825 on Raspberry Pi.
Microstepping enabled — 1/8 step mode for smooth motion.
"""

import RPi.GPIO as GPIO
import time
import argparse

# --- Pin assignments (BCM) ---
STEP_PIN = 20    # Pi pin 38 → DRV8825 STEP
DIR_PIN  = 21    # Pi pin 40 → DRV8825 DIR

# DRV8825 microstep config pins
M0_PIN = 24      # Pi pin 18
M1_PIN = 23      # Pi pin 16
M2_PIN = 18      # Pi pin 12

# Microstep modes: (M0, M1, M2) → step divisor
MICROSTEP_MODES = {
    1:   (0, 0, 0),   # full step
    2:   (1, 0, 0),   # 1/2 step
    4:   (0, 1, 0),   # 1/4 step
    8:   (1, 1, 0),   # 1/8 step  ← default, smooth
    16:  (0, 0, 1),   # 1/16 step
    32:  (1, 0, 1),   # 1/32 step — smoothest but slowest
}

STEPS_PER_REV = 200  # NEMA 17 standard


def setup(microstep=8):
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)

    GPIO.setup(STEP_PIN, GPIO.OUT)
    GPIO.setup(DIR_PIN, GPIO.OUT)
    GPIO.setup(M0_PIN, GPIO.OUT)
    GPIO.setup(M1_PIN, GPIO.OUT)
    GPIO.setup(M2_PIN, GPIO.OUT)

    m0, m1, m2 = MICROSTEP_MODES[microstep]
    GPIO.output(M0_PIN, m0)
    GPIO.output(M1_PIN, m1)
    GPIO.output(M2_PIN, m2)

    print(f"[Stepper] Microstep: 1/{microstep}  |  Effective steps/rev: {STEPS_PER_REV * microstep}")


def rotate(degrees, direction="cw", microstep=8, rpm=10):
    """Rotate stepper by given degrees."""
    effective_steps_per_rev = STEPS_PER_REV * microstep
    steps = int((degrees / 360.0) * effective_steps_per_rev)

    # delay between pulses from RPM
    step_delay = 60.0 / (rpm * effective_steps_per_rev)

    GPIO.output(DIR_PIN, GPIO.HIGH if direction == "cw" else GPIO.LOW)

    print(f"[Stepper] {direction.upper()} {degrees}° → {steps} microsteps @ {rpm} RPM")

    for i in range(steps):
        GPIO.output(STEP_PIN, GPIO.HIGH)
        time.sleep(step_delay / 2)
        GPIO.output(STEP_PIN, GPIO.LOW)
        time.sleep(step_delay / 2)

    print("[Stepper] Done.")


def sweep(cycles=2, degrees=90, microstep=8, rpm=10):
    """Sweep back and forth for testing."""
    for i in range(cycles):
        print(f"\n--- Sweep {i+1}/{cycles} ---")
        rotate(degrees, "cw", microstep, rpm)
        time.sleep(0.3)
        rotate(degrees, "ccw", microstep, rpm)
        time.sleep(0.3)


def main():
    parser = argparse.ArgumentParser(description="DRV8825 Stepper Motor Control")
    parser.add_argument("--degrees", type=float, default=90, help="Degrees to rotate (default: 90)")
    parser.add_argument("--dir", choices=["cw", "ccw"], default="cw", help="Direction (default: cw)")
    parser.add_argument("--rpm", type=float, default=10, help="Speed in RPM (default: 10)")
    parser.add_argument("--microstep", type=int, choices=[1, 2, 4, 8, 16, 32], default=8,
                        help="Microstep mode (default: 8 = 1/8 step)")
    parser.add_argument("--sweep", action="store_true", help="Run sweep test (back and forth)")
    parser.add_argument("--cycles", type=int, default=2, help="Sweep cycles (default: 2)")
    args = parser.parse_args()

    try:
        setup(args.microstep)
        if args.sweep:
            sweep(args.cycles, args.degrees, args.microstep, args.rpm)
        else:
            rotate(args.degrees, args.dir, args.microstep, args.rpm)
    except KeyboardInterrupt:
        print("\n[Stepper] Interrupted.")
    finally:
        GPIO.cleanup()
        print("[Stepper] GPIO cleaned up.")


if __name__ == "__main__":
    main()
