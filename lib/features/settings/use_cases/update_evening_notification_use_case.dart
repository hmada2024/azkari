// lib/features/settings/use_cases/update_evening_notification_use_case.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة استخدام مسؤولة عن تفعيل أو إلغاء تذكير المساء.
class UpdateEveningNotificationUseCase {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  UpdateEveningNotificationUseCase(this._prefs, this._notificationService);

  /// يحفظ الإعداد ويقوم بجدولة أو إلغاء الإشعار.
  Future<void> execute(bool isEnabled) async {
    // 1. حفظ الإعداد في SharedPreferences
    await _prefs.setBool(AppConstants.eveningNotifKey, isEnabled);

    // 2. التفاعل مع خدمة الإشعارات
    if (isEnabled) {
      await _notificationService.scheduleEveningReminder();
    } else {
      await _notificationService.cancelEveningReminder();
    }
  }
}
