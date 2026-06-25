# Smart Irrigation Exhibition — Complete Pinout Reference

This document lists every pin connection for every component in the system, organized by power supplies, controllers, sensors, and actuators. Cross-reference with the master wiring plan for safety procedures and calibration steps.

---

## 1. Power Supplies

### LM2596 Buck Converter (12V → 5V)

| Pin | Connects To |
| :--- | :--- |
| IN+ | 12V supply (+) via barrel jack adapter |
| IN− | 12V supply (−) → star ground |
| OUT+ | Relay COM, pump circuit, buzzer (+) |
| OUT− | Pump (−) return, star ground |

Notes: Tune OUT to exactly 5.00V before connecting any load (see calibration guide). Place 1000 µF capacitor directly across OUT+/OUT−.

### DRV8825 Stepper Driver

| Pin | Connects To |
| :--- | :--- |
| VMOT | 12V supply (+), 100 µF cap across VMOT/GND |
| GND | Raspberry Pi Pin 25 (GND), star ground |
| 1A / 1B | Stepper motor coil 1 (24 AWG) |
| 2A / 2B | Stepper motor coil 2 (24 AWG) |
| STEP | Raspberry Pi GPIO20 (Pin 38) |
| DIR | Raspberry Pi GPIO21 (Pin 40) |
| ENABLE | Not connected (internally pulled low / enabled by default) |
| FLT | Not connected (open-drain fault output — goes LOW on overcurrent/thermal fault) |
| MS1 / MS2 / MS3 | Not connected (defaults to full-step mode) |
| RESET / SLEEP | Jumpered together (physical wire bridge required) |

Notes: DRV8825 has internal voltage regulator — logic powered from VMOT, no VDD pin. Calibrate Vref: `Vref = I_limit / 2`. Start at 0.2V, increase until smooth. Never connect/disconnect the motor while powered.

---

## 2. Controllers

### Raspberry Pi 4 (AI + stepper + indicators — NO pump relay)

| Pin | GPIO | Connects To |
| :--- | :--- | :--- |
| Pin 1 | 3.3V | Status LED anodes (via 220 Ω, shared rail) |
| Pin 2 | 5V | Buzzer (+), Blue LED anode (via 220 Ω) |
| Pin 6 | GND | Signal ground, star ground |
| Pin 13 | GPIO27 | Blue LED NPN transistor base (via 1 kΩ) |
| Pin 15 | GPIO22 | Buzzer NPN transistor base (via 1 kΩ) |
| Pin 25 | GND | DRV8825 GND, star ground |
| Pin 29 | GPIO5 | Green status LED (via 220 Ω) |
| Pin 31 | GPIO6 | Red status LED (via 220 Ω) |
| Pin 33 | GPIO13 | Yellow status LED (via 220 Ω) |
| Pin 38 | GPIO20 | A4988 STEP |
| Pin 40 | GPIO21 | A4988 DIR |

Notes: Pump relay moved to ESP32 GPIO16 — Pi sends pump commands via Firebase (`commands/pump_relay`). GPIO17 (Pin 11) is now free. Avoid GPIO2/3 (I2C) and GPIO14/15 (UART) — reserved for hardware interfaces.

### ESP32 NodeMCU (sensors + pump relay + Wi-Fi/Firebase)

| Pin | Connects To |
| :--- | :--- |
| VIN | ACS712 VCC, Relay module VCC (USB 5V passthrough), 100 µF cap to GND |
| 3V3 | Soil sensor VCC, DHT11 VCC, 10 µF cap to GND |
| GND | All sensor GNDs, relay GND, star ground |
| GPIO34 (ADC1_CH6) | Soil moisture sensor AOUT (input-only ADC pin) |
| GPIO35 (ADC1_CH7) | ACS712 AOUT, via 10 kΩ / 20 kΩ voltage divider |
| GPIO4 | DHT11 DATA, with 4.7 kΩ pull-up to 3V3 |
| GPIO16 | Relay SIG/IN — pump switch control (active LOW) |

Notes: Use ADC1 pins only (GPIO32–39) — ADC2 pins conflict with active Wi-Fi and return invalid readings. ESP32 pushes sensor data to Firebase and polls `commands/pump_relay` to control pump. Pi orchestrates pump timing via Firebase, no direct UART link between the two boards.

---

## 3. Sensors (all wired to ESP32)

### Capacitive Soil Moisture Sensor v1.2

| Pin | Connects To |
| :--- | :--- |
| VCC | ESP32 3V3 |
| GND | ESP32 GND |
| AOUT | ESP32 GPIO34, with 100 nF cap to GND at the sensor |

### DHT11 Temperature & Humidity Sensor

| Pin | Connects To |
| :--- | :--- |
| VCC | ESP32 3V3, with 100 nF cap to GND at the sensor |
| GND | ESP32 GND |
| DATA | ESP32 GPIO4, with 4.7 kΩ pull-up resistor to 3V3 |

### ACS712-05B Current Sensor

| Pin | Connects To |
| :--- | :--- |
| IP+ | Relay NO terminal (high-current side, in series with pump circuit) |
| IP− | Pump (+) lead (high-current side, in series with pump circuit) |
| VCC | ESP32 VIN (5V) |
| GND | ESP32 GND |
| OUT | 10 kΩ resistor to junction, junction to ESP32 GPIO35, 20 kΩ resistor from junction to GND |

Notes: IP+/IP− carry actual pump load current — wired in series with the pump's power path, not just powered alongside it. The voltage divider on OUT is mandatory; AOUT can reach 4.5V which exceeds the ESP32's 3.3V ADC limit.

---

## 4. Actuators & Indicators (all wired to Pi / buck 5V rail)

### 5V Single-Channel Relay Module (on ESP32)

| Pin | Connects To |
| :--- | :--- |
| VCC | ESP32 VIN (5V from USB) |
| GND | ESP32 GND |
| SIG / IN | ESP32 GPIO16 |
| COM | Buck converter OUT+ |
| NO | ACS712 IP+ (then to pump circuit) |

### Water Pump (3–6V DC)

| Pin | Connects To |
| :--- | :--- |
| (+) | ACS712 IP− (via relay NO and current sensor) |
| (−) | Buck converter OUT−, star ground |

Notes: 1N4007 flyback diode across pump terminals — cathode (stripe) to (+), anode to (−).

### Active Piezo Buzzer (5V)

| Pin | Connects To |
| :--- | :--- |
| (+) | Pi 5V (Pin 2) or Buck converter OUT+ |
| (−) | NPN transistor collector |
| — | NPN emitter → star ground |
| — | NPN base ← Raspberry Pi GPIO22 (Pin 15), via 1 kΩ resistor |

### Blue Indicator LED (5V)

| Pin | Connects To |
| :--- | :--- |
| Anode | 5V supply, via 220 Ω resistor |
| Cathode | NPN transistor collector |
| — | NPN emitter → star ground |
| — | NPN base ← Raspberry Pi GPIO27 (Pin 13), via 1 kΩ resistor |

Notes: Driven via transistor (not direct GPIO) because blue LED forward voltage exceeds 3.3V GPIO output.

### Green / Red / Yellow Status LEDs (3.3V, direct GPIO drive)

| LED | Pin | Connects To |
| :--- | :--- | :--- |
| Green | Anode | Raspberry Pi GPIO5 (Pin 29), via 220 Ω resistor |
| Red | Anode | Raspberry Pi GPIO6 (Pin 31), via 220 Ω resistor |
| Yellow | Anode | Raspberry Pi GPIO13 (Pin 33), via 220 Ω resistor |
| All three | Cathode | Star ground |

### Pi Camera Module (CSI)

| Connection | Details |
| :--- | :--- |
| Ribbon cable | Raspberry Pi CSI camera port (lift tab, insert ribbon, close tab) |

Notes: Not a GPIO connection — uses dedicated camera serial interface. Used by AI daemon for plant disease inference via picamera2 library.

### NEMA 17 Stepper Motor

| Pin | Connects To |
| :--- | :--- |
| Coil A (2 wires) | A4988 1A / 1B |
| Coil B (2 wires) | A4988 2A / 2B |

Notes: Driven entirely through the A4988; no direct connection to Pi or ESP32. Confirm coil pairing with a multimeter (continuity between the two wires of each coil) before wiring, since coil order varies by motor.

---

## 5. Capacitor & Resistor Summary

| Type | Value | Location |
| :--- | :--- | :--- |
| Electrolytic | 100 µF (≥25V) | DRV8825 VMOT to GND |
| Electrolytic | 1000 µF (≥10V) | Buck converter OUT+ to OUT− |
| Electrolytic | 100 µF (≥10V) | ESP32 VIN to GND |
| Electrolytic | 10 µF (≥10V) | ESP32 3V3 to GND |
| Ceramic | 100 nF | ESP32 3V3 to GND |
| Ceramic | 100 nF | DHT11 VCC to GND |
| Ceramic | 100 nF | Soil sensor AOUT to GND |
| Ceramic | 100 nF | DRV8825 VMOT decoupling (optional, close to module) |
| Resistor | 220 Ω (×4) | Green, Red, Yellow, Blue LED current limiting |
| Resistor | 1 kΩ (×3) | NPN base: buzzer, blue LED, relay (if relay needs a transistor stage) |
| Resistor | 4.7 kΩ | DHT11 DATA pull-up |
| Resistor | 10 kΩ | ACS712 voltage divider, upper leg |
| Resistor | 20 kΩ | ACS712 voltage divider, lower leg |
| Diode | 1N4007 (×2) | Flyback: pump terminals, relay coil |

Note: Fan-related parts (1× 1 kΩ, 1× 1N4007, 1× NPN transistor) have been removed since the fan is no longer used in this build.

---

## 6. Star Ground Reference

All ground returns must tie to a single physical row (20 AWG black wire):

- 12V supply (−)
- Buck converter IN− and OUT−
- DRV8825 GND
- Raspberry Pi Pin 6 and Pin 25 (GND)
- ESP32 GND
- All NPN transistor emitters
- All sensor GNDs
- All LED cathodes
