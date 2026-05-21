#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ─── Credentials ─────────────────────────────────────────────
// Real values live in secrets.h (gitignored). Copy secrets.copy.h to
// secrets.h and fill it in before building. Macros expected:
//   WIFI_SSID, WIFI_PASSWORD, API_KEY, DATABASE_URL
#include "secrets.h"

// ─── Pin & Timing ────────────────────────────────────────────
#define PUMP_RELAY       D1
#define PUMP_ON_MS       5000   // 5 s — matches PIC PUMP_ON_TICKS × 100 ms
#define POLL_INTERVAL_MS 1000   // Firebase poll cadence

// ─── Firebase Objects ────────────────────────────────────────
FirebaseData   fbdo;
FirebaseConfig config;
FirebaseAuth   auth;
bool signupOK = false;

unsigned long lastPollTime = 0;

// ─── Pump Control ────────────────────────────────────────────
void setPump(bool on) {
    digitalWrite(PUMP_RELAY, on ? LOW : HIGH);  // relay active LOW
    Serial.printf("[PUMP] %s\n", on ? "ON" : "OFF");
}

// ─── Firebase Init ───────────────────────────────────────────
void firebaseInit() {
    config.api_key      = API_KEY;
    config.database_url = DATABASE_URL;

    if (Firebase.signUp(&config, &auth, "", "")) {
        Serial.println("[Firebase] Sign up OK");
        signupOK = true;
    } else {
        Serial.println("[Firebase] Sign up FAILED: " + String(config.signer.signupError.message.c_str()));
    }

    config.token_status_callback = tokenStatusCallback;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
    delay(100);
    Serial.println("[Firebase] Init done.");
}

// ─── Setup ───────────────────────────────────────────────────
void setup() {
    Serial.begin(115200);
    delay(200);

    pinMode(PUMP_RELAY, OUTPUT);
    setPump(false);  // pump OFF at boot

    Serial.print("\n[WiFi] Connecting to ");
    Serial.println(WIFI_SSID);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\n[WiFi] Connected! IP: " + WiFi.localIP().toString());

    firebaseInit();
    Serial.println("[System] Ready — polling esp/pump/state\n");
}

// ─── Main Loop ───────────────────────────────────────────────
void loop() {
    if (!signupOK) return;

    // WiFi watchdog
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("[WiFi] Reconnecting...");
        WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
        unsigned long t = millis();
        while (WiFi.status() != WL_CONNECTED && millis() - t < 10000) {
            delay(500); Serial.print(".");
        }
        Serial.println(WiFi.status() == WL_CONNECTED ? "\n[WiFi] Reconnected." : "\n[WiFi] Failed.");
    }

    if (millis() - lastPollTime < POLL_INTERVAL_MS) return;
    lastPollTime = millis();

    if (!Firebase.ready()) {
        Serial.println("[Firebase] Not ready — skipping.");
        return;
    }

    if (!Firebase.RTDB.getString(&fbdo, "/esp/pump/state")) {
        // Node may not exist yet — not an error
        return;
    }

    String state = fbdo.stringData();
    state.trim();

    if (state != "ON") return;

    // Activate pump for PUMP_ON_MS, then clear the node
    setPump(true);
    delay(PUMP_ON_MS);
    setPump(false);

    Firebase.RTDB.setString(&fbdo, "/esp/pump/state", "OFF");
    Serial.println("[ESP] pump cycle done — node cleared");
}
