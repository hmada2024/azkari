// lib/features/settings/use_cases/update_theme_use_case.dart
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UpdateThemeUseCase {
  final SharedPreferences _prefs;
  UpdateThemeUseCase(this._prefs);
  Future<Either<Failure, void>> execute(ThemeMode newTheme) async {
    try {
      await _prefs.setInt(AppConstants.themeKey, newTheme.index);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure("فشل حفظ إعدادات المظهر."));
    }
  }
}