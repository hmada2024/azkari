// lib/features/settings/use_cases/update_font_scale_use_case.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة استخدام مسؤولة عن حفظ تفضيل حجم الخط للمستخدم.
class UpdateFontScaleUseCase {
  final SharedPreferences _prefs;

  UpdateFontScaleUseCase(this._prefs);

  /// يحفظ مقياس الخط الجديد في SharedPreferences.
  Future<void> execute(double newScale) async {
    await _prefs.setDouble(AppConstants.fontScaleKey, newScale);
  }
}
