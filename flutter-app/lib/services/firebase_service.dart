import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final _db = FirebaseDatabase.instance;

  // ── Sensor streams ───────────────────────────────────────────────────
  static Stream<double> get soilMoisture => _db
      .ref('sensors/soil_moisture_pct')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  static Stream<double> get humidity => _db
      .ref('sensors/humidity')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  static Stream<double> get temperature => _db
      .ref('sensors/temperature')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  static Stream<double> get current => _db
      .ref('sensors/current')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  // ── Status streams ───────────────────────────────────────────────────
  static Stream<String> get systemState => _db
      .ref('status/system_state')
      .onValue
      .map((e) => e.snapshot.value?.toString() ?? 'NORMAL');

  static Stream<String> get currentMode => _db
      .ref('status/mode')
      .onValue
      .map((e) => e.snapshot.value?.toString() ?? 'AUTOMATIC');

  static Stream<String> get pumpStatus => _db
      .ref('status/pump')
      .onValue
      .map((e) => e.snapshot.value?.toString().toUpperCase() ?? 'OFF');

  static Stream<int> get gantryPlant => _db
      .ref('status/gantry_plant')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toInt() ?? 0);

  // ── AI detection stream ──────────────────────────────────────────────
  static Stream<Map<String, dynamic>> get latestDetection =>
      _db.ref('ai/latest_detection').onValue.map((e) {
        final val = e.snapshot.value as Map?;
        if (val == null) return {};
        return Map<String, dynamic>.from(val);
      });

  // ── Commands ─────────────────────────────────────────────────────────
  static Future<void> setMode(String mode) =>
      _db.ref('status/mode').set(mode);

  static Future<void> writePumpAction({
    required String state,
    required int plant,
  }) =>
      _db.ref('commands/pump_action').set({
        'state': state,
        'plant': plant,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

  static Stream<Map<String, dynamic>> get pumpAction =>
      _db.ref('commands/pump_action').onValue.map((e) {
        final val = e.snapshot.value as Map?;
        if (val == null) return {'state': 'OFF', 'plant': 0, 'timestamp': 0};
        return Map<String, dynamic>.from(val);
      });

  static Future<void> writeEmergencyStop() =>
      _db.ref('commands/emergency_stop').set(true);

  // ── Alerts ───────────────────────────────────────────────────────────
  static Future<void> pushAlert({
    required String message,
    required String severity,
  }) =>
      _db.ref('alerts/history').push().set({
        'message': message,
        'severity': severity,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

  // ── Connectivity ─────────────────────────────────────────────────────
  static Stream<bool> get connected => _db
      .ref('.info/connected')
      .onValue
      .map((e) => e.snapshot.value as bool? ?? false);
}
