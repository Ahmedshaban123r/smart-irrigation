# Exhibition Build — Progress Log

> Smart Irrigation System — CIE-406, Zewail City of Science and Technology
> This file tracks every decision and step of the exhibition rework.
> Update it as work progresses.

---

## Goal

Rework the graded PIC + ESP8266 + Pi system into a reliable exhibition demo.
Original system had reliability issues. Exhibition priority: **it works on the table**.

**Graded artefacts are untouched** — `pic-firmware/`, `esp-firmware/`, `default.hex`.
All exhibition work lives in `esp32-firmware/` and `exhibition/`.

---

## Architecture Decision — Topology A

| Layer | Hardware | Role |
|---|---|---|
| Sensor node | ESP32 NodeMCU-32 v1.3 | Reads sensors → pushes to Firebase every 2 s |
| Control node | Raspberry Pi | Reads Firebase → safety checks → drives all actuators via GPIO |
| Cloud | Firebase RTDB | Unchanged schema — same paths as graded build |
| Mobile app | Flutter (unchanged) | Zero modifications needed |

---

## Hardware Confirmed

| Item | Details | Status |
|---|---|---|
| ESP32 board | NodeMCU-32 v1.3, ESP32-D0WDQ6 rev1.0, dual-core 240 MHz | ✅ Verified |
| MAC address | `40:22:d8:04:51:68` | ✅ |
| USB-UART chip | CH340 | ✅ COM12 |
| Wi-Fi | Built-in, confirmed | ✅ |

---

## Software Setup

| Step | Details | Status |
|---|---|---|
| Arduino IDE | `C:\Program Files\Arduino IDE\` | ✅ |
| ESP32 core | Espressif Systems esp32 **v2.0.17** | ✅ |
| Board selection | NodeMCU-32S / ESP32 Dev Module | ✅ |
| Port | COM12 | ✅ |
| DHT sensor library | Adafruit | ✅ |
| Adafruit Unified Sensor | Adafruit | ✅ |
| Firebase_ESP_Client | Mobizt | ✅ |

---

## ESP32 Sensor Node

File: `esp32-firmware/esp32_sensor_node/esp32_sensor_node.ino`

### Feature flags (top of .ino)

| Flag | Default | Enable when |
|---|---|---|
| `CURRENT_ENABLED` | `false` | ACS712 wired + voltage divider confirmed |
| `SONAR_ENABLED` | `false` | HC-SR04 wiring fixed + level shifter added |

### Sensor pin assignments

| Sensor | Pin | Status | Notes |
|---|---|---|---|
| Capacitive soil moisture AOUT | P34 (ADC1) | ✅ Working | Power from 3V3 |
| DHT11 DATA | P4 | ✅ Working | Module pull-up built in |
| ACS712-05B OUT | P35 (ADC1) | ⏳ Not wired | Needs 2kΩ/3kΩ voltage divider |
| HC-SR04 TRIG | P26 | ❌ Dropped for now | 3.3V TRIG may be insufficient; re-enable with level shifter |
| HC-SR04 ECHO | P25 | ❌ Dropped for now | 5V echo — needs 1kΩ series resistor |

### Firebase paths written

```
/sensors/soil_moisture_pct   int     (0–100 %)
/sensors/current             float   (A)  — 0.0 until ACS712 wired
/sensors/temperature         float   (°C)
/sensors/humidity            int     (%)
/sensors/water_level_cm      float   — hardcoded -1.0 until HC-SR04 resolved
```

### Credentials — hardcoded in .ino

- `WIFI_SSID` / `WIFI_PASSWORD`: Robox Industries network
- `API_KEY`: Firebase Web API Key (filled in)
- `DATABASE_URL`: `https://embedded-project-32dca-default-rtdb.firebaseio.com`

### Calibration

- `SOIL_DRY = 4095` (open air)
- `SOIL_WET = 1950` (submerged, midpoint of oscillation)

---

## Raspberry Pi Actuators & Indicators

### Actuators

| Device | Board | GPIO | Physical Pin | Notes |
|---|---|---|---|---|
| Pump relay SIG | **ESP32** | GPIO 16 | P16 | Active LOW — moved from Pi GPIO17 |
| DRV8825 STEP | Pi | GPIO 20 | Pin 38 | |
| DRV8825 DIR | Pi | GPIO 21 | Pin 40 | |
| DRV8825 ENABLE | — | NC | — | Internally pulled low = always enabled |
| DRV8825 FLT | — | NC | — | Open-drain fault output (optional) |

### Indicators (all on Pi)

| Device | Pi BCM GPIO | Physical Pin | Meaning | Circuit |
|---|---|---|---|---|
| LED — Green | GPIO 5 | Pin 29 | System NORMAL / power on | 220 Ω, direct |
| LED — Red | GPIO 6 | Pin 31 | FAULT / emergency stop active | 220 Ω, direct |
| LED — Yellow | GPIO 13 | Pin 33 | AUTO mode active | 220 Ω, direct |
| LED — Blue | GPIO 27 | Pin 13 | Pump ON | 220 Ω + NPN (5V drive) |
| Active buzzer | GPIO 22 | Pin 15 | Alerts & events | 1kΩ + NPN (5V buzzer) |

**LED count: 4 total.** One per system state axis — status, fault, mode, pump.
Green always on = system alive. Red overrides all = something needs attention.

### Buzzer event map

| Event | Pattern |
|---|---|
| System boot / ready | 2 short beeps |
| Pump ON | 1 short beep |
| Emergency stop triggered | Continuous rapid beep until cleared |
| Soil critically dry (auto) | 3 slow beeps |
| Fault cleared / system NORMAL | 1 long beep |

---

## Wiring Reference

### ESP32 Sensor Node

```
  ┌──────────────────────────────────────────────────────────┐
  │                   NodeMCU-32 v1.3                        │
  ├──────────────────────────────────────────────────────────┤
  │  P34    P35    P4    P26*   P25*   5V   GND   3V3        │
  └───┬──────┬─────┬──────┬──────┬─────┴────┴─────┴─────────┘
      │      │     │      │      │
  Soil    ACS712  DHT11  TRIG*  ECHO*
  AOUT    OUT↓    DATA   (dis-  (dis-
  3V3→   divider         abled) abled)
  GND↓
```

```
ACS712 voltage divider (when wired):
  ACS712 OUT ── 2kΩ ──┬── P35
                      3kΩ
                       └── GND
```

```
HC-SR04 (when re-enabled):
  TRIG via level shifter (3.3V → 5V) → P26
  ECHO via 1kΩ series resistor (5V → ~2.7V) → P25
```

### Raspberry Pi (AI + Stepper + Indicators)

```
Pi 5V  (pin 2)    ─────────────── Buzzer(+), Blue LED anode (via 220Ω)
Pi GND (pin 6/25) ─────────────── Signal GND (NOT motor return), DRV8825 GND

GPIO27 (pin 13) ─ [1kΩ] ─ NPN base → Blue LED (5V drive)
GPIO22 (pin 15) ─ [1kΩ] ─ NPN base → Buzzer between 5V and collector
GPIO5  (pin 29) ─ [220Ω] ─ LED Green  ─ GND
GPIO6  (pin 31) ─ [220Ω] ─ LED Red    ─ GND
GPIO13 (pin 33) ─ [220Ω] ─ LED Yellow ─ GND
GPIO20 (pin 38) ─────────────────── DRV8825 STEP
GPIO21 (pin 40) ─────────────────── DRV8825 DIR

12V SMPS ──── DRV8825 VMOT + 100µF cap ─ DRV8825 GND ─── SMPS GND (star)
         ──── LM2596 IN+ ─── Buck OUT+ ─── Relay COM (on ESP32 side)
                              Buck OUT- ─── Pump(-) / star GND
```

### ESP32 Pump + Sensor Side

```
ESP32 GPIO16 ──────────────── Relay SIG/IN
ESP32 VIN (5V) ────────────── Relay VCC, ACS712 VCC
ESP32 GND ─────────────────── Relay GND, sensor GNDs
Relay COM ─── Buck OUT+ (5V)
Relay NO  ─── ACS712 IP+ ─── ACS712 IP- ─── Pump(+)
Pump(-) ──── Buck OUT- / star GND
1N4007 across pump terminals (cathode to +)
```

**Star ground:** motor/pump return current flows directly to SMPS GND.
Pi GND and SMPS GND connect at ONE point only — at the SMPS terminal.

---

## Session Log

### Session 1 — 2026-06-18/19

- Confirmed ESP32 NodeMCU-32 v1.3 functional (esptool, COM12)
- Installed ESP32 core 2.0.17 (3.x timed out on campus network)
- Installed DHT, Adafruit Unified Sensor, Firebase_ESP_Client
- Wrote and flashed `esp32_sensor_node.ino`
- ✅ DHT11 — temperature + humidity correct, Firebase updating
- ✅ Soil moisture — calibrated (DRY=4095, WET=1950), correct %
- ✅ Firebase `/sensors/` updating every 2 s
- ❌ HC-SR04 — ECHO never went HIGH after correcting TRIG/ECHO swap
  - Likely cause: 3.3V TRIG insufficient for this sensor variant
  - **Decision: dropped for now, re-enable with level shifter when available**

### Session 2 — 2026-06-19

- Rewrote ESP32 firmware to clean production state:
  - HC-SR04 kept in code but gated behind `SONAR_ENABLED false`
  - ACS712 kept, gated behind `CURRENT_ENABLED false`
  - Removed all debug/experiment code accumulated during HC-SR04 investigation
- Added buzzer, 4× LED to actuator plan (fan dropped)
- Updated wiring table and GPIO assignments for full Pi actuator set
- Created `exhibition/POWER_ANALYSIS.md`
- Wrote `exhibition/pi_controller_exhibition.py` — full Pi controller (no UART/PIC)
- Wrote `exhibition/irrigation-exhibition.service` — systemd unit
- Wrote `exhibition/test_controller.py` — hardware-free mock tests

### Session 3 — 2026-06-19

**Pi deployment — fully working**

- Installed `firebase-admin` + `RPi.GPIO` on Pi (user: robox)
- Fixed GPIO access: added robox to `dialout` group (`/dev/gpiomem` owned by dialout)
- Fixed systemd service: `User=robox`, correct Python path `/usr/bin/python3`
- Deployed files to `/home/robox/Final_Project/` on Pi
- Firebase key: `/home/robox/Final_Project/firebase-key.json`
- Service enabled and auto-starts on boot: `sudo systemctl enable irrigation-exhibition`

**Bugs found and fixed during deployment:**

| Bug | Fix |
|---|---|
| `User=pi` in service — user is `robox` | Fixed service file |
| GPIO `/dev/mem` permission denied | `sudo usermod -a -G dialout robox` + reboot |
| `firebase-key.json` not on Pi | Downloaded from Firebase Console, placed in `Final_Project/` |
| `FIREBASE_CRED` pointed to `~/firebase-key.json` | Updated path to `/home/robox/Final_Project/firebase-key.json` |
| E-STOP triggered on every boot | Firebase had stale `emergency_stop: true` — fixed: seed `false` in `init_firebase()` |
| Auto pump infinite loop (soil=0% with ESP32 disconnected) | Added `AUTO_PUMP_COOLDOWN_S = 60` — 60 s wait between auto cycles |
| `set(None)` fails in Firebase Admin SDK | Changed cleanup to `.delete()` in test |

**Test results:**
- Unit tests: **65/65 passing** (hardware-free, runs on any machine)
- Firebase live test: **22/23 passing** — only failure: soil=0% (sensor not wired yet, expected)
- Pi ↔ Firebase round-trip confirmed working
- Controller stable: boots clean, no E-STOP, auto pump fires once then respects cooldown

**New files created this session:**
- `exhibition/test_firebase_live.py` — live Firebase connectivity test (run on Pi)
- `exhibition/WIRING_DIAGRAM.md` — full wiring reference for all components

---

## Next Steps — Phased Plan

### Phase 2 — Write Pi Exhibition Controller ✅ COMPLETE

- [x] **2.1** Create `exhibition/pi_controller_exhibition.py`
- [x] **2.2** Create `exhibition/irrigation-exhibition.service` (systemd)
- [x] **2.3** Tests: 65/65 unit tests passing, 22/23 Firebase live tests passing

### Phase 3 — Wire ESP32 Side (bench)
*Requires: 2kΩ + 3kΩ resistors*

- [ ] **3.1** Build ACS712 voltage divider on breadboard
- [ ] **3.2** Wire ACS712: VCC→5V, GND→GND, OUT→divider→P35
- [ ] **3.3** Flip `CURRENT_ENABLED true` in firmware, flash, verify serial output
- [ ] **3.4** Check current reading with no load (should read ~0.0 A)
- [ ] **3.5** (Optional) Flip `SONAR_ENABLED true` after adding level shifter to TRIG

### Phase 4 — Wire Actuators (bench)
*Requires: pump + relay module, A4988 + stepper, 12V SMPS, LM2596 buck, 4× LED, resistors, buzzer, 2× NPN (2N2222), 1N4007 diodes*
*See `exhibition/WIRING_DIAGRAM.md` for full connection details*

- [ ] **4.1** Wire pump relay to **ESP32**: GPIO16 → relay SIG, relay VCC → ESP32 VIN, relay GND → ESP32 GND
- [ ] **4.2** Wire pump circuit: relay COM → Buck OUT+, relay NO → ACS712 IP+, ACS712 IP- → pump(+), pump(-) → Buck OUT-/star GND
- [ ] **4.3** 1N4007 flyback diode across pump terminals
- [ ] **4.4** Wire DRV8825: GPIO20 STEP, GPIO21 DIR, ENABLE NC, FLT NC, RESET/SLEEP jumpered, VMOT→12V + 100µF, GND→SMPS GND + Pi GND
- [ ] **4.5** Set DRV8825 current limit: Vref = I_limit / 2. Start 0.2V, max 0.4V
- [ ] **4.6** Wire 3× status LEDs: GPIO5/6/13 → 220Ω → LED → GND
- [ ] **4.7** Wire blue LED (5V): GPIO27 → 1kΩ → NPN base, 5V → 220Ω → LED anode, LED cathode → NPN collector, emitter → GND
- [ ] **4.8** Wire buzzer: GPIO22 → 1kΩ → NPN base, 5V → buzzer(+), buzzer(-) → NPN collector, emitter → GND
- [ ] **4.9** Star ground: connect all GNDs at SMPS terminal

### Phase 5 — Pi Software Deployment ✅ COMPLETE

- [x] **5.1** `pi_controller_exhibition.py` deployed to `/home/robox/Final_Project/`
- [x] **5.2** `firebase-key.json` at `/home/robox/Final_Project/firebase-key.json`
- [x] **5.3** `pip3 install firebase-admin RPi.GPIO` installed
- [x] **5.4** `FIREBASE_CRED` path corrected, `STEPS_PER_PLANT` to be set after gantry measured
- [x] **5.5** Manual run verified — boot log clean
- [x] **5.7** Service file deployed to `/etc/systemd/system/irrigation-exhibition.service`
- [x] **5.8** `sudo systemctl enable irrigation-exhibition` — auto-starts on boot
- [x] **5.9** Journal clean: GPIO ready → Firebase ready → System ready (no errors)

> **5.6 NOTE:** Physical green LED not verified yet — actuator wiring (Phase 4) not done.

### Phase 6 — Integration Test (full rig)

- [ ] **6.1** ESP32 serial: soil + temp + hum every 2 s, no errors
- [ ] **6.2** Firebase console: `/sensors/` values updating
- [ ] **6.3** App: sensor tiles show live data
- [ ] **6.4** App: switch to MANUAL mode → yellow LED OFF
- [ ] **6.5** App: pump ON → relay clicks, pump runs, blue LED ON, 1 beep
- [ ] **6.6** App: pump OFF → pump stops, blue LED OFF
- [ ] **6.7** App: move gantry to plant 1 → stepper steps correct distance
- [ ] **6.8** App: move gantry to plant 2 → stepper continues from plant 1
- [ ] **6.9** Emergency stop → pump off + stepper stops + red LED ON + alarm buzzer
- [ ] **6.10** Clear emergency stop → red LED OFF + 1 long beep + green LED ON
- [ ] **6.11** Auto mode: confirm Pi reads soil and triggers pump at threshold (TBD threshold)
- [ ] **6.13** Power-cycle Pi → controller restarts automatically (systemd)
- [ ] **6.14** Run rig for 30 min continuously — watch for resets, Firebase auth expiry, memory issues

### Phase 7 — Exhibition Polish

- [ ] **7.1** Confirm exhibition date and location
- [ ] **7.2** Cable management: label all wires, cable-tie harnesses
- [ ] **7.3** Power-up sequence rehearsal (documented order: SMPS → Pi → ESP32)
- [ ] **7.4** Demo script: 3-minute walkthrough of all features
- [ ] **7.5** Decide: keep LCD or rely on app only (see Open Decisions)

---

## Open Decisions

| Decision | Options | Status |
|---|---|---|
| HC-SR04 | Re-enable with level shifter vs keep disabled | ⬜ Wait for resistors |
| LCD on exhibition build | Keep / drop (use app only) | ⬜ Open |
| Exhibition date | Not captured | ⬜ Confirm with team |
| Pump rated current | Determines relay rating + SMPS sizing | ⬜ Measure pump label |
| STEPS_PER_PLANT | Measure physically on gantry | ⬜ Measure on bench |
| Auto irrigation threshold | Soil % below which Pi triggers pump | ⬜ Decide (suggest 30%) |
