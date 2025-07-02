// lib/features/settings/use_cases/update_evening_notification_use_case.dart
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/core/services/notification_service.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UpdateEveningNotificationUseCase {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;
  UpdateEveningNotificationUseCase(this._prefs, this._notificationService);
  Future<Either<Failure, void>> execute(bool isEnabled) async {
    try {
      await _prefs.setBool(AppConstants.eveningNotifKey, isEnabled);
      if (isEnabled) {
        await _notificationService.scheduleEveningReminder();
      } else {
        await _notificationService.cancelEveningReminder();
      }
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure("فشل تحديث تذكير المساء."));
    }
  }
}