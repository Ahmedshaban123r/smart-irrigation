# AI-Based Smart Precision Irrigation System

> CIE-349 / CIE-408 — Embedded Systems, Spring 2026  
> Zewail City, University of Science and Technology  
> Program of Communications and Information Engineering

## System Overview

A cyber-physical smart irrigation system combining embedded real-time control, IoT connectivity, a Flutter mobile app, and on-device machine learning for plant disease detection and autonomous actuation.

| Unit | Hardware | Language / Tool |
|------|----------|----------------|
| Real-time controller | PIC16F877A | C (MPLAB X + XC8) |
| IoT bridge | ESP8266 NodeMCU v3 | C++ (PlatformIO) |
| AI inference | Raspberry Pi 4 (4 GB) | Python 3, TFLite |
| Mobile app | Android / iOS | Flutter (Dart) |

## Architecture

```
[Sensors] → [PIC16F877A] ←UART→ [ESP8266] ←MQTT/REST→ [Firebase RTDB]
                 ↑                                              ↓
           [NEMA17 + Pump]                             [Flutter App]
                 ↑
           [Raspberry Pi 4] ←CSI→ [Pi Camera v2]
             TFLite INT8
```

## Repository Structure

| Folder | Contents | Owner |
|--------|----------|-------|
| `pic-firmware/` | PIC16F877A MPLAB X project — safety FSM, ADC scan, motion control, UART | M1 + M2 |
| `esp-firmware/` | ESP8266 PlatformIO project — bidirectional Firebase bridge | M4 |
| `pi-ai/` | Raspberry Pi inference daemon, action protocol generator, systemd service | M3 |
| `ml-pipeline/` | MobileNetV2 fine-tuning notebook, dataset scripts, TFLite export | M3 |
| `flutter-app/` | Flutter mobile application (dashboard, actuator control, AI monitor) | M4 |
| `mechanical/` | CAD source files, print-ready STLs, print settings | M5 |
| `docs/` | Project report, circuit schematics, component datasheets | All |

See [`STREAMS.md`](STREAMS.md) for full team ↔ folder mapping and gate criteria.

## Quick Start

### PIC Firmware
```bash
# Open in MPLAB X IDE
File → Open Project → pic-firmware/mplab-project/smart_irrigation.X
# Select PICkit 3/4, build and program
```

### ESP8266 Firmware
```bash
cd esp-firmware
pio run --target upload --upload-port /dev/ttyUSB0
```

### Raspberry Pi AI Daemon
```bash
cd pi-ai
pip install -r requirements.txt
python inference/daemon.py --model ../ml-pipeline/models/mobilenetv2_int8.tflite
# Or via systemd:
sudo cp systemd/irrigation-ai.service /etc/systemd/system/
sudo systemctl enable --now irrigation-ai
```

### Flutter App
```bash
cd flutter-app
flutter pub get
flutter run
```

### ML Pipeline (training)
```bash
cd ml-pipeline
pip install -r requirements.txt
jupyter notebook notebooks/train_mobilenetv2.ipynb
```

## UART Frame Protocol

| Direction | Start | Frame | Purpose |
|-----------|-------|-------|---------|
| App → PIC | `0xCC` | `[0xCC][CMD][P1][P2][CRC][0xDD]` | Pump, gantry, e-stop |
| AI → PIC | `0xBB` | `[0xBB][PROTO][ZONE_X][0x00][P1][P2][CRC][0xEE]` | AI action protocols |
| PIC → ESP | `0xAA` | `[0xAA][S0][S1][S2][S3][STATUS][CRC][0x55]` | Telemetry |
| PIC → ESP | `0xAC` | `[0xAC][ACK/NACK][CMD_ECHO][0x55]` | Command ACK |

## Safety Features

1. **Dry-run protection** — HC-SR04 water level → warning (amber LED) → pump lockout
2. **Overwatering protection** — soil moisture threshold → warning → irrigation halt
3. **Overcurrent protection** — ACS712 current → warning → full system shutdown
4. **Overheat protection** — LM35 temperature → warning → motor + pump shutdown

Priority: `Safety > AI Protocol > App Command > Scheduled Irrigation`

## ML Model

- Architecture: MobileNetV2 fine-tuned, TFLite INT8 quantised
- Classes: 6 (healthy, leaf_spot, blight, pest, wilt, nutrient_deficiency)
- Target accuracy: ≥ 92% (post-quantisation ≥ 90%)
- Inference time: < 200 ms on Raspberry Pi 4
- Dataset + model: [HuggingFace — link TBA]

## Hardware BOM Summary

Full BOM in [`docs/report/`](docs/report/). Key components:

- PIC16F877A-I/P, NodeMCU v3, Raspberry Pi 4 (4 GB), Pi Camera v2
- Capacitive soil moisture v1.2, LM35DZ, HC-SR04, ACS712-05B
- NEMA17 (JK42HS40) + A4988 driver, 12 V DC pump, 2-ch relay
- 2× 500 mm 2020 V-slot extrusion, 1× 8 mm smooth rod, 2× LM8UU bearings

## Demo & Submission Dates

| Milestone | Date |
|-----------|------|
| G0 — Environment ready | End of Week 1 |
| G1 — Sensors + safety validated | End of Week 2 |
| G2 — Subsystems standalone | End of Week 3 |
| G3 — Full comm chain linked | End of Week 4 |
| G4 — Demo ready | End of Week 5 |
| Live demo + discussion | 17–21 May 2026 |
| Final submission | Day of Final Exam |

## Team

| Member | Stream | Role |
|--------|--------|------|
| Ahmed (leader) | A | Analog sensors, ADC, safety algorithms |
| M2 | A | Stepper control, UART, command priority engine |
| M3 | B | ML pipeline, Pi inference daemon |
| M4 | C | ESP8266 firmware, Flutter app |
| M5 | D | 3D design, mechanical assembly |

## License

MIT
