// lib/features/settings/use_cases/update_morning_notification_use_case.dart
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/core/services/notification_service.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UpdateMorningNotificationUseCase {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;
  UpdateMorningNotificationUseCase(this._prefs, this._notificationService);
  Future<Either<Failure, void>> execute(bool isEnabled) async {
    try {
      await _prefs.setBool(AppConstants.morningNotifKey, isEnabled);
      if (isEnabled) {
        await _notificationService.scheduleMorningReminder();
      } else {
        await _notificationService.cancelMorningReminder();
      }
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure("فشل تحديث تذكير الصباح."));
    }
  }
}