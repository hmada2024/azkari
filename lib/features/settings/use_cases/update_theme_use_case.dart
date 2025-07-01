// lib/features/settings/use_cases/update_theme_use_case.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة استخدام مسؤولة عن حفظ تفضيل الثيم (Theme) الخاص بالمستخدم.
class UpdateThemeUseCase {
  final SharedPreferences _prefs;

  UpdateThemeUseCase(this._prefs);

  /// يحفظ الثيم الجديد في SharedPreferences.
  Future<void> execute(ThemeMode newTheme) async {
    await _prefs.setInt(AppConstants.themeKey, newTheme.index);
  }
}
