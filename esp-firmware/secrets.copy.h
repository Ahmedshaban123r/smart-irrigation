// /*
//  * secrets.copy.h — template for esp-firmware/secrets.h.
//  *
//  * This file IS committed. It documents which macros `esp.ino` expects so a
//  * new collaborator can reproduce the build without leaking real credentials.
//  *
//  * Setup:
//  *   1. Copy this file to `secrets.h` in the same directory:
//  *        cp esp-firmware/secrets.copy.h esp-firmware/secrets.h
//  *   2. Fill in the real values in `secrets.h`.
//  *   3. Confirm `git status` does NOT list `secrets.h` — it is matched by the
//  *      repository .gitignore (`**/secrets.h`).
//  *   4. Build and flash as usual.
//  *
//  * Never paste real credentials into THIS file. Real values live only in
//  * `secrets.h`, which is gitignored.
//  */

#pragma once

// ─── Wi-Fi ───────────────────────────────────────────────────────────────────
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// ─── Firebase ────────────────────────────────────────────────────────────────
// Web API key from Firebase Console → Project settings → General → Web API Key
#define API_KEY "YOUR_FIREBASE_WEB_API_KEY"
// Realtime Database URL, e.g. https://<project-id>-default-rtdb.firebaseio.com/
#define DATABASE_URL "https://YOUR_PROJECT-default-rtdb.firebaseio.com/"
