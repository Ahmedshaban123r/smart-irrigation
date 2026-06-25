/*
 * ESP32 Stepper Test — DRV8825
 * Bypasses Pi to verify DRV8825 + motor work.
 * 1/8 microstepping for smooth motion.
 *
 * Wiring:
 *   ESP32 GPIO 16 → DRV8825 STEP
 *   ESP32 GPIO 17 → DRV8825 DIR
 *   ESP32 GPIO 18 → DRV8825 M0
 *   ESP32 GPIO 19 → DRV8825 M1
 *   ESP32 GPIO 21 → DRV8825 M2
 *   ESP32 GND     → DRV8825 GND
 *   12V supply    → DRV8825 VMOT + GND
 *   DRV8825 RESET ↔ SLEEP (jumper together)
 *   100µF cap across VMOT and GND
 */

#define STEP_PIN 16
#define DIR_PIN  17
#define M0_PIN   18
#define M1_PIN   19
#define M2_PIN   21

#define STEPS_PER_REV 200
#define MICROSTEP     8      // 1/8 step
#define RPM           10

const int effectiveSteps = STEPS_PER_REV * MICROSTEP;  // 1600
const float stepDelay = 60.0 / (RPM * effectiveSteps) * 1000000.0;  // microseconds

void setMicrostep(int mode) {
    // DRV8825 truth table
    int m0 = 0, m1 = 0, m2 = 0;
    switch (mode) {
        case 1:  m0=0; m1=0; m2=0; break;  // full
        case 2:  m0=1; m1=0; m2=0; break;  // 1/2
        case 4:  m0=0; m1=1; m2=0; break;  // 1/4
        case 8:  m0=1; m1=1; m2=0; break;  // 1/8
        case 16: m0=0; m1=0; m2=1; break;  // 1/16
        case 32: m0=1; m1=0; m2=1; break;  // 1/32
    }
    digitalWrite(M0_PIN, m0);
    digitalWrite(M1_PIN, m1);
    digitalWrite(M2_PIN, m2);
}

void rotateDegrees(float degrees, bool clockwise) {
    int steps = (int)((degrees / 360.0) * effectiveSteps);

    digitalWrite(DIR_PIN, clockwise ? HIGH : LOW);
    Serial.printf("[Stepper] %s %.0f° → %d microsteps\n",
                  clockwise ? "CW" : "CCW", degrees, steps);

    for (int i = 0; i < steps; i++) {
        digitalWrite(STEP_PIN, HIGH);
        delayMicroseconds((unsigned long)(stepDelay / 2));
        digitalWrite(STEP_PIN, LOW);
        delayMicroseconds((unsigned long)(stepDelay / 2));
    }

    Serial.println("[Stepper] Done.");
}

void setup() {
    Serial.begin(115200);
    delay(500);

    pinMode(STEP_PIN, OUTPUT);
    pinMode(DIR_PIN, OUTPUT);
    pinMode(M0_PIN, OUTPUT);
    pinMode(M1_PIN, OUTPUT);
    pinMode(M2_PIN, OUTPUT);

    setMicrostep(MICROSTEP);

    Serial.println("=================================");
    Serial.println("  ESP32 DRV8825 Stepper Test");
    Serial.printf("  Microstep: 1/%d\n", MICROSTEP);
    Serial.printf("  RPM: %d\n", RPM);
    Serial.println("=================================\n");
    Serial.println("Send via Serial Monitor:");
    Serial.println("  'f' = forward 90°");
    Serial.println("  'b' = backward 90°");
    Serial.println("  'r' = full revolution CW");
    Serial.println("  's' = sweep test (back & forth)");
    Serial.println("  '1'-'5' = set microstep (1=full, 2=1/2, 3=1/4, 4=1/8, 5=1/16)\n");
}

void loop() {
    if (!Serial.available()) return;

    char cmd = Serial.read();

    switch (cmd) {
        case 'f':
            rotateDegrees(90, true);
            break;
        case 'b':
            rotateDegrees(90, false);
            break;
        case 'r':
            rotateDegrees(360, true);
            break;
        case 's':
            Serial.println("\n--- Sweep Test ---");
            for (int i = 0; i < 3; i++) {
                Serial.printf("Sweep %d/3\n", i + 1);
                rotateDegrees(90, true);
                delay(300);
                rotateDegrees(90, false);
                delay(300);
            }
            Serial.println("--- Sweep Done ---\n");
            break;
        case '1':
            setMicrostep(1);
            Serial.println("[Mode] Full step");
            break;
        case '2':
            setMicrostep(2);
            Serial.println("[Mode] 1/2 step");
            break;
        case '3':
            setMicrostep(4);
            Serial.println("[Mode] 1/4 step");
            break;
        case '4':
            setMicrostep(8);
            Serial.println("[Mode] 1/8 step");
            break;
        case '5':
            setMicrostep(16);
            Serial.println("[Mode] 1/16 step");
            break;
        default:
            break;
    }
}
