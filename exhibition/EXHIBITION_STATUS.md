# Exhibition Build — Status Report

**Last updated:** 2026-06-21

---

## Completed

### ESP32 Sensor Node + Pump Relay (`esp32-firmware/esp32_sensor_node/esp32_sensor_node.ino`)
- Reads DHT11 (temp/humidity), soil moisture sensor
- Pushes to Firebase `/sensors/` every 2s: `soil_moisture_pct`, `temperature`, `humidity`, `current`
- **Pump relay on GPIO16** — polls `commands/pump_relay` from Firebase every 500ms
- Active LOW relay: LOW = pump ON, HIGH = pump OFF
- Current sensor & sonar disabled via feature flags (hardware not wired)
- Removed dead `water_level_cm` field from Firebase push

### Pi Controller (`exhibition/pi_controller_exhibition.py`) — UNIFIED WITH AI
- **Unified pump_action**: reads `commands/pump_action/{state, plant, timestamp}` — app sends plant index + ON/OFF, Pi moves gantry then sends pump command to ESP32 via Firebase `commands/pump_relay`
- **AI inference built in**: captures image + runs TFLite model when gantry arrives at each plant
- **Auto-scan mode**: cycles through 2 plants → move → settle 3s → capture+infer → check soil → pump if <30% → next plant. 120s interval between scans
- **Emergency stop**: kills pump, aborts stepper, buzzer alarm loop, FAULT state
- **Mode switching**: AUTOMATIC (auto-scan) / MANUAL (app-driven pump_action)
- **Entropy-based Unknown**: entropy > threshold → "Unknown" class
- **Temporal smoothing**: 5-frame sliding window majority vote
- LED indicators: green=normal, red=fault, yellow=auto, blue=pump active
- Buzzer patterns: boot, pump-on, dry-soil alert, e-stop alarm
- Stepper motor gantry: 200 steps/plant, abort-safe mid-move
- **Pump relay on ESP32** — Pi writes `commands/pump_relay` to Firebase, ESP32 toggles GPIO16

### GPIO Alignment (2026-06-22)
Code aligned to `smart_irrigation_pinout_reference.md`:

**Raspberry Pi GPIO (BCM):**

| Function | GPIO | Pi Pin |
|----------|------|--------|
| Stepper STEP | 20 | Pin 38 |
| Stepper DIR | 21 | Pin 40 |
| Buzzer | 22 | Pin 15 |
| Green LED | 5 | Pin 29 |
| Red LED | 6 | Pin 31 |
| Yellow LED | 13 | Pin 33 |
| Blue LED | 27 | Pin 13 |

**ESP32 GPIO:**

| Function | GPIO | Notes |
|----------|------|-------|
| Pump Relay SIG | 16 | Active LOW — moved from Pi GPIO17 |
| Soil Moisture | 34 | ADC1_CH6 |
| ACS712 OUT | 35 | ADC1_CH7, via voltage divider |
| DHT11 DATA | 4 | Module pull-up |

DRV8825 (not A4988) — has FLT pin instead of VDD. No VDD needed (internal regulator from VMOT).
ENABLE not wired (internally pulled low = always enabled). RESET/SLEEP must be jumpered together. FLT not connected.
Pump relay now on ESP32 — Pi sends `commands/pump_relay` via Firebase, ESP32 polls every 500ms.

### Camera — OpenCV (not picamera2)
- Ubuntu 22.04 has old libcamera (2020) — picamera2 won't install
- All scripts use `cv2.VideoCapture(0, cv2.CAP_V4L2)` with MJPG fourcc
- USB camera: DV20 USB (Jieli Technology) at `/dev/video0`
- Resolution: 1280×720 (cleanest — no JPEG corruption)
- Inference speed: ~100ms per frame on Pi 4

### Pi AI Daemon (`exhibition/pi_daemon_exhibition.py`) — OPTIONAL
- Standalone version (controller has AI built in now)
- Same 3-class inference, entropy Unknown, temporal smoothing
- Uses OpenCV camera, pushes to `ai/latest_detection/`

### Test Script (`exhibition/test_camera_inference.py`)
- Standalone camera + model test — no GPIO, no Firebase
- `--image` flag for single image test (no camera needed)
- Verified working: model loads, inference runs, entropy gate works

### ML Pipeline (`embedded-project-v2.ipynb` + `build_notebook.py`)
- **3-class MobileNetV2** transfer learning (freeze first 100 layers)
- **Background randomization**: PlantVillage leaves segmented + pasted on DTD textures
- **Pi camera domain mixing**: real camera images (30 photos) augmented 50× each, mixed into training pool
- Pi camera holdout evaluation on never-seen originals
- INT8 TFLite quantization pipeline
- Entropy threshold calibration cell (threshold = 0.4115)
- Label smoothing (0.1), Dropout(0.4), patience 5, 25 epochs
- **Model trained and deployed to Pi** ✓

### Flutter App — All Files Updated
- **`firebase_service.dart`** — routes through `commands/pump_action`, removed 11 dead paths
- **`protocol_definition.dart`** — 3 classes + Unknown, removed Pest & Nutrient_Deficiency
- **`ai_monitor_screen.dart`** — removed dead Active Protocol card & Action History, shows entropy value
- **`actuator_screen.dart`** — uses `commands/pump_action`, shows gantry plant position
- **`command_parser.dart`** — 3 commands (e-stop, pump on/off with plant index)
- **`notification_service.dart`** — simplified to detection + mode change notifications
- **`home_screen.dart`** — updated text (early blight and late blight)
- **`detection_card.dart`** — updated class colors, added Unknown
- **`command_parser_test.dart`** — updated for new command set

### Firebase Schema (`exhibition/firebase_schema.json`)
```
sensors/          ← ESP32 writes
  soil_moisture_pct, temperature, humidity, current

commands/         ← App writes + Pi writes
  emergency_stop: bool
  pump_action: {state, plant, timestamp}   ← App writes
  pump_relay: bool                         ← Pi writes, ESP32 reads (true=ON)

status/           ← Pi controller writes
  mode, pump, gantry_plant, system_state

ai/               ← Pi controller writes (during capture)
  latest_detection: {class, confidence, entropy, timestamp, source}

alerts/           ← App writes
  history: {push-id: {message, severity, timestamp}}
```

### Pi Environment
- **IP:** 192.168.1.37
- **User:** robox
- **Path:** `/home/robox/Final_Project/`
- **OS:** Ubuntu 22.04 Jammy (arm64)
- **apt fix:** removed amd64 foreign architecture
- **Python:** 3.10, no venv, user pip installs
- **Packages:** firebase-admin, RPi.GPIO, ai-edge-litert, cv2 4.5.4, numpy 1.26.4, PIL

---

## Current Blockers

### 1. Stepper Motor Not Moving
GPIO20 pulsing from code but motor doesn't respond. Check physically:
- [ ] DRV8825 RESET and SLEEP pins jumpered together (wire bridge)
- [ ] 12V supply connected to DRV8825 VMOT
- [ ] Vref calibrated: start 0.2V, max 0.4V (Vref = I_limit / 2)
- [ ] Wire from Pi Pin 38 goes to DRV8825 STEP pin
- [ ] Wire from Pi Pin 40 goes to DRV8825 DIR pin
- [ ] FLT pin left unconnected (no VDD needed — internal regulator)
- [ ] Motor coil pairs correct (check continuity with multimeter)

### 2. Soil Sensor Reads 0%
ESP32 GPIO34 — hardware wiring issue. Verify VCC→3V3, GND, AOUT→P34.

---

## Next Steps

1. **Fix stepper motor** — check A4988 checklist above
2. **Fix soil sensor wiring** — ESP32 GPIO34
3. **Update systemd service** — `irrigation-exhibition.service` for new unified script
4. **Build Flutter APK** — `flutter build apk --release`, install on demo phone
5. **End-to-end test** — app → Firebase → Pi (gantry + pump + AI) → Firebase → app
6. **Test with printed leaves** — point camera at leaf printouts, verify classifications

### Nice-to-Have
- Camera image upload to Firebase Storage (show captured image in app)
- Soil moisture per-plant (currently one sensor pretending to be two)
