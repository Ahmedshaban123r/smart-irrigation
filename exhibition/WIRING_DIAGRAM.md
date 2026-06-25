# Wiring Diagram — Smart Irrigation Exhibition

> All pin numbers: BCM for Pi GPIO, physical pin in parentheses.
> All resistor values assume 3.3 V GPIO logic unless noted.

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MAINS                                                                      │
│    Outlet A ──► 12V/6A SMPS ──► LM2596 buck (5V) + stepper driver          │
│    Outlet B ──► Official Pi USB-C PSU (5V/3A) ──► Raspberry Pi             │
│    Outlet C ──► USB charger (5V/1A) ──► ESP32 USB port                     │
└─────────────────────────────────────────────────────────────────────────────┘

          ┌─────────────────┐          ┌─────────────────────┐
          │  ESP32          │  Wi-Fi   │  Firebase RTDB      │
          │  NodeMCU-32     │◄────────►│  /sensors/          │
          │  v1.3           │          │  /commands/         │
          │                 │          │  /status/           │
          │  GPIO16 → Relay │          └──────────┬──────────┘
          └────────┬────────┘                     │ commands
                   │                              │
          ┌────────▼────────┐          ┌──────────▼──────────┐
          │  Sensors        │          │  Raspberry Pi       │
          │  - Soil ADC     │          │  pi_controller      │
          │  - DHT11        │          │  _exhibition.py     │
          │  - ACS712       │          └──────────┬──────────┘
          │  Actuator       │                     │ GPIO
          │  - Relay → Pump │          ┌──────────▼──────────┐
          └─────────────────┘          │  Actuators          │
                                       │  - A4988 → Stepper  │
                                       │  - 4× LED           │
                                       │  - Buzzer            │
                                       └─────────────────────┘
```

---

## A. ESP32 Sensor Node + Pump Relay

```
NodeMCU-32 v1.3 — top view (USB connector at bottom)

                    ┌──────────────┐
                EN  │              │  23 / GPIO23
                36  │              │  22 / GPIO22
                SVP │              │  1  / TXD
                SVN │              │  3  / RXD
  Soil ADC ► GPIO34 │   ESP32      │  21 / GPIO21
  ACS712  ► GPIO35  │   NodeMCU    │  19 / GPIO19
             GPIO32 │   32 v1.3    │  18 / GPIO18
             GPIO33 │              │  5  / GPIO5
             GPIO25 │              │  17 / GPIO17
             GPIO26 │              │  16 / GPIO16  ──► Relay SIG (PUMP)
             GPIO27 │              │  4  / GPIO4   ◄── DHT11 DATA
             GPIO14 │              │  2  / GPIO2
             GPIO12 │              │  15 / GPIO15
             GPIO13 │              │  GND
                GND │              │  VIN (5V) ──► Relay VCC + ACS712 VCC
                VIN │              │  3V3  ◄──── sensor VCC rail
                     └──────────────┘
```

### A1. Soil Moisture Sensor (capacitive)

```
Sensor VCC ──────────────── ESP32 3V3
Sensor GND ──────────────── ESP32 GND
Sensor AOUT ─────────────── ESP32 P34 (ADC1_CH6)
```

### A2. DHT11 Temperature/Humidity

```
DHT11 VCC  ──────────────── ESP32 3V3
DHT11 GND  ──────────────── ESP32 GND
DHT11 DATA ──────────────── ESP32 P4 (GPIO4)
                             (module has built-in pull-up — no external resistor)
```

### A3. ACS712-05B Current Sensor

```
ACS712 VCC ──────────────── 5V (from USB charger or ESP32 VIN)
ACS712 GND ──────────────── GND (common)
ACS712 IP+ ──────────────── Pump + wire (in series with pump)
ACS712 IP- ──────────────── Pump relay output

                Voltage divider (scales 0–5V out to 0–3V for ESP32 ADC):

ACS712 OUT ──┬── 2kΩ ──── ESP32 P35
             │
            3kΩ
             │
            GND

  Divider ratio: 3k/(2k+3k) = 0.6   →   5V × 0.6 = 3.0V max (safe for P35)
```

> **CURRENT_ENABLED** flag in firmware: set `false` until divider is wired.
> P35 is input-only, no internal pull-up — safe to leave floating when disabled.

### A4. HC-SR04 Ultrasonic (DISABLED — kept for future)

```
When re-enabled (SONAR_ENABLED true):

HC-SR04 VCC  ─── 5V
HC-SR04 GND  ─── GND
HC-SR04 TRIG ─── level shifter (3.3V→5V) ─── ESP32 P26
HC-SR04 ECHO ─── 1kΩ series ─────────────── ESP32 P25
               (5V echo reduced to ~2.7V — just safe for ADC input)
```

---

## B. Raspberry Pi (AI + Stepper + Indicators)

### Pi GPIO Pinout Reference (used pins only)

```
Pi physical pin layout (GPIO header, pins 1–40):

 [3V3]  1 ●────────► LED VCC rail (if needed)
 [5V]   2 ●────────► Buzzer (+), Blue LED anode (via 220Ω)
 [GND]  6 ●────────► Signal ground (star point)

GPIO27  13 ●─── 1kΩ ─► NPN base (blue LED transistor)
GPIO22  15 ●─── 1kΩ ─► NPN base (buzzer transistor)
 [GND] 25 ●────────► DRV8825 GND

GPIO5   29 ●─── 220Ω ─► LED Green (+)
GPIO6   31 ●─── 220Ω ─► LED Red (+)
GPIO13  33 ●─── 220Ω ─► LED Yellow (+)

GPIO20  38 ●────────► A4988 STEP
GPIO21  40 ●────────► A4988 DIR
```

> **GPIO17 (Pin 11) is now FREE** — pump relay moved to ESP32 GPIO16.

### B1. Pump Relay (NOW ON ESP32 — see section A)

```
ESP32 GPIO16 ────────────────── Relay module SIG/IN
ESP32 VIN (5V) ─────────────── Relay module VCC
ESP32 GND ──────────────────── Relay module GND

Relay COM ──────────────────── LM2596 Buck OUT+ (5V)
Relay NO  ──────────────────── ACS712 IP+ (then to pump)
ACS712 IP- ─────────────────── Pump (+)
Pump -    ──────────────────── Buck OUT- / star GND

1N4007 across pump: cathode ── pump +, anode ── pump -
```

> Pi controls pump timing via Firebase (`commands/pump_relay: true/false`).
> ESP32 polls every 500ms and toggles GPIO16 (active LOW relay).

### B2. DRV8825 Stepper Driver

```
                      ┌────────────────┐
Pi GPIO20 (pin 38) ──►│ STEP           │
Pi GPIO21 (pin 40) ──►│ DIR            │
                      │ ENABLE (NC)    │  ← internally pulled LOW = always enabled
                      │ FLT (NC)       │  ← open-drain fault output (optional)
Pi GND  (pin 25)   ──►│ GND  DRV8825  │
12V SMPS +  ──────────►│ VMOT  module  │──── + leg of 100µF cap
12V SMPS GND ─────────►│ GND           │──── - leg of 100µF cap (to SMPS GND)
                      │ RESET ──┐      │
                      │ SLEEP ──┘ wire │  ← jumpered together
                      │ 1A/1B ────────┼───► Stepper coil A (2 wires)
                      │ 2A/2B ────────┼───► Stepper coil B (2 wires)
                      │ MS1/2/3 (NC)  │  ← defaults to full-step
                      └────────────────┘

No VDD pin — DRV8825 has internal regulator, logic powered from VMOT.
Current limit: Vref = I_limit / 2
  Start at 0.2V, increase until smooth. Max 0.4V for exhibition.
  Measure Vref at the small pot with multimeter.
  Set BEFORE connecting motor.
```

### B3. Buzzer (active, 5V, via NPN)

```
Pi GPIO22 (pin 15) ──── 1kΩ ──── 2N2222 Base
                                  2N2222 Emitter ──── GND
                                  2N2222 Collector ── Buzzer − terminal
Pi 5V (pin 2) or Buck OUT+ ──── Buzzer + terminal

Active buzzer: buzzes when + is HIGH and − is LOW.
GPIO HIGH → transistor on → buzzer − goes LOW → buzzer sounds.
```

### B4. LEDs

```
3.3V direct drive:
Pi GPIO5  (pin 29) ── 220Ω ── LED Green  (+) ── GND   [System NORMAL]
Pi GPIO6  (pin 31) ── 220Ω ── LED Red    (+) ── GND   [FAULT / E-stop]
Pi GPIO13 (pin 33) ── 220Ω ── LED Yellow (+) ── GND   [AUTO mode]

5V NPN drive (blue Vf too high for 3.3V GPIO):
Pi GPIO27 (pin 13) ── 1kΩ ── 2N2222 Base
                               2N2222 Emitter ── GND
                               2N2222 Collector ── LED Blue cathode
5V (Pi pin 2 or Buck OUT+) ── 220Ω ── LED Blue anode   [Pump ON]
```

---

## C. Star Ground

```
                        ┌──────────────────────────┐
                        │   SMPS GND terminal      │  ← STAR POINT
                        │   (negative − terminal)  │
                        └──┬───────┬───────┬───────┘
                           │       │       │
                    Pi GND │  Pump │DRV8825│
                    (pin 6)│   −   │  GND  │
                           │       │       │
                    Signal │  Power return currents
                    ground │  travel here — NOT through Pi

Pi GND ── joins at ONE wire to SMPS GND terminal.
Motor and pump current must NEVER flow through Pi GND wiring.
```

---

## D. Full Connection Checklist

Before power-on, verify each connection:

### ESP32 side
- [ ] Soil sensor VCC → 3V3, GND → GND, AOUT → P34
- [ ] DHT11 VCC → 3V3, GND → GND, DATA → P4
- [ ] ACS712 VCC → VIN (5V), GND → GND, IP+/IP− in series with pump wire
- [ ] ACS712 voltage divider: OUT → 10kΩ → P35, 20kΩ → GND
- [ ] Relay SIG → GPIO16, Relay VCC → VIN (5V), Relay GND → GND
- [ ] Relay COM → Buck OUT+ (5V), Relay NO → ACS712 IP+
- [ ] Pump (+) → ACS712 IP−, Pump (−) → Buck OUT− / star GND
- [ ] 1N4007 across pump terminals (cathode to +)
- [ ] ESP32 powered via own USB (not from Pi 3V3)

### Raspberry Pi side
- [ ] GPIO20 → DRV8825 STEP, GPIO21 → DIR
- [ ] DRV8825 ENABLE not connected (internally pulled low)
- [ ] DRV8825 RESET and SLEEP jumpered together
- [ ] DRV8825 FLT not connected
- [ ] DRV8825 GND → Pi GND (Pin 25) — no VDD needed (internal regulator)
- [ ] DRV8825 VMOT → 12V+, GND → SMPS GND
- [ ] 100µF cap across VMOT and GND (close to module)
- [ ] Stepper coils → DRV8825 1A/1B and 2A/2B outputs
- [ ] GPIO22 → 1kΩ → 2N2222 base, collector → Buzzer(−), Buzzer(+) → 5V
- [ ] GPIO5  → 220Ω → LED Green → GND
- [ ] GPIO6  → 220Ω → LED Red → GND
- [ ] GPIO13 → 220Ω → LED Yellow → GND
- [ ] GPIO27 → 1kΩ → 2N2222 base, collector → Blue LED cathode, anode → 5V via 220Ω
- [ ] Pi GND (pin 6) → one wire to SMPS GND terminal

### Power
- [ ] 12V SMPS output voltage verified (multimeter): 11.8–12.2 V
- [ ] Pi USB-C from official PSU only
- [ ] ESP32 USB from separate charger

---

## E. Power-Up Sequence

1. All wiring verified and connections tight
2. Pi USB-C connected — wait for boot (Pi green LED steady)
3. Confirm `sudo journalctl -u irrigation-exhibition -f` shows:
   - `GPIO ready`
   - `Firebase ready — status seeded`
   - `System ready — entering poll loop`
   - Green LED on Pi board lights up
4. Power SMPS (12V rail) — stepper driver and relay now powered
5. Test pump: app → MANUAL → pump ON → hear relay click
6. Test stepper: app → gantry move → hear/feel motor step
7. Connect ESP32 USB — verify sensor data in Firebase console

---

## F. Troubleshooting Quick Reference

| Symptom | Likely cause | Check |
|---|---|---|
| Relay clicks but pump doesn't run | Pump− not connected to SMPS GND | Star ground wiring |
| Stepper vibrates but doesn't move | Coil wires swapped or current limit too low | Vref (= I/2), coil pairing |
| Stepper gets hot, no movement | Current limit too high | Lower Vref |
| LEDs very dim | Series resistor too high or wrong LED colour Vf | Check resistor value |
| Blue LED off | Vf too high for 3.3V GPIO | Use NPN + 5V circuit |
| Buzzer always on | NPN base connected to 5V permanently | Check GPIO18 pin |
| Pi reboots when motor starts | Star ground missing, Pi GND carrying motor return | Check ground wiring |
| Soil always reads 0% | Sensor not connected or ESP32 not running | Check ESP32 serial |
| Firebase auth error | Key file wrong path or expired | Check FIREBASE_CRED |
