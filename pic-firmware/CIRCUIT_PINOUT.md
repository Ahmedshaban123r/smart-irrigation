# Circuit & Pinout Reference
## PIC16F877A @ 8 MHz — Smart Irrigation Sensor Test

---

## MCU Overview

| Property | Value |
|---|---|
| MCU | PIC16F877A |
| Clock | 8 MHz external crystal (HS mode) |
| Supply | 5 V |
| Compiler | MPLAB XC8 |

---

## Complete Pin Assignment

| PIC Pin | Port/Pin | Connected To | Direction |
|---|---|---|---|
| 2 | RA0 / AN0 | Soil moisture sensor AO | Input (analog) |
| 3 | RA1 / AN1 | LM35 OUT *(unused in test)* | Input (analog) |
| 4 | RA2 / AN2 | ACS712 OUT | Input (analog) |
| 13 | OSC1 | 8 MHz crystal | — |
| 14 | OSC2 | 8 MHz crystal | — |
| 33 | RB0 | DHT11 DATA (+ 4.7 kΩ pull-up to VCC) | Bidirectional |
| 19 | RD0 | Relay module IN | Output |
| 20 | RD1 | Buzzer + | Output |
| 21 | RD2 | LCD RS | Output |
| 22 | RD3 | LCD E (Enable) | Output |
| 23 | RD4 | LCD D4 | Output |
| 24 | RD5 | LCD D5 | Output |
| 25 | RD6 | LCD D6 | Output |
| 26 | RD7 | LCD D7 | Output |
| 18 | RC1 | LED (Red) anode | Output |
| 11, 32 | VDD | +5 V | Power |
| 12, 31 | VSS | GND | Power |

> LCD RW pin → tied directly to GND on the LCD module (always write mode, not connected to PIC).

---

## LCD — HD44780 16x2 (4-bit mode)

```
LCD Module          PIC16F877A
─────────           ──────────
VSS  (pin 1)  ───── GND
VDD  (pin 2)  ───── +5V
VO   (pin 3)  ───── Potentiometer wiper (contrast adjust, 10 kΩ pot between VCC and GND)
RS   (pin 4)  ───── RD2
RW   (pin 5)  ───── GND  (always write)
E    (pin 6)  ───── RD3
D0-D3 (pins 7-10) ─ NOT CONNECTED (4-bit mode)
D4   (pin 11) ───── RD4
D5   (pin 12) ───── RD5
D6   (pin 13) ───── RD6
D7   (pin 14) ───── RD7
A    (pin 15) ───── +5V (backlight anode, add 33 Ω series resistor)
K    (pin 16) ───── GND (backlight cathode)
```

---

## DHT11 — Temperature & Humidity Sensor

```
DHT11               PIC16F877A
─────               ──────────
VCC  (pin 1)  ───── +5V
DATA (pin 2)  ───── RB0
               └─── 4.7 kΩ pull-up resistor to +5V  ← REQUIRED
NC   (pin 3)  ───── (not connected)
GND  (pin 4)  ───── GND
```

> Without the 4.7 kΩ pull-up on DATA, the line floats and reads will fail.

---

## Soil Moisture Sensor (resistive/capacitive module)

```
Sensor Module       PIC16F877A
─────────────       ──────────
VCC           ───── +5V
GND           ───── GND
AO (analog)   ───── RA0 / AN0
DO (digital)  ───── NOT CONNECTED (unused)
```

**Calibration values (in firmware):**

| State | ADC Reading |
|---|---|
| Dry (air) | 820 |
| Wet (submerged) | 350 |

Adjust `SOIL_DRY_ADC` and `SOIL_WET_ADC` in `HAL/Soil/Soil_config.h` to match your sensor.

---

## ACS712-05B — Current Sensor (±5 A)

```
ACS712 Module       PIC16F877A / Load
──────────────      ─────────────────
VCC           ───── +5V
GND           ───── GND
OUT           ───── RA2 / AN2
IP+  }
IP-  }        ───── In series with the load being measured
```

**Firmware constants (`HAL/Current/Current_config.h`):**

| Parameter | Value |
|---|---|
| Supply | 5000 mV |
| Zero-current output | 2500 mV (VCC/2) |
| Sensitivity | 66 mV/A (05B variant) |
| ADC resolution | 1024 counts (10-bit) |

> For ACS712-20A (±20 A): change `CURRENT_SENS_MV_A` to `100`.
> For ACS712-30A (±30 A): change to `66` → `133`.

---

## Buzzer

```
Buzzer              PIC16F877A
──────              ──────────
+  (or S)     ───── RD1
−  (or −)     ───── GND
```

Use an NPN transistor (e.g., 2N2222) if buzzer current > 25 mA:
```
RD1 ──[1 kΩ]── Base
              Collector ── Buzzer+ ── +5V
              Emitter   ── GND
```

---

## Relay Module

```
Relay Module        PIC16F877A
────────────        ──────────
VCC           ───── +5V
GND           ───── GND
IN            ───── RD0
```

---

## LED (Red)

```
RC1 ──[330 Ω]── LED anode ── LED cathode ── GND
```

---

## Crystal Oscillator

```
8 MHz crystal
  Pin 1 ───── OSC1 (PIC pin 13) ──┬── 22 pF cap ── GND
  Pin 2 ───── OSC2 (PIC pin 14) ──┴── 22 pF cap ── GND
```

---

## Power Supply Decoupling

Place a **100 nF ceramic capacitor** between VDD and VSS as close to the PIC as possible (pins 11/12 and 32/31). Optionally add a **10 µF electrolytic** in parallel.

---

## ADC Channel Summary

| Channel | Pin | Sensor | Samples |
|---|---|---|---|
| AN0 | RA0 | Soil Moisture | 4 |
| AN1 | RA1 | LM35 *(unused)* | — |
| AN2 | RA2 | ACS712 Current | 8 |

ADC clock: Fosc/32 → Tad = 4 µs @ 8 MHz. VREF = VDD/VSS (0–5 V range).

---

## Display Page Cycle

LCD cycles every 2 seconds:

| Page | Row 1 | Row 2 |
|---|---|---|
| 0 | `Hum : XX %` | `Temp: XX C` |
| 1 | `Soil: XX %` | `Curr: XXXX mA` |

If DHT11 read fails, Page 0 shows `DHT11 Error:` + error code:

| Code | Meaning |
|---|---|
| 2 | No sensor response (check wiring / pull-up) |
| 3 | Bit-read timeout (timing issue) |
| 4 | Checksum mismatch (noisy line) |
