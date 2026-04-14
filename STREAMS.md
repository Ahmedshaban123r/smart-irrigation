# Stream ↔ Folder Mapping

This file maps each execution stream to its primary repository folder(s),
the responsible member(s), and the relevant gate criteria.

---

## Stream A — Hardware + Safety (M1 + M2)

**Folders:** `pic-firmware/`

| Sub-folder | Contents | Owner |
|------------|----------|-------|
| `pic-firmware/src/` | `.c` source files — ADC scan, safety FSM, UART ISR, motion control, LCD, keypad | M1 + M2 |
| `pic-firmware/include/` | `.h` header files — pin definitions, thresholds, structs | M1 + M2 |
| `pic-firmware/mplab-project/` | MPLAB X project files (`.X` directory, `Makefile`) | M2 |

**Gate responsibilities:**
- G1: All 4 ADC channels ±5%, safety features fire at correct thresholds
- G2: UART frames sent/received, command priority engine working
- G3: Full app + AI command loop verified, safety blocks both

---

## Stream B — ML + AI Actuation (M3)

**Folders:** `pi-ai/`, `ml-pipeline/`

| Sub-folder | Contents | Owner |
|------------|----------|-------|
| `pi-ai/inference/` | `daemon.py`, `preprocess.py`, `capture.py` | M3 |
| `pi-ai/protocols/` | `action_protocol.py` — generates 8-byte UART packets from inference output | M3 |
| `pi-ai/systemd/` | `irrigation-ai.service` systemd unit file | M3 |
| `ml-pipeline/notebooks/` | `train_mobilenetv2.ipynb` — full training, evaluation, confusion matrix | M3 |
| `ml-pipeline/dataset/` | Dataset download scripts, label mapping, augmentation pipeline | M3 |
| `ml-pipeline/models/` | `mobilenetv2_int8.tflite`, `labels.txt`, `model_card.md` | M3 |

**Gate responsibilities:**
- G1: Training complete, ≥92% test accuracy
- G2: TFLite model on Pi generates correct action protocol packets
- G3: Pi → PIC UART link tested, all 6 protocols end-to-end

**HuggingFace:** Model + dataset + notebook pushed by G4. Cite in README.

---

## Stream C — IoT + Mobile App (M4)

**Folders:** `esp-firmware/`, `flutter-app/`

| Sub-folder | Contents | Owner |
|------------|----------|-------|
| `esp-firmware/src/` | `main.cpp`, `firebase.cpp`, `uart_bridge.cpp`, `spiffs_buffer.cpp` | M4 |
| `esp-firmware/include/` | `config.h` (WiFi creds template), `frame_defs.h` | M4 |
| `flutter-app/` | Full Flutter project — `lib/`, `pubspec.yaml`, `android/`, `ios/` | M4 |

**Gate responsibilities:**
- G1: ESP pushes JSON to Firebase, reads commands
- G2: Bidirectional firmware — SPIFFS buffer, ACK/NACK handler
- G3: Full app → Firebase → ESP → PIC → actuator → ACK → app loop verified
- G4: Release APK built and uploaded

**UART protocol note:** M4 must agree with M2 on frame format by **end of Week 1**.
Reference: `pic-firmware/include/frame_defs.h` (M2 owns this file — M4 mirrors it in `esp-firmware/include/frame_defs.h`).

---

## Stream D — 3D Design + Mechanical (M5)

**Folder:** `mechanical/`

| Sub-folder | Contents | Owner |
|------------|----------|-------|
| `mechanical/cad/` | OpenSCAD source files (`.scad`) for all 6 printed parts | M5 |
| `mechanical/stl/` | Print-ready STL exports | M5 |
| `mechanical/print-settings/` | Slicer profiles (`.3mf` or `.ini`), print settings table | M5 |

**Gate responsibilities:**
- G1: All STLs exported, parts ordered
- G2: Control box and gantry brackets printed and test-fitted
- G3: Gantry fully assembled, wiring harness built, electronics mounted
- G4: Demo photos + video recorded and uploaded

---

## Cross-Stream Dependencies (Critical Path)

| Dependent | Depends On | By Gate | Mitigation |
|-----------|-----------|---------|------------|
| `pi-ai/` UART link | `pic-firmware/` UART ISR | G2 | Use USB-serial stub until M2 is ready |
| `esp-firmware/` frame parsing | `pic-firmware/` frame format | G1 | M2 + M4 agree on `frame_defs.h` by Week 1 |
| App → PIC command test | ESP + PIC UART working | G2 | Test with ESP-only loopback |
| `mechanical/` final mount | All electronics stable | G3 | Use dummy boards for fitment in Weeks 2–3 |

---

## Commit Convention

```
[stream-a] Add safety FSM for dry-run protection
[stream-b] Add TFLite INT8 export script
[stream-c] Wire Firebase RTDB schema
[stream-d] Add carriage plate OpenSCAD v2
[docs]     Update BOM with 1-axis redesign
```

Use `[stream-a]` through `[stream-d]` prefixes so commits are filterable by stream.
