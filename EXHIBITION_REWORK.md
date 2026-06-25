# Exhibition Rework — Handoff Notes

> Purpose: continue the conversation about retargeting the smart-irrigation project from
> the original graded topology (PIC + ESP8266 + Pi) to a simpler, more reliable
> **exhibition** build. This file captures decisions, open questions, and the next
> concrete steps so work can resume on a different machine.

---

## 1. Context

- The original project (described in `README.md`) is **already submitted and graded**.
- This rework is for an **exhibition demo only** — no rubric, no stream ownership,
  no PIC firmware requirement.
- Primary goal: **make it work reliably on a demo table.** Visual polish second.
- Original pain point: "a lot of things were not working correctly" with the
  3-MCU topology (PIC + ESP8266 + Pi). Exact failures were not enumerated — worth
  re-confirming before committing to the rewrite.

---

## 2. Direction we landed on

**Drop the PIC firmware and the ESP8266 entirely. Move to a Pi-centric topology
with an ESP32 (already on hand) as a helper for the analog signals.**

Reasons:
- Pi has no native ADC, so something must read the capacitive soil sensor and the
  ACS712 current sensor.
- ESP8266 has only **one** ADC channel — not enough for two analog sensors without
  a mux, so it's a bad fit.
- ESP32 has 8+ usable ADC channels, Wi-Fi, BT, and is already verified working
  (see §4). It can either:
  - act as a wireless sensor node pushing readings to Firebase (matches the
    existing app), **or**
  - act as a wired ADC/IO expander to the Pi over UART/I²C.
- Alternative still on the table: skip the ESP32 and put an **ADS1115** (4-ch
  16-bit I²C ADC) on the Pi directly. Cheapest and most reliable, but loses the
  "wireless sensor node" demo factor.

**Decision still open:** ESP32-as-Wi-Fi-sensor-node vs. Pi + ADS1115.
Pick before ordering/wiring anything new.

---

## 3. Power topology (agreed)

Two-supply layout — strongly recommended for exhibition reliability:

| Rail | Source | Feeds |
|---|---|---|
| 12 V / 5 A SMPS brick | Wall plug | Pump + stepper Vmot (A4988) only |
| 5 V / 3 A USB-C | Official Pi PSU | Raspberry Pi only |
| 3.3 V | Pi's onboard regulator | Sensors, ADS1115, ESP32 3V3 pin (low current only) |

**Mandatory protection:**
- Flyback diode (1N4007 min) across the pump
- 1000–2200 µF bulk cap on the 12 V rail near the motor/pump
- Star ground: motor return current must NOT flow through Pi GND
- Power Pi via USB-C, not the GPIO 5 V pin

**Do not use:**
- LM7805 to drop 12 V → 5 V for the Pi (cooks the regulator)
- Cheap LM2596 modules for the Pi rail (ripple → undervoltage resets)

If single-supply is required, use a quality switching buck (Pololu D24V50F5 or
Mean Well DDR-15G-5).

---

## 4. Hardware status — verified

**ESP32 board on hand:** ESP32-D0WDQ6 rev 1.0, dual-core 240 MHz, Wi-Fi + BT.
- MAC: `40:22:d8:04:51:68`
- Enumerates as COM4 on this machine (CP2102 USB-UART)
- Bootloader responds to `python -m esptool --port COM4 chip-id` — chip is fully
  functional, flash accessible, reset circuitry works.
- Wi-Fi scan example has **not yet been confirmed** — blocked on §5.

---

## 5. Open blocker — Arduino IDE / ESP32 core install

When trying to install the ESP32 board core in Arduino IDE, install **failed with
a network timeout**:

```
Failed to install platform: 'esp32:esp32:3.3.10'.
Error: 4 DEADLINE_EXCEEDED: net/http: request canceled
       (Client.Timeout or context cancellation while reading body)
```

The download that timed out is `esp32:esp-rv32@2601` (≈140 MB toolchain).

### Things to try, in order

1. **Just retry the install 2–3 times.** Partial downloads are cached; it often
   completes on the second attempt.
2. **Bump the CLI network timeout.** Edit `C:\Users\Abdullah\AppData\Local\Arduino15\arduino-cli.yaml`
   and add:
   ```yaml
   network:
     connection_timeout: 600s
   ```
   Then restart the IDE and retry.
3. **Switch network.** Try a phone hotspot — campus Wi-Fi is the most common
   culprit for throttled GitHub/Espressif CDN downloads.
4. **Install older core.** In Boards Manager, pick **2.0.17** instead of 3.3.10.
   Smaller download, works fine for Wi-Fi/GPIO/ADC. Upgrade later if needed.

### Important board-selection note (already burned an hour on this)

The first Arduino IDE upload attempt failed with **"No DFU capable USB device
available"** because the board was set to **"Arduino Nano ESP32"** (FQBN
`arduino:esp32:nano_nora`). That is a different product with an ESP32-**S3** chip
that uploads via DFU.

Our board is the **original ESP32**. Correct selection once the Espressif core is
installed:

- Tools → Board → **esp32** (Espressif Systems) → **ESP32 Dev Module**
- Tools → Port → COM4

NOT the "Arduino ESP32 Boards" core.

---

## 6. Things NOT to touch in the repo

The existing PIC/ESP8266/Pi work is committed and represents the graded
deliverable. **Do not delete or rewrite** anything under:

- `pic-firmware/`
- `esp-firmware/`
- `default.hex`
- `Report and Feasibilty Study/`

Exhibition rework should live in **new** folders (e.g. `esp32-firmware/`,
`exhibition/`) so the graded artefacts stay intact in git history.

---

## 7. Concrete next steps (resume here)

In order:

1. **Confirm what was actually failing** in the original setup. UART? ESP Wi-Fi
   drops? DHT11 timing? Safety lockouts? This decides how much of the old
   firmware logic needs to be rewritten vs. just re-hosted.
2. **Resolve the Arduino IDE install blocker** (§5).
3. **Run the WiFiScan example** on the ESP32 to confirm the radio works.
4. **Pick the topology** (§2): ESP32-as-Wi-Fi-sensor-node OR Pi + ADS1115. Don't
   wire anything until this is decided.
5. **Verify the pump's rated current** — decides whether a 12 V / 3 A brick is
   enough or a 5 A one is needed (§3).
6. Sketch the Pi-side Python that replaces `pi_controller.py`'s UART path with
   direct sensor reads (either from ESP32 over Wi-Fi/Firebase or from ADS1115
   over I²C).
7. Keep the Firebase schema in `README.md` §9 unchanged so the existing Flutter
   app keeps working without modification.

---

## 8. Decisions still open

- **Topology**: ESP32 wireless sensor node vs. Pi + ADS1115. (§2)
- **Whether to keep the ESP8266 as the pump relay node** or fold the pump into
  the Pi GPIO. (Original ESP8266 sketch in `esp-firmware/esp.ino` is fine and
  could be reused as-is if kept.)
- **Whether to keep the LCD** on the exhibition build, or rely on the phone app
  as the sole display.
- **Exhibition date / deadline** — not captured. Affects how aggressive the
  rework should be.

---

*Generated mid-conversation. Update this file as decisions are made so the next
session can pick up cleanly.*
