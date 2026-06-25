"""
exhibition/test_firebase_live.py

Live Firebase connectivity test — run ON THE PI with real credentials.
No hardware needed. Requires firebase-key.json and network access.

Usage:
    python3 test_firebase_live.py
    python3 test_firebase_live.py /path/to/firebase-key.json   # override key path
"""

import sys
import time

KEY_PATH = sys.argv[1] if len(sys.argv) > 1 else "/home/robox/Final_Project/firebase-key.json"
DB_URL   = "https://embedded-project-32dca-default-rtdb.firebaseio.com"

_results = []

def check(name, condition, detail=""):
    _results.append((name, condition))
    suffix = f"  [{detail}]" if detail else ""
    print(f"  {'[OK]' if condition else '[!!]'} {'PASS' if condition else 'FAIL'}  {name}{suffix}")

# ── 1. Import firebase_admin ──────────────────────────────────────────────────
print("\n[1] Import firebase_admin")
try:
    import firebase_admin
    from firebase_admin import credentials, db
    check("firebase_admin importable", True)
except ImportError as e:
    check("firebase_admin importable", False, str(e))
    print("\n  Install: pip3 install firebase-admin")
    sys.exit(1)

# ── 2. Key file readable ──────────────────────────────────────────────────────
print("\n[2] Key file")
try:
    import json, os
    check("key file exists",     os.path.isfile(KEY_PATH), KEY_PATH)
    with open(KEY_PATH) as f:
        key = json.load(f)
    check("key file valid JSON", True)
    check("project_id present",  "project_id" in key, key.get("project_id", "MISSING"))
    check("private_key present", "private_key" in key)
    check("client_email present","client_email" in key, key.get("client_email", "MISSING"))
except Exception as e:
    check("key file readable",   False, str(e))
    sys.exit(1)

# ── 3. Initialize app ─────────────────────────────────────────────────────────
print("\n[3] Firebase app init")
try:
    cred = credentials.Certificate(KEY_PATH)
    firebase_admin.initialize_app(cred, {"databaseURL": DB_URL})
    check("app initialized", True)
except Exception as e:
    check("app initialized", False, str(e))
    sys.exit(1)

# ── 4. Write test marker ──────────────────────────────────────────────────────
print("\n[4] Write to /test/ping")
ts = int(time.time())
try:
    db.reference("test").update({"ping": ts, "source": "pi_live_test"})
    check("write succeeded", True)
except Exception as e:
    check("write succeeded", False, str(e))

# ── 5. Read back ──────────────────────────────────────────────────────────────
print("\n[5] Read back /test/ping")
try:
    val = db.reference("test/ping").get()
    check("read succeeded",      val is not None)
    check("value matches write", val == ts, f"wrote {ts}, got {val}")
except Exception as e:
    check("read succeeded", False, str(e))

# ── 6. Read /sensors/ (ESP32 data) ───────────────────────────────────────────
print("\n[6] Read /sensors/ — check ESP32 is publishing")
try:
    sensors = db.reference("sensors").get() or {}
    check("/sensors/ readable",             True)
    check("soil_moisture_pct present",      "soil_moisture_pct" in sensors,
          str(sensors.get("soil_moisture_pct", "MISSING")))
    check("temperature present",            "temperature" in sensors,
          str(sensors.get("temperature",    "MISSING")))
    check("humidity present",               "humidity" in sensors,
          str(sensors.get("humidity",       "MISSING")))
    soil = sensors.get("soil_moisture_pct", -1)
    check("soil reading plausible (>0%)",   int(soil) > 0,
          f"got {soil}% — ESP32 connected?")
except Exception as e:
    check("/sensors/ readable", False, str(e))

# ── 7. Read /status/ (Pi wrote this on boot) ─────────────────────────────────
print("\n[7] Read /status/ — check Pi seeded correctly")
try:
    status = db.reference("status").get() or {}
    check("/status/ readable",              True)
    check("system_state present",           "system_state" in status,
          status.get("system_state", "MISSING"))
    check("pump present",                   "pump" in status,
          status.get("pump", "MISSING"))
    check("mode present",                   "mode" in status,
          status.get("mode", "MISSING"))
except Exception as e:
    check("/status/ readable", False, str(e))

# ── 8. Write a command and read it back ──────────────────────────────────────
print("\n[8] Round-trip command write/read")
try:
    cmd_ts = int(time.time())
    db.reference("commands/test_cmd").set({"ts": cmd_ts, "val": "live_test"})
    time.sleep(0.5)
    result = db.reference("commands/test_cmd").get()
    check("command write succeeded",  result is not None)
    check("command read-back matches", result.get("ts") == cmd_ts if result else False)
    db.reference("commands/test_cmd").delete()
    check("command cleanup succeeded", True)
except Exception as e:
    check("command round-trip", False, str(e))

# ── 9. Clean up test marker ───────────────────────────────────────────────────
print("\n[9] Cleanup /test/")
try:
    db.reference("test").delete()
    check("test node deleted", True)
except Exception as e:
    check("test node deleted", False, str(e))

# ── Summary ───────────────────────────────────────────────────────────────────
passed = sum(1 for _, ok in _results if ok)
total  = len(_results)
failed = total - passed

print("\n" + "=" * 60)
print(f"  {passed}/{total} passed", end="")
if failed:
    print(f"  |  {failed} FAILED:")
    for name, ok in _results:
        if not ok:
            print(f"    [!!] {name}")
else:
    print("  -- Firebase fully reachable")
print("=" * 60)
