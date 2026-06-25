import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_service.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static final _notif = FlutterLocalNotificationsPlugin();
  static StreamSubscription? _detectionSub;
  static StreamSubscription? _modeSub;
  static String? _lastDetectionClass;
  static String? _lastMode;

  static const _channel = AndroidNotificationChannel(
    'irrigation_alerts',
    'Irrigation Alerts',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (!kIsWeb) {
      await Permission.notification.request();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _notif.initialize(const InitializationSettings(android: androidSettings));
      await _notif
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    _detectionSub = FirebaseService.latestDetection.listen((detection) {
      final cls = detection['class']?.toString() ?? '';
      if (cls.isEmpty || cls == 'Healthy' || cls == 'Unknown' || cls == _lastDetectionClass) return;
      _lastDetectionClass = cls;
      _show('Plant Issue Detected', '$cls detected — check AI Monitor', severity: 'warning');
    });

    _modeSub = FirebaseService.currentMode.listen((mode) {
      if (mode == _lastMode) return;
      _lastMode = mode;
      if (mode == 'MANUAL') {
        _show('Manual Mode Enabled', 'AI automation paused. You have full control.', severity: 'info');
      }
    });

    log.i('NotificationService initialized');
  }

  static Future<void> _show(String title, String body, {String severity = 'info'}) async {
    if (!kIsWeb) {
      _notif.show(
        DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
    await _logAlert(title, body, severity);
    log.i('Notification: $title — $body');
  }

  static Future<void> _logAlert(String title, String body, String severity) async {
    try {
      await FirebaseService.pushAlert(
        message: '$title: $body',
        severity: severity,
      );
      log.d('Alert logged: $title');
    } catch (e) {
      log.w('Alert log failed: $e');
    }
  }

  static void dispose() {
    _detectionSub?.cancel();
    _modeSub?.cancel();
  }
}
