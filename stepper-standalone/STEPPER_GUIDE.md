# Stepper Motor (DRV8825) — Wiring & Usage

## Wiring

### DRV8825 → Raspberry Pi

| DRV8825 Pin | Connect To         | Notes                              |
|-------------|--------------------|------------------------------------|
| **STEP**    | Pi GPIO 20 (Pin 38)| Pulse = one microstep              |
| **DIR**     | Pi GPIO 21 (Pin 40)| HIGH = CW, LOW = CCW               |
| **M0**      | Pi GPIO 24 (Pin 18)| Microstep config                   |
| **M1**      | Pi GPIO 23 (Pin 16)| Microstep config                   |
| **M2**      | Pi GPIO 18 (Pin 12)| Microstep config                   |
| **GND**     | Pi GND (Pin 6/14/20/etc.) | Common ground             |
| **ENABLE**  | Leave NC or tie LOW | LOW = enabled (has internal pull-down) |

### DRV8825 → Power

| DRV8825 Pin   | Connect To         | Notes                              |
|---------------|--------------------|------------------------------------|
| **VMOT**      | 12V power supply + | Motor power (8.2V–45V)            |
| **GND** (motor side) | 12V supply GND | Same ground as Pi              |
| **100µF cap** | Across VMOT & GND  | **REQUIRED** — protects DRV8825   |
| **RESET**     | Jumper to **SLEEP** | Both HIGH = board active          |
| **SLEEP**     | Jumper to **RESET** | Both HIGH = board active          |
| **FLT**       | Leave NC            | Open-drain fault output           |

### DRV8825 → Stepper Motor (NEMA 17)

| DRV8825 Pin | Motor Wire  |
|-------------|-------------|
| **A1**      | Coil A wire 1 (typically Black)  |
| **A2**      | Coil A wire 2 (typically Green)  |
| **B1**      | Coil B wire 1 (typically Red)    |
| **B2**      | Coil B wire 2 (typically Blue)   |

> **Find coil pairs:** Touch two wires together and try to spin the motor shaft by hand. If it resists, those two are a coil pair.

### Current Limit (Vref)

**Before powering motor:** Adjust the Vref potentiometer on DRV8825.

```
Vref = I_limit / 2
```

- Start at **0.2V** (= 0.4A limit) — safe starting point
- Max for typical NEMA 17: **0.4V** (= 0.8A)
- Measure between potentiometer center and GND with multimeter

### Microstep Truth Table

| M0 | M1 | M2 | Mode      | Steps/Rev |
|----|----|----|-----------|-----------|
| 0  | 0  | 0  | Full step | 200       |
| 1  | 0  | 0  | 1/2 step  | 400       |
| 0  | 1  | 0  | 1/4 step  | 800       |
| 1  | 1  | 0  | **1/8 step** | **1600** |
| 0  | 0  | 1  | 1/16 step | 3200      |
| 1  | 0  | 1  | 1/32 step | 6400      |

**Default in script: 1/8 step** — good balance of smooth motion and speed.

---

## Copy Script to Pi

```bash
scp stepper_test.py robox@robox.local:/home/robox/Final_Project/
```

Or if mDNS not working, use Pi's IP:

```bash
scp stepper_test.py robox@<PI_IP>:/home/robox/Final_Project/
```

---

## Usage (on Pi)

### Basic rotation (90° clockwise, 1/8 microstep, 10 RPM)

```bash
python3 stepper_test.py
```

### Custom rotation

```bash
# 180° counterclockwise at 15 RPM
python3 stepper_test.py --degrees 180 --dir ccw --rpm 15

# Full revolution, smooth 1/16 microstepping
python3 stepper_test.py --degrees 360 --microstep 16 --rpm 5

# Quick test with 1/4 step
python3 stepper_test.py --degrees 45 --microstep 4 --rpm 20
```

### Sweep test (back and forth)

```bash
# Default: 2 sweeps of 90°
python3 stepper_test.py --sweep

# 5 sweeps of 180° at 1/32 microstepping (ultra smooth)
python3 stepper_test.py --sweep --cycles 5 --degrees 180 --microstep 32 --rpm 3
```

---

## Debugging: Is it the Pi or the DRV8825?

Follow this order:

### Step 1 — Test Pi GPIO (no motor needed)

Hook LED + 220Ω resistor from GPIO 20 to GND. Copy and run:

```bash
scp gpio_test.py robox@robox.local:/home/robox/Final_Project/
ssh robox@robox.local
python3 /home/robox/Final_Project/gpio_test.py
```

- **LED blinks** → Pi GPIOs fine. Problem is DRV8825/wiring/motor. Go to Step 2.
- **No blink** → Pi GPIO broken. Check `sudo raspi-gpio get 20`, try different pin, check if RPi.GPIO installed.

### Step 2 — Test DRV8825 + Motor via ESP32 (bypass Pi)

Flash `esp32_stepper_test.ino` to ESP32 via Arduino IDE. Rewire DRV8825 to ESP32:

| DRV8825 Pin | ESP32 GPIO |
|-------------|------------|
| STEP        | 16         |
| DIR         | 17         |
| M0          | 18         |
| M1          | 19         |
| M2          | 21         |
| GND         | GND        |

Keep VMOT on 12V, RESET↔SLEEP jumpered, 100µF cap in place.

**Flash (Arduino IDE):**
- Board: ESP32 Dev Module
- Port: COM12 (or whatever shows)
- Upload

**Use Serial Monitor (115200 baud):**

| Key | Action            |
|-----|-------------------|
| `f` | Forward 90° CW    |
| `b` | Backward 90° CCW  |
| `r` | Full revolution    |
| `s` | Sweep test (3x)   |
| `1` | Full step mode     |
| `2` | 1/2 step mode      |
| `3` | 1/4 step mode      |
| `4` | 1/8 step mode      |
| `5` | 1/16 step mode     |

**Results:**
- **Motor spins on ESP32** → DRV8825 + motor fine. Problem is Pi side.
- **Still nothing** → DRV8825 dead, wiring wrong, or motor bad. Check:
  1. RESET↔SLEEP jumper exists?
  2. 12V on VMOT? (measure with multimeter)
  3. 100µF cap in place?
  4. Vref reads 0.2V–0.4V?
  5. Motor coil pairs correct? (resistance test: ~1-4Ω between coil pair)

---

## Troubleshooting

| Problem                  | Fix                                                  |
|--------------------------|------------------------------------------------------|
| Motor not moving at all  | Check RESET↔SLEEP jumper. Check 12V on VMOT.        |
| Motor vibrating, not spinning | Coil wires swapped. Swap A1↔A2 or B1↔B2.       |
| Motor very hot           | Lower Vref. Start 0.2V, go up only if needed.        |
| Motor skipping steps     | Raise Vref slightly. Or lower RPM.                    |
| Jittery motion           | Use higher microstep (16 or 32). Lower RPM.          |
| Script error: "GPIO"     | Run with `sudo` or add user to gpio group.            |
