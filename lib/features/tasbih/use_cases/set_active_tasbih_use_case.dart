// lib/features/tasbih/use_cases/set_active_tasbih_use_case.dart
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetActiveTasbihUseCase {
  final SharedPreferences _prefs;
  SetActiveTasbihUseCase(this._prefs);
  Future<Either<Failure, void>> execute(int tasbihId) async {
    try {
      await _prefs.setInt(AppConstants.activeTasbihIdKey, tasbihId);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure("فشل حفظ الذكر النشط."));
    }
  }
}
