# Power Analysis — Smart Irrigation Exhibition Build

> Purpose: size every supply rail, confirm no component is under/over-driven,
> select wire gauge and fuses, enforce star-ground discipline.
> Update any row marked ⬜ once real measurements are taken.

---

## 1. Component Inventory

### 1a. 12 V Rail (SMPS)

| Component | Voltage | Current (typical) | Current (peak) | Power (typ) | Notes |
|---|---|---|---|---|---|
| DC pump (water) | 12 V | 1.0 A | 2.5 A | 12 W | ⬜ Read pump label — update current |
| Stepper motor via DRV8825 | 12 V | 0.8 A/phase × 2 = 1.6 A | 1.7 A/phase × 2 = 3.4 A | 19 W | DRV8825 current-limit: Vref = I_limit / 2 — set to ≤ 0.4V initially |
| **12 V rail total** | | **2.6 A typ** | **5.9 A peak** | **31 W** | |

**SMPS selection:** 12 V / 5 A brick minimum. Recommend **12 V / 6 A** for headroom.
Peak is only momentary (stepper + pump simultaneously at startup). Sustained is ~2.6 A.

> ⚠️ If pump current (step 3.3) reads > 2 A sustained, upgrade to 12 V / 8 A.

---

### 1b. 5 V Rail (Pi USB-C PSU)

| Component | Voltage | Current (typical) | Current (peak) | Power (typ) | Notes |
|---|---|---|---|---|---|
| Raspberry Pi 4 (compute) | 5 V | 600 mA | 1 500 mA | 3.0 W | Peak during boot/heavy load |
| Active buzzer | 5 V | 30 mA | 30 mA | 150 mW | Via NPN transistor from Pi 5V pin |
| ACS712-05B (sensor supply) | 5 V | 10 mA | 10 mA | 50 mW | Powers ACS712; signal goes to ESP32 via divider |
| **5 V rail total** | | **640 mA typ** | **1 540 mA peak** | **3.2 W** | |

**PSU selection:** Official Raspberry Pi USB-C PSU (5 V / 3 A).
Max draw is 1.69 A — well within 3 A rating. Use only the official PSU; cheap ones droop under load causing Pi undervoltage resets.

> The buzzer and fan are powered from Pi 5V pins (physical pins 2/4), not GPIO.
> GPIO only drives the NPN base via 1 kΩ resistor (~3.3 mA per signal line — safe).

---

### 1c. 3.3 V Rail (Pi onboard regulator)

| Component | Voltage | Current (typical) | Notes |
|---|---|---|---|
| ESP32 (Wi-Fi active) | 3.3 V | 80 mA | Peak during TX burst: ~240 mA — power ESP32 from its own USB, not Pi 3V3 |
| Capacitive soil sensor | 3.3 V | 5 mA | |
| DHT11 module | 3.3 V | 1 mA | |
| LED Green (GPIO5 + 220 Ω) | 3.3 V | 5 mA | (3.3 − 2.2) / 220 = 5 mA |
| LED Red (GPIO6 + 220 Ω) | 3.3 V | 6 mA | (3.3 − 2.0) / 220 = 6 mA |
| LED Yellow (GPIO13 + 220 Ω) | 3.3 V | 5 mA | (3.3 − 2.1) / 220 = 5 mA |
| LED Blue (GPIO27 + NPN + 5V) | 5.0 V | 7 mA | Via NPN transistor, 220 Ω from 5V rail |
| **3.3 V rail total (excl. ESP32)** | | **22 mA typ** | Pi onboard reg rated 500 mA — very comfortable |

> **ESP32 power recommendation:** Power ESP32 from its own USB port (separate 5V phone charger
> or the SMPS via a USB-A port). Do NOT draw ESP32 from Pi 3.3V — Wi-Fi TX spikes (240 mA)
> will brown-out Pi's onboard regulator and crash the Pi.

---

## 2. Rail Summary

| Rail | Source | Total Draw (typ) | Total Draw (peak) | Supply Rating | Headroom |
|---|---|---|---|---|---|
| 12 V | SMPS brick | 2.6 A | 5.9 A | 6 A | 0.1 A (upgrade if pump > 2 A) |
| 5 V | Pi official USB-C PSU | 0.64 A | 1.54 A | 3 A | 1.46 A |
| 3.3 V | Pi onboard reg | 22 mA | 22 mA | 500 mA | 478 mA |
| 3.3 V (ESP32) | ESP32 USB-C (separate) | 80 mA | 240 mA | 1 A USB charger | 760 mA |

---

## 3. Protection & Safety

### 3a. Fuses

| Location | Fuse rating | Protects |
|---|---|---|
| 12 V SMPS output line | 6 A automotive blade | Pump wire + stepper wire combined |
| Pump branch (after relay) | 3 A | Pump only (replace with measured pump Imax + 20%) |

### 3b. Flyback Diodes

| Device | Diode | Orientation |
|---|---|---|
| DC pump | 1N4007 | Cathode to + terminal, anode to − terminal |
| Stepper motor | DRV8825 has internal diodes | No external diode needed |
| Relay coil | Most relay modules have built-in diode | Verify; add 1N4007 if not |

### 3c. Bulk Capacitors

| Location | Value | Purpose |
|---|---|---|
| 12 V rail, near DRV8825 VMOT pin | 100 µF electrolytic (≥ 16 V) | Absorb stepper back-EMF spikes |
| 12 V rail, near pump relay output | 470–1000 µF electrolytic | Absorb pump inrush / back-EMF |

### 3d. Current Limiting Resistors (GPIO signals)

| Signal | Series Resistor | Limits |
|---|---|---|
| NPN base — buzzer (GPIO22) | 1 kΩ | GPIO current to 3.3 mA |
| NPN base — blue LED (GPIO27) | 1 kΩ | GPIO current to 3.3 mA |
| LED Green/Red/Yellow | 220 Ω | LED current to ~5–6 mA |
| LED Blue | 220 Ω (5V rail + NPN) | LED current to ~7 mA at 5V |

---

## 4. Star Ground Diagram

```
                    ┌──────────────┐
  Pi GND ──────────┤              ├──── SMPS GND terminal (star point)
  ESP32 GND ───────┤  Star point  │
  Sensor GNDs ─────┤  (SMPS −)   ├──── Pump − terminal
  NPN emitters ────┤              ├──── DRV8825 GND
                    └──────────────┘
```

**Rule:** Motor / pump return current must travel directly back to SMPS GND.
It must NEVER flow through Pi GND wiring — noise will cause spurious GPIO reads and resets.

---

## 5. Wire Gauge Guide

| Circuit | Current | Minimum wire gauge | Recommendation |
|---|---|---|---|
| 12 V pump feed | up to 2.5 A | 24 AWG | **22 AWG** (red/black pair) |
| 12 V stepper (VMOT) | up to 1.7 A/phase | 26 AWG | **24 AWG** |
| 5 V Pi USB-C | 1.7 A max | Use official cable | Official Pi USB-C cable only |
| GPIO signal lines | < 10 mA | 28 AWG | Standard jumper wires fine |
| GND returns (star) | up to 5 A peak | 20 AWG | **20 AWG** thick black wire to SMPS |

---

## 6. Power-Up Sequence

1. **Verify** all wiring before powering anything
2. **SMPS OFF** — connect 12 V SMPS to mains but leave switched OFF
3. **Power ESP32** via USB (phone charger) → confirm blue onboard LED + serial output
4. **Power Pi** via official USB-C → wait for boot (green LED on Pi stops blinking = ready)
5. **Confirm Pi controller running** — check `journalctl -u irrigation-exhibition` shows [INIT] messages, green status LED on
6. **Power SMPS ON** — 12 V rail live, relay and stepper driver now powered
7. **Test pump via app** — brief manual ON, confirm relay click
8. **Test stepper** — small move via app, confirm motion

**Power-down sequence (reverse):**
1. SMPS OFF
2. Pi shutdown: `sudo shutdown now`
3. Disconnect Pi USB-C after Pi activity LED stops

---

## 7. Measurements To Take

| Measurement | When | Notes |
|---|---|---|
| Pump stall current | ⬜ On bench with multimeter in series | Determines relay rating + fuse + SMPS sizing |
| Pump no-load current | ⬜ On bench, pump running in water | Typical operating current |
| DRV8825 Vref | ⬜ Set before stepper test | Vref = I_limit / 2 — start at 0.2V |
| Stepper phase current | ⬜ Scope/meter on coil while moving | Confirm DRV8825 current limit working |
| Pi 5V rail voltage under load | ⬜ Multimeter at GPIO pin 2 while system running | Should stay > 4.75 V |
| Pi 3.3V rail voltage | ⬜ GPIO pin 1 | Should stay > 3.25 V |
| SMPS output voltage | ⬜ Under full load (pump + stepper simultaneously) | Should stay 11.8–12.2 V |

---

## 8. Exhibition Power Budget Summary

```
┌─────────────────────────────────────────────────────────────┐
│  WALL POWER                                                 │
│  2× mains outlets needed                                    │
│    ① 12V/6A SMPS  — pump + stepper       ≈ 31 W typ        │
│    ② Pi USB-C PSU — Pi + buzzer          ≈  3 W typ        │
│    ③ USB charger  — ESP32               ≈  1 W             │
│                              TOTAL       ≈ 35 W typ         │
│                              TOTAL       ≈ 71 W peak (brief)│
└─────────────────────────────────────────────────────────────┘
```

Two mains outlets (or one power strip). Peak 72 W is well within any standard outlet.
