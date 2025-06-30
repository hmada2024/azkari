// lib/core/theme/app_theme.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

/// هذا الكلاس هو المركز الوحيد لتعريف وتخصيص ثيمات التطبيق.
/// يوفر تعريفًا كاملاً للوضع الفاتح والداكن، مما يضمن تناسق المظهر
/// في جميع أنحاء التطبيق.
class AppTheme {
  // private constructor
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: AppTextStyles.cairo.fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 1.0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppTextStyles.cairo.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    dividerColor: Colors.black12,
    textTheme: const TextTheme(
      // يمكنك تعريف أنماط محددة هنا
      headlineSmall: TextStyle(fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: AppTextStyles.cairo.fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.primary,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardDark,
      elevation: 1.0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.accent),
      titleTextStyle: AppTextStyles.cairo.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    iconTheme: const IconThemeData(color: AppColors.accent),
    dividerColor: Colors.white24,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
}
