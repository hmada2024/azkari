// lib/features/tasbih/use_cases/set_active_tasbih_use_case.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة استخدام مسؤولة عن حفظ معرّف (ID) الذكر النشط.
class SetActiveTasbihUseCase {
  final SharedPreferences _prefs;

  SetActiveTasbihUseCase(this._prefs);

  /// يحفظ الـ ID في SharedPreferences.
  Future<void> execute(int tasbihId) async {
    await _prefs.setInt(AppConstants.activeTasbihIdKey, tasbihId);
  }
}
