// lib/features/settings/use_cases/update_morning_notification_use_case.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة استخدام مسؤولة عن تفعيل أو إلغاء تذكير الصباح.
class UpdateMorningNotificationUseCase {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  UpdateMorningNotificationUseCase(this._prefs, this._notificationService);

  /// يحفظ الإعداد ويقوم بجدولة أو إلغاء الإشعار.
  Future<void> execute(bool isEnabled) async {
    // 1. حفظ الإعداد في SharedPreferences
    await _prefs.setBool(AppConstants.morningNotifKey, isEnabled);

    // 2. التفاعل مع خدمة الإشعارات
    if (isEnabled) {
      await _notificationService.scheduleMorningReminder();
    } else {
      await _notificationService.cancelMorningReminder();
    }
  }
}
