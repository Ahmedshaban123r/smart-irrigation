# An AI-Augmented Cyber-Physical Smart Precision Irrigation System

> **Course:** CIE-349 / CIE-408 — Embedded Systems (Spring 2026)
> **Institution:** Zewail City of Science and Technology
> **Program:** Communications and Information Engineering (CIE)
> **Repository status:** active development — see `STREAMS.md` for the team ↔ folder ↔ gate mapping.

---

## 1. Abstract

This repository contains the full engineering artefacts of a cyber-physical
precision-irrigation platform that couples real-time embedded control, networked
IoT telemetry, a cross-platform mobile human–machine interface, and on-device
computer-vision inference. The system continuously senses the soil-water,
electrical, thermal, and tank-level state of a two-plant test bench, performs a
safety-critical evaluation against a hysteresis-protected fault model, and
actuates a pump and a Cartesian gantry to deliver water on a per-plant basis.
A Raspberry Pi 4 attached to the same UART bus performs convolutional-neural-network
inference on plant images captured by a CSI camera, classifies disease state into
six clinical categories, and serialises both telemetry and inference results to a
Firebase Realtime Database (RTDB). A Flutter mobile client subscribes to the same
RTDB, rendering live sensor streams, AI detections, and an operator command surface
(pump toggle, gantry positioning, mode switching, emergency stop). The project
demonstrates the integration of MCU-class deterministic control, edge-class neural
inference, cloud-class persistence, and a touch-class user interface within a
single, gate-driven engineering process.

---

## 2. System Overview

| Subsystem | Hardware | Toolchain | Role |
|-----------|----------|-----------|------|
| Real-time controller | PIC16F877A-I/P (8 MHz crystal) | MPLAB X IDE + XC8 v2.36 | Deterministic sensing, safety FSM, motion control, UART arbitration |
| Wi-Fi pump actuator | ESP8266 NodeMCU v3 | Arduino core, `Firebase_ESP_Client` | Wireless pump relay triggered by Firebase commands from the app / Pi |
| Edge AI + IoT gateway | Raspberry Pi 4 Model B (4 GB) | Python 3.11, `firebase-admin`, `pyserial`, TensorFlow Lite | Image capture, CNN inference, UART ↔ Firebase bridge |
| Cloud persistence | Firebase RTDB + Cloud Storage | Firebase JS/Admin SDK | Telemetry store, command queue, image hosting |
| Mobile HMI | Android / iOS | Flutter (Dart 3) + Material 3 | Dashboard, actuator control, AI monitor, alerts, voice command |
| Mechanical | Custom 3D-printed gantry | OpenSCAD source + STL | Linear motion, instrumentation mount, electronics enclosure |

> **Note on the actuator topology.** The pump can be driven through two
> independent paths. The **wired path** routes commands over UART
> (App → Firebase → Pi → PIC → relay on `RD0`) and is gated by the on-board
> safety FSM. The **wireless path** routes commands directly to an ESP8266
> NodeMCU that polls Firebase at `/esp/pump/state` and toggles its own relay
> on `D1` for a fixed 5-second cycle. Both paths can coexist on the same
> physical pump or drive separate solenoids; the ESP path is intended as a
> fast, low-latency override for app-initiated watering and for resilience
> when the Pi bridge is offline.

---

## 3. High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          PHYSICAL / ANALOG DOMAIN                            │
│                                                                              │
│  Soil moisture (cap.)   ACS712-05B   DHT11   HC-SR04   Limit SW   E-Stop SW  │
│        │                    │          │        │          │         │       │
│        ▼                    ▼          ▼        ▼          ▼         ▼       │
│   ┌────────────────────────────────────────────────────────────────────┐    │
│   │                       PIC16F877A (8 MHz)                           │    │
│   │   MCAL: ADC | GPIO | USART | TIMER0 | Interrupt Manager            │    │
│   │   HAL : Soil | Current | Humidity | Ultrasonic | LCD | LED | ...   │    │
│   │   APP : Safety FSM | Irrigation Sequencer | Comms | Main scheduler │    │
│   └────────────────────────────────────────────────────────────────────┘    │
│        │                    │                   │           │                │
│        ▼                    ▼                   ▼           ▼                │
│  Pump relay (12 V)     A4988 + NEMA17       Buzzer +     16×2 LCD            │
│  (wired path, RD0)     stepper gantry       LEDs                             │
└──────────────────────────────┬───────────────────────────────────────────────┘
                               │ UART 9600-8N1
                               │ (custom framed protocol, §6)
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                       RASPBERRY PI 4 (edge gateway)                          │
│   capture_and_infer.sh  →  libcamera  →  TFLite (MobileNetV2 INT8)           │
│   pi_controller.py      :  serial RX/TX  ⇄  Firebase RTDB + Storage          │
└──────────────────────────────┬───────────────────────────────────────────────┘
                               │ HTTPS / WebSocket (Firebase SDK)
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                       FIREBASE  (RTDB + Storage)                             │
│   /sensors  /status  /commands  /ai  /alerts  /esp/pump/state                │
└──────┬───────────────────────┬───────────────────────────────────────────────┘
       │ Firebase listener     │ 1 Hz poll on /esp/pump/state
       ▼                       ▼
┌─────────────────────────┐   ┌─────────────────────────────────────────────┐
│  FLUTTER MOBILE CLIENT  │   │           ESP8266 NodeMCU v3                │
│  (Android / iOS)        │   │   Wi-Fi → Firebase_ESP_Client                │
│  Landing → Dashboard →  │   │   D1 relay → wireless pump (5 s cycle,       │
│  Controls → AI Monitor  │   │            self-clears node on completion)   │
│  → Alerts (STT mic)     │   └─────────────────────────────────────────────┘
└─────────────────────────┘
```

**Two actuator paths to the pump:**

* **Wired path** — Flutter writes a `commands/pump` node → the Pi bridge
  consumes it → encodes a `0xBB 0x04` UART frame → PIC validates against the
  safety FSM → drives the relay on `RD0` for `PUMP_ON_TICKS × 100 ms`.
* **Wireless path** — Flutter writes `/esp/pump/state = "ON"` → the ESP8266
  picks it up within ≤ 1 s on its polling loop → energises its own relay on
  `D1` for `PUMP_ON_MS = 5000 ms` → resets the node to `"OFF"`.

---

## 4. Repository Layout

```
smart-irrigation/
├── pic-firmware/         PIC16F877A MPLAB X project (Stream A)
│   ├── MCAL/             Microcontroller-abstraction layer (ADC, USART, GPIO, TIMER0)
│   ├── HAL/              Hardware-abstraction layer (LCD, sensors, motor, relay, …)
│   ├── SERVICES/         Reusable services (STD_TYPES, BIT_MATH, Delay)
│   ├── APP/              Application layer (Safety, Comms, Irrigation, MyProject)
│   ├── include/          Cross-module headers (frame defs, pin maps)
│   ├── config.h          Central configuration (clock, thresholds, pin map, timing)
│   └── cmake/, _build/   Out-of-tree build helpers
│
├── esp-firmware/         ESP8266 NodeMCU pump actuator (Stream C)
│   └── esp.ino           Arduino sketch: Wi-Fi + Firebase polling + relay
│
├── pi-script/            Raspberry Pi bridge daemon (Stream B)
│   ├── pi_controller.py  UART ⇄ Firebase main bridge
│   ├── handshake.py      Boot-time handshake validator
│   ├── bidir_test.py     Loopback UART self-test
│   ├── test_firebase.py  RTDB connectivity test
│   ├── irrigation.service systemd unit (auto-start on boot)
│   └── export.json       RTDB schema snapshot (reference)
│
├── pi-ai/                Inference + camera layer (Stream B)
│   ├── Capture_camera/   libcamera capture + invocation script
│   ├── Irrigation system/Docker_files  Containerised inference runtime
│   ├── inference/        Daemon stubs (TFLite runner)
│   └── protocols/        Action-protocol packet generators
│
├── ml-pipeline/          Model training + export (Stream B)
│   ├── notebooks/Model (1).ipynb   MobileNetV2 fine-tune + INT8 quantisation
│   ├── dataset/          Dataset retrieval and augmentation scripts
│   └── models/           TFLite artefacts + label map + model card
│
├── flutter-app/          Mobile HMI (Stream C)
│   ├── lib/services/     firebase_service, stt_service, notification_service
│   ├── lib/screens/      Landing, Dashboard, Controls, AI Monitor, Alerts
│   ├── lib/widgets/      SensorCard, DetectionCard, StatusBadge, mic button, …
│   ├── lib/models/       protocol_definition.dart
│   ├── lib/theme/        Material 3 theme (greenDeep ↔ greenPale palette)
│   └── android/, ios/    Platform projects
│
├── mechanical/           CAD + STL artefacts (Stream D)
│   ├── cad/              OpenSCAD source (6 printed parts + assembly)
│   ├── stl/              Print-ready exports
│   └── print-settings/   Slicer profiles
│
├── Report and Feasibilty Study/  Course deliverables
├── app-release.apk       Latest Android build (for evaluator side-load)
├── default.hex           Latest PIC HEX (golden image)
├── README.md             ← this file
└── STREAMS.md            Team ↔ folder ↔ gate criteria mapping
```

---

## 5. PIC16F877A Firmware — Architecture

The firmware adopts a strict four-layer architecture inspired by AUTOSAR’s
classic separation of concerns. Each layer depends only on the layer immediately
below it, and inter-module access is mediated by explicit `*_interface.h`
contracts.

```
┌─────────────────────────────────────────────────────────────┐
│  APP/    Safety FSM · Irrigation sequencer · Comms · main  │
├─────────────────────────────────────────────────────────────┤
│  HAL/    LCD · Motor · Relay · Soil · Current · Humidity · │
│          Ultrasonic · LED · Buzzer · Button · Fan · Temp   │
├─────────────────────────────────────────────────────────────┤
│  MCAL/   ADC · USART · GPIO · TIMER0 · Interrupt Manager   │
├─────────────────────────────────────────────────────────────┤
│  SERVICES/  STD_TYPES · BIT_MATH · Delay                   │
└─────────────────────────────────────────────────────────────┘
```

### 5.1 Build configuration

| Parameter | Value |
|-----------|-------|
| MCU | PIC16F877A-I/P (DIP-40) |
| Oscillator | HS, 8 MHz external crystal (with 22 pF load caps) |
| Compiler | Microchip XC8 v2.36 (free mode) |
| IDE | MPLAB X IDE v6.x |
| Programmer | PICkit 3 / PICkit 4 (ICSP) |
| Code memory used | see `_build/` after compilation |
| Power | 5 V regulated, common ground with relay-isolated 12 V rail |

Configuration fuses are declared at the top of `APP/MyProject.c`:
`FOSC=HS`, `WDTE=OFF`, `PWRTE=ON`, `BOREN=ON`, `LVP=OFF`, `CPD=OFF`,
`WRT=OFF`, `CP=OFF`. All build-time tunables live in `pic-firmware/config.h`
(thresholds, pin map, baud divisor, tick periods, microstep counts).

### 5.2 Scheduler model

`APP/MyProject.c` provides two co-existing top-level applications gated by
`#if` blocks:

* **Production main (`Section 1`)** — full pipeline. Cooperative super-loop
  with a 100 ms tick (`__delay_ms(100)`). Soft-real-time periods:
  * Sensor scan: every 2 s (`SENSOR_PERIOD_TICKS = 20`)
  * Auto irrigation cycle: every 5 min (`IRRIG_PERIOD_TICKS = 3000`)
  * Pi handshake gate at boot before entering the loop.
* **Debug main (`Section 2`)** — sensor + photo pipeline without the 5-min
  timer or handshake gate. The carriage bounces between plant 0 (3 cm from
  home) and plant 1 (13 cm). After each move the firmware reads every sensor,
  emits a `SENSORS` packet and an `AT_PLANT` packet, then idles 20 s while the
  Pi captures and uploads an image. Sensor pages are paged onto the LCD every
  4 s during the wait.

The two sections allow bring-up, debug, and demo without recompiling against
two different code trees.

### 5.3 Safety model

The `APP/Safety` module owns a per-channel hysteresis FSM with three states
per channel: **CLEAR → WARN → ACTION (locked)**. Each channel exposes an
independent set of thresholds in `config.h`:

| Channel | Sensor | Warn | Action | Clear | Action consequence |
|---------|--------|------|--------|-------|--------------------|
| Soil over-saturation | Capacitive soil (RA0/AN0) | 80 % | 90 % | 75 % | Pump OFF + system lockout |
| Over-temperature | DHT11 (RB0) | 55 °C | 70 °C | 50 °C | Pump + stepper OFF, fan ON, lockout |
| Over-current | ACS712-05B (RA2/AN2) | 3 500 mA | 4 500 mA | 3 000 mA | Full actuator OFF + lockout |
| Dry-run (low tank) | HC-SR04 (RC3 trig / RB1 echo) | 5 cm | 2 cm | 6 cm | Pump OFF + lockout |

Visual / audible annunciation is bound to the FSM state: amber LED (RE1) and
buzzer (RB2) pulse in `WARN`; red LED (RE2) latches in `ACTION`. A lockout is
cleared only when *all* channels return to `CLEAR`.

**Command-priority arbitration** (highest to lowest):
`Safety lockout` ▶ `Hardware E-stop (RB4)` ▶ `App E-stop` ▶ `AI protocol` ▶
`App manual command` ▶ `Scheduled auto cycle`.

### 5.4 Motion control

`HAL/Motor` drives an A4988 stepper driver (1/16 microstepping, MS1/MS2/MS3
tied high externally) connected to a NEMA17 (JK42HS40) on a GT2 belt with a
20-tooth pulley. Calibration:

* 1 cm of linear motion = 800 microsteps
* Plant 0 at 4 000 steps (≈ 5 cm); plant 1 at 12 000 steps (≈ 15 cm)
* `STEP_DELAY_NORMAL_US = 1 800 µs` ⇒ a 10 cm traverse takes ≈ 14.4 s
* `STEP_DELAY_HOMING_US = 800 µs` for limit-switch approach

Homing routine: drive towards `RB3` limit switch at homing speed until the
switch trips (active-LOW, internal pull-up), back off by
`HOMING_BACKOFF_STEPS = 200` steps, and zero the logical position counter.

### 5.5 UART driver

`MCAL/USART` configures the EUSART for 9 600 baud, 8-N-1, BRGH = 1, asynchronous
mode. `UART_SPBRG_VAL = 51` is derived from `(F_OSC / (16 × baud)) − 1 =
(8e6 / 153 600) − 1 ≈ 51`, giving a steady-state error well under 1 %.

Frame parsing is centralised in `APP/Comms`, which exposes `Comms_Poll()` for
the super-loop and `Comms_SendSensors / Comms_SendStatus / Comms_SendAtPlant /
Comms_SendHandshakeAck` for outbound transmissions. See §6 for the wire
format.

### 5.6 Pin map (selected)

| MCU pin | Function | Direction |
|---------|----------|-----------|
| RA0 / AN0 | Capacitive soil moisture | Analog in |
| RA2 / AN2 | ACS712-05B current sense | Analog in |
| RB0 | DHT11 1-wire data | Bidirectional |
| RB1 | HC-SR04 echo | Digital in |
| RB2 | Buzzer (NPN driver) | Digital out |
| RB3 | Limit switch (active-LOW) | Digital in (pull-up) |
| RB4 | Emergency-stop button (active-LOW) | Digital in (pull-up) |
| RC0 | A4988 STEP | Digital out |
| RC1 | A4988 DIR (HIGH = away from home) | Digital out |
| RC2 | A4988 ENABLE (LOW = enabled) | Digital out |
| RC3 | HC-SR04 trigger | Digital out |
| RC4 | Cooling fan (NPN driver) | Digital out |
| RC6 / RC7 | UART TX / RX | Alt-function |
| RD0 | Pump relay (active-LOW) | Digital out |
| RD2 / RD3 / RD4-7 | LCD RS / EN / D4-D7 | Digital out |
| RE1 / RE2 | Amber / red LEDs | Digital out |

Full table in `config.h`.

---

## 6. UART Wire Protocol (PIC ↔ Raspberry Pi)

The link runs at 9 600-8-N-1 on `/dev/ttyAMA0` on the Pi side. Every frame
carries an explicit type byte so the receiver can dispatch without
context. Two header bytes distinguish direction.

### 6.1 Pi → PIC commands (fixed 3-byte frame)

```
┌────────┬────────┬────────┐
│ 0xBB   │  CMD   │  DATA  │
└────────┴────────┴────────┘
```

| `CMD` | Meaning | `DATA` semantics |
|-------|---------|------------------|
| `0x01` MODE | Set operating mode | `0x00` = AUTO, `0x01` = MANUAL |
| `0x02` IRRIGATE | Run one-shot irrigation on a single plant (manual) | plant index `0x00`–`0x04` |
| `0x03` ESTOP | App-driven emergency stop | `0x01` = stop, `0x00` = release |
| `0x04` PUMP | Direct pump command | high nibble = plant (0/1), low nibble = state (0 = OFF, 1 = ON) |
| `0x10` HANDSHAKE | Boot signal from Pi | `0xAA` |

### 6.2 PIC → Pi telemetry (variable-length frame)

```
┌────────┬────────┬──────────────── … ──────────────┐
│ 0xAA   │  TYPE  │              payload             │
└────────┴────────┴──────────────── … ──────────────┘
```

| `TYPE` | Payload | Meaning |
|--------|---------|---------|
| `0x01` SENSORS | `soil, temp, hum, curr_hi, curr_lo, water` (6 B) | Periodic sensor snapshot (every 2 s) |
| `0x02` AT_PLANT | `plant_index` (1 B) | “Carriage parked, take a photo now” |
| `0x03` STATUS | `mode, lockout` (2 B) | Mode/lockout change notification |
| `0x10` HANDSHAKE | `0xBB` (1 B) | PIC acknowledges Pi handshake |

Current is transmitted as a 16-bit big-endian integer in milliamps; all other
fields are unsigned 8-bit. The frame definitions live in `pic-firmware/config.h`
and are mirrored in `pi-script/pi_controller.py`.

---

## 7. Raspberry Pi Bridge (`pi-script/`)

`pi_controller.py` opens the serial port, spawns a reader thread that decodes
framed packets into a Python dictionary, and forwards the result into the
Firebase paths described in §8. A second thread subscribes to the
`/commands/*` paths on Firebase, encodes commands into the 3-byte Pi → PIC
frame, and writes them to the serial port. The script also acts on the
`AT_PLANT` event by invoking `Capture_camera/capture_and_infer.sh`, which
takes a still via `libcamera-still`, runs the quantised MobileNetV2 model, and
uploads both the image and the inference result to Cloud Storage / RTDB.

The unit `pi-script/irrigation.service` registers the bridge with systemd so
it starts at boot and restarts on failure. `handshake.py` and `bidir_test.py`
are bring-up utilities; `test_firebase.py` verifies cloud credentials before
deployment.

---

## 8. ESP8266 Wireless Pump Actuator (`esp-firmware/`)

The ESP8266 NodeMCU v3 runs an Arduino sketch (`esp.ino`) that joins the
campus / hotspot Wi-Fi, signs into the same Firebase project used by the app
and the Pi, and polls a single RTDB node for pump commands.

| Aspect | Value |
|--------|-------|
| Board | ESP8266 NodeMCU v3 |
| Toolchain | Arduino IDE / Arduino CLI, ESP8266 core, `Firebase_ESP_Client` |
| Relay pin | `D1` (GPIO 5), active-LOW |
| Polled node | `/esp/pump/state` (string: `"ON"` / `"OFF"`) |
| Poll cadence | 1 Hz (`POLL_INTERVAL_MS = 1000`) |
| Pump-on duration | 5 s (`PUMP_ON_MS = 5000`) — matches `PUMP_ON_TICKS × 100 ms` on the PIC |
| Auto-clear | Node is reset to `"OFF"` after each cycle |
| Wi-Fi watchdog | Reconnect attempts on `WL_CONNECTED` loss (10 s budget) |
| Sources of commands | Flutter app (`Controls` tab) and the Pi bridge (forwarded from voice / scheduler) |

**Control flow:**

```
Flutter / Pi  ──set──▶  /esp/pump/state = "ON"
                                 │
                                 ▼
                        ESP8266 poll loop (1 Hz)
                                 │
                          state == "ON" ?
                                 │
                                 ▼
                  relay LOW → pump ON  (5 000 ms)
                                 │
                                 ▼
                  relay HIGH → pump OFF
                                 │
                                 ▼
                set /esp/pump/state = "OFF"  (idempotent latch)
```

**Build & flash:**

```bash
# Install ESP8266 board support + Firebase_ESP_Client library in the Arduino IDE
# Open esp-firmware/esp.ino
# Edit WIFI_SSID, WIFI_PASSWORD, API_KEY, DATABASE_URL to match your project
# Select board: NodeMCU 1.0 (ESP-12E Module), upload speed 115200, port = NodeMCU
# Sketch → Upload
```

**Security note.** The reference sketch stores Wi-Fi and Firebase credentials
as string literals for laboratory demonstration. For production deployment,
move secrets into a separate `secrets.h` excluded from version control and
enable Firebase RTDB rules that restrict `/esp/pump/state` to authenticated
writes.

---

## 9. Firebase RTDB Schema

```
sensors/
  current               float   (A)
  humidity              int     (%)
  soil_moisture_pct     int     (%)
  temperature           float   (°C)

status/
  gantry_x              int     (plant index)
  mode                  string  "AUTOMATIC" | "MANUAL"
  mode_changed_at       int     (ms epoch)
  pump                  string  "ON" | "OFF"
  system_state          string  "NORMAL" | "WARNING" | "FAULT"

commands/
  emergency_stop        bool
  pump/
    state               string  "ON" | "OFF"
    source              string  "app" | "voice"
    timestamp           int
  gantry_move/
    x                   int     (plant index)
    source              string
    timestamp           int
  cancel_ai_protocol    bool

ai/
  latest_detection/
    class               string  e.g. "Late_Blight"
    confidence          float   ∈ [0, 1]
    image_url           string  Cloud Storage URL
    timestamp           string  ISO-8601
  active_protocol/
    status              string  "idle" | "running"
    zone_x              int
    grace_remaining     int
  action_log/{id}/      class, confidence, action_taken, timestamp, zone_x

alerts/
  history/{id}/         message, severity, timestamp

esp/
  pump/
    state               string  "ON" | "OFF"   (consumed by the ESP8266 node)
```

`sensors/*` and `status/*` are read-only for the mobile client; all operator
actions are expressed as `commands/*` writes that the Pi bridge consumes.

---

## 10. Mobile Client (`flutter-app/`)

A Flutter (Dart 3) application targeting Android (primary, APK shipped) and
iOS. Architecture: a single `firebase_service.dart` exposes every read stream
as a static getter, so screens never construct database references directly.
The app is organised into five bottom-tab destinations:

| Tab | Screen | Responsibilities |
|-----|--------|------------------|
| Home | `HomeScreen` | Landing surface, “how it works” cards, hero stats |
| Dashboard | `DashboardScreen` | Live `SensorCard` grid + `DetectionCard` |
| Controls | `ActuatorScreen` | Pump toggle, gantry move, emergency stop |
| AI Monitor | `AiMonitorScreen` | Latest detection image + active protocol state |
| Alerts | `AlertsScreen` | Severity-sorted alert history |

Cross-cutting services:

* `stt_service.dart` — singleton Speech-to-Text wrapper (Android requires
  `RECORD_AUDIO`).
* `notification_service.dart` — local notifications on fault / detection.
* `theme/app_theme.dart` — Material 3 theme, greenDeep → greenPale palette,
  DM Serif Display + DM Sans typography.

The AI model emits one of six classes; their colour mapping lives in
`DetectionCard._colorForClass`: `Healthy`, `Early_Blight`, `Late_Blight`,
`Pest`, `Nutrient_Deficiency`, plus a generic “unknown” fallback.

---

## 11. Machine-Learning Pipeline (`ml-pipeline/`)

| Aspect | Value |
|--------|-------|
| Base architecture | MobileNetV2 (TensorFlow / Keras) |
| Strategy | Transfer learning — ImageNet weights, last block fine-tuned |
| Input | 224 × 224 RGB |
| Output classes | 6 (`healthy`, `leaf_spot`, `blight`, `pest`, `wilt`, `nutrient_deficiency`) |
| Loss | Categorical cross-entropy |
| Optimiser | Adam, learning-rate scheduled |
| Augmentation | Random flip, rotation, brightness, zoom |
| Target accuracy | ≥ 92 % (test) / ≥ 90 % (post-INT8 quantisation) |
| Export format | TensorFlow Lite, INT8 post-training quantisation |
| Target inference time | < 200 ms on Raspberry Pi 4 (single thread) |
| Notebook | `ml-pipeline/notebooks/Model (1).ipynb` |
| Artefacts | `ml-pipeline/models/mobilenetv2_int8.tflite`, `labels.txt`, `model_card.md` |

The notebook produces a full evaluation: training curves, per-class precision
/ recall, confusion matrix, and a quantisation-aware delta report.

---

## 12. Mechanical Subsystem (`mechanical/`)

The gantry is a single-axis linear stage executed in 3D-printed PLA on an
aluminium 2020 V-slot frame. Six OpenSCAD parts compose the assembly:

| Part | File | Function |
|------|------|----------|
| 1 | `Part1_Drive_End_Bracket.scad` | Mounts the NEMA17, anchors the GT2 belt, terminates the 8 mm smooth rod |
| 2 | `Part2_Idler_End_Bracket.scad` | Houses the idler pulley + tensioner |
| 3 | `Part3_Carriage_Plate.scad` | LM8UU bearing carriage carrying the watering manifold + camera |
| 4 | `Part4_Belt_Clamp_x2.scad` | Pair of GT2 belt clamps for the carriage |
| 5 | `Part5_Control_Box.scad` | Electronics enclosure (PIC, A4988, relay, LCD bezel) |
| 6 | `Part6_Rod_End_Holder_x2.scad` | Twin rod-end clamps |

The full assembly is rendered in `mechanical/cad/irrigation_assembly.scad`.

**Frame BOM:** 2 × 500 mm 2020 V-slot extrusion, 1 × 8 mm linear rod, 2 ×
LM8UU linear bearings, GT2 belt + 20 T pulley, NEMA17 stepper.

---

## 13. Build, Flash, and Run

### 13.1 PIC firmware

```bash
# In MPLAB X IDE
File → Open Project → pic-firmware (CMake project) or use the .X folder
Select tool: PICkit 3 / 4 (ICSP)
Build → Make and Program Device
```

The golden HEX is checked in at `default.hex` for evaluators without a build
toolchain.

### 13.2 Raspberry Pi bridge

```bash
cd pi-script
sudo apt install python3-pip
pip install pyserial firebase-admin --break-system-packages

# One-shot run
python3 pi_controller.py

# Permanent install
sudo cp irrigation.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now irrigation
```

Edit `pi_controller.py` to point `FIREBASE_CRED`, `FIREBASE_DB_URL`, and
`FIREBASE_BUCKET` at your project, then drop the service-account JSON at the
path given by `FIREBASE_CRED`.

### 13.3 ESP8266 firmware

```bash
# Arduino IDE: Board Manager → install "esp8266" core
# Library Manager → install "Firebase Arduino Client Library for ESP8266 and ESP32"
# Open esp-firmware/esp.ino, edit the credential macros, then Upload.
# Or via Arduino CLI:
arduino-cli compile --fqbn esp8266:esp8266:nodemcuv2 esp-firmware/esp.ino
arduino-cli upload  --fqbn esp8266:esp8266:nodemcuv2 -p COMx esp-firmware/esp.ino
```

### 13.4 Inference layer

```bash
cd pi-ai/Capture_camera
chmod +x capture_and_infer.sh
./capture_and_infer.sh                # one-shot capture + classify + upload
```

The Docker variant under `pi-ai/Irrigation system/Docker_files` provides a
reproducible runtime if Pi OS package versions drift.

### 13.5 Mobile client

```bash
cd flutter-app
flutter pub get
flutter run                # debug, attached device
flutter build apk          # release APK
flutter analyze            # static analysis
flutter test               # unit + widget tests
```

`lib/firebase_options.dart` is generated locally with `flutterfire configure`
and is git-ignored.

### 13.6 ML training

```bash
cd ml-pipeline
pip install -r requirements.txt
jupyter notebook "notebooks/Model (1).ipynb"
```

---

## 14. Hardware Bill of Materials (selected)

| Block | Component | Notes |
|-------|-----------|-------|
| MCU | PIC16F877A-I/P | 8 MHz HS crystal + 2 × 22 pF |
| Wi-Fi node | ESP8266 NodeMCU v3 + 5 V relay module on `D1` | Shares Firebase project with the Pi |
| Edge AI | Raspberry Pi 4 Model B (4 GB) + Pi Camera v2 | Active cooling recommended |
| Sensors | Capacitive soil v1.2, DHT11, ACS712-05B, HC-SR04 | All 5 V tolerant |
| Actuation | NEMA17 (JK42HS40), A4988 driver, 12 V DC pump, 2-ch SRD relay | Common ground with logic |
| HMI | 16×2 HD44780 LCD (4-bit), amber + red LEDs, buzzer, momentary E-stop | RD-port shadowed in firmware |
| Frame | 2 × 2020 V-slot 500 mm, 8 mm rod, LM8UU, GT2 belt + 20 T pulley | See §11 |
| Power | 12 V / 5 A SMPS + LM7805 logic rail | Isolated relay coil |

A full BOM with vendor links is included in `Report and Feasibilty Study/`.

---

## 15. Course Milestones

| Gate | Criterion | Target |
|------|-----------|--------|
| G0 | Development environment ready, repo cloned, tool-chain reproducible | End of Week 1 |
| G1 | All four ADC channels validated to ±5 %, safety FSM trips at the configured thresholds, ML training pipeline producing ≥ 92 % test accuracy | End of Week 2 |
| G2 | Each subsystem (PIC, Pi, App) runs standalone; bidirectional UART + Firebase + APK build all green | End of Week 3 |
| G3 | Full closed loop verified: App ↔ Firebase ↔ Pi ↔ PIC ↔ actuator ↔ telemetry ↔ App; safety overrides on every layer | End of Week 4 |
| G4 | Demo bench, photos, video, final report | End of Week 5 |
| Live demo | Departmental defence | 17 – 21 May 2026 |
| Final submission | Course portal upload | Day of the final exam |

Per-stream gate ownership and mitigation paths are tabulated in
`STREAMS.md`.

---

## 16. References

1. Microchip Technology, *PIC16F87XA Data Sheet*, DS39582.
2. Allegro MicroSystems, *ACS712 Fully Integrated, Hall-Effect-Based Linear
   Current Sensor IC*, datasheet.
3. Allegro MicroSystems / Pololu, *A4988 Stepper Motor Driver Carrier*,
   reference design.
4. Aosong Electronics, *DHT11 Humidity & Temperature Sensor* datasheet.
5. Sandler, M., Howard, A., Zhu, M., Zhmoginov, A., Chen, L.-C.,
   *MobileNetV2: Inverted Residuals and Linear Bottlenecks*, CVPR 2018.
6. Google, *TensorFlow Lite — Post-Training Integer Quantization*, official
   guide.
7. Google, *Firebase Realtime Database — Data Organization*, official
   documentation.
8. Flutter Authors, *Flutter Engineering Best Practices*, flutter.dev.
9. AUTOSAR Consortium, *Layered Software Architecture* (motivation for the
   MCAL / HAL / SERVICES / APP split adopted in `pic-firmware/`).

---

## 17. License

Released under the MIT License. See `LICENSE` if present, otherwise
distribute under the terms reproduced in the course handbook.
