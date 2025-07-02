// lib/features/settings/use_cases/update_font_scale_use_case.dart
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateFontScaleUseCase {
  final SharedPreferences _prefs;
  UpdateFontScaleUseCase(this._prefs);

  Future<Either<Failure, void>> execute(double newScale) async {
    try {
      await _prefs.setDouble(AppConstants.fontScaleKey, newScale);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure("فشل حفظ إعدادات حجم الخط."));
    }
  }
}
