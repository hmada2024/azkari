// lib/core/services/notification_service.dart
import 'package:flutter/foundation.dart'; // ✨ استيراد جديد لاستخدام debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int morningNotificationId = 0;
  static const int eveningNotificationId = 1;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    } catch (e) {
      debugPrint('Could not set timezone: $e');
    }

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    tz.TZDateTime nextInstanceOf(int hour, int minute) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkari_daily_channel',
          'تذكيرات الأذكار اليومية',
          channelDescription: 'قناة لإرسال تذكيرات أذكار الصباح والمساء',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMorningReminder() async {
    await _scheduleDailyNotification(
      id: morningNotificationId,
      title: '☀️ أذكار الصباح',
      body: 'حان وقت قراءة أذكار الصباح. حصّن يومك بذكر الله.',
      hour: 8,
      minute: 0,
    );
  }

  Future<void> scheduleEveningReminder() async {
    await _scheduleDailyNotification(
      id: eveningNotificationId,
      title: '🌙 أذكار المساء',
      body: 'لا تنسَ قراءة أذكار المساء. طمئن قلبك بذكر الله.',
      hour: 17,
      minute: 30,
    );
  }

  Future<void> cancelMorningReminder() async {
    await _notificationsPlugin.cancel(morningNotificationId);
  }

  Future<void> cancelEveningReminder() async {
    await _notificationsPlugin.cancel(eveningNotificationId);
  }
}
