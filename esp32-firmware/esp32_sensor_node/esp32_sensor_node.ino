#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <DHT.h>

// ─── Feature flags ────────────────────────────────────────────
// Flip to true once the sensor is wired and voltage divider confirmed
#define CURRENT_ENABLED  false   // ACS712: needs 2kΩ/3kΩ divider on P35
#define SONAR_ENABLED    false   // HC-SR04: verify wiring + level-shift before enabling

// ─── Credentials ─────────────────────────────────────────────
#define WIFI_SSID     "Abdullah's Galaxy A52s 5G"
#define WIFI_PASSWORD "A7a12347"
#define API_KEY       "AIzaSyBdnBbVYOYoykE8aXM9tKAg0Jw94rq11P8"
#define DATABASE_URL  "https://embedded-project-32dca-default-rtdb.firebaseio.com"

// ─── Pins ────────────────────────────────────────────────────
// ADC1 only — ADC2 is disabled while Wi-Fi is active
#define SOIL_PIN     34   // capacitive soil sensor AOUT, powered 3V3
#define CURRENT_PIN  35   // ACS712-05B OUT via 10kΩ/20kΩ voltage divider
#define DHT_PIN       4   // DHT11 DATA (module pull-up built in)
#define DHT_TYPE      DHT11
#define PUMP_PIN     16   // Relay SIG — active LOW (LOW = pump ON, HIGH = pump OFF)
#define TRIG_PIN     26   // HC-SR04 TRIG — 3.3V may be marginal on some units; add level shifter if ECHO never rises
#define ECHO_PIN     25   // HC-SR04 ECHO — 5V output; protect with 1kΩ series resistor

// ─── Calibration ─────────────────────────────────────────────
#define SOIL_DRY    4095   // raw ADC reading in open air
#define SOIL_WET    1950   // raw ADC reading submerged in water

// ACS712-05B on 5V with 2kΩ/3kΩ divider to bring 0–5V → 0–3V at ESP32 pin:
//   midpoint (0 A) = 2.5V × (3/5) = 1.5V → raw ≈ 1861
//   sensitivity    = 185 mV/A × (3/5) = 111 mV/A at pin
#define CURRENT_ZERO  1861
#define MV_PER_AMP   111.0f

// ─── Timing ──────────────────────────────────────────────────
#define SEND_INTERVAL_MS  2000
#define PUMP_POLL_MS       500   // check pump command every 500ms for fast response

// ─── Firebase ────────────────────────────────────────────────
FirebaseData   fbdo;
FirebaseConfig config;
FirebaseAuth   auth;
bool signupOK = false;

DHT dht(DHT_PIN, DHT_TYPE);
unsigned long lastSendTime = 0;
unsigned long lastPumpPoll = 0;
bool pumpState = false;

// ─── Sensor functions ─────────────────────────────────────────

int readSoilPct() {
    int raw = analogRead(SOIL_PIN);
    return constrain(map(raw, SOIL_DRY, SOIL_WET, 0, 100), 0, 100);
}

float readCurrentA() {
    // 64-sample average to reduce ADC noise
    long sum = 0;
    for (int i = 0; i < 64; i++) {
        sum += analogRead(CURRENT_PIN);
        delayMicroseconds(200);
    }
    float mv = (sum / 64.0f / 4095.0f) * 3300.0f;
    return fabsf((mv - 1500.0f) / MV_PER_AMP);
}

float readWaterCm() {
    // If ECHO never rises: TRIG 3.3V too low for this HC-SR04 variant.
    // Fix: NPN transistor (2N2222) or 74HC125 to level-shift TRIG to 5V.
    // ECHO 5V → 1kΩ series resistor brings pin voltage to ~2.7V (safe for ESP32).
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(4);
    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);

    unsigned long t = micros();
    while (digitalRead(ECHO_PIN) == LOW) {
        if (micros() - t > 25000UL) return -1.0f;  // ECHO never rose
    }
    t = micros();
    while (digitalRead(ECHO_PIN) == HIGH) {
        if (micros() - t > 25000UL) return -1.0f;  // object too far / noise
    }
    return (micros() - t) * 0.01715f;  // µs × (34300 cm/s / 2 / 1e6)
}

// ─── Pump relay ──────────────────────────────────────────────
void checkPumpRelay() {
    if (Firebase.RTDB.getBool(&fbdo, "/commands/pump_relay")) {
        bool desired = fbdo.boolData();
        if (desired != pumpState) {
            pumpState = desired;
            digitalWrite(PUMP_PIN, desired ? LOW : HIGH);
            Serial.printf("[Pump] %s\n", desired ? "ON" : "OFF");
        }
    }
}

// ─── Wi-Fi ───────────────────────────────────────────────────
void wifiConnect() {
    if (WiFi.status() == WL_CONNECTED) return;
    Serial.print("[WiFi] Connecting");
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    unsigned long t = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - t < 15000) {
        delay(500);
        Serial.print(".");
    }
    if (WiFi.status() == WL_CONNECTED)
        Serial.println("\n[WiFi] Connected: " + WiFi.localIP().toString());
    else
        Serial.println("\n[WiFi] Failed — will retry next cycle");
}

// ─── Setup ───────────────────────────────────────────────────
void setup() {
    Serial.begin(115200);
    delay(200);

    pinMode(PUMP_PIN, OUTPUT);
    digitalWrite(PUMP_PIN, HIGH);   // active-LOW relay: HIGH = pump OFF at boot

    if (SONAR_ENABLED) {
        pinMode(TRIG_PIN, OUTPUT);
        pinMode(ECHO_PIN, INPUT);
        digitalWrite(TRIG_PIN, LOW);
    }
    dht.begin();
    wifiConnect();

    config.api_key      = API_KEY;
    config.database_url = DATABASE_URL;

    if (Firebase.signUp(&config, &auth, "", "")) {
        signupOK = true;
        Serial.println("[Firebase] Auth OK");
    } else {
        Serial.println("[Firebase] Auth FAILED: " +
                       String(config.signer.signupError.message.c_str()));
    }

    config.token_status_callback = tokenStatusCallback;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
    Serial.println("[System] Ready");
}

// ─── Loop ────────────────────────────────────────────────────
void loop() {
    wifiConnect();
    if (!signupOK || !Firebase.ready()) return;

    // Poll pump relay command every 500ms
    if (millis() - lastPumpPoll >= PUMP_POLL_MS) {
        lastPumpPoll = millis();
        checkPumpRelay();
    }

    // Send sensor data every 2s
    if (millis() - lastSendTime < SEND_INTERVAL_MS) return;
    lastSendTime = millis();

    int   soil    = readSoilPct();
    float current = CURRENT_ENABLED ? readCurrentA() : 0.0f;
    float water   = SONAR_ENABLED   ? readWaterCm()  : -1.0f;
    float temp    = dht.readTemperature();
    float hum     = dht.readHumidity();

    if (isnan(temp) || isnan(hum)) {
        Serial.println("[DHT] Read failed — skipping cycle");
        return;
    }

    FirebaseJson json;
    json.set("soil_moisture_pct", soil);
    json.set("current",           current);
    json.set("temperature",       temp);
    json.set("humidity",          (int)hum);

    if (Firebase.RTDB.updateNode(&fbdo, "/sensors", &json)) {
        Serial.printf("[OK] soil=%d%% cur=%.2fA temp=%.1fC hum=%d%%\n",
                      soil, current, temp, (int)hum);
    } else {
        Serial.println("[Firebase] Write failed: " + fbdo.errorReason());
    }
}
