// lib/core/theme/app_theme.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: AppTextStyles.cairo.fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.cardLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textLight,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        fontFamily: AppTextStyles.cairo.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0, // We will use custom decoration with shadows
      color: Colors.transparent, // Cards will have gradient backgrounds
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    dividerColor: Colors.grey.shade300,
    textTheme: TextTheme(
      titleMedium: const TextStyle(
          color: AppColors.textLight, fontWeight: FontWeight.bold),
      bodyLarge: const TextStyle(color: AppColors.textLight),
      bodyMedium: TextStyle(color: AppColors.textLight.withOpacity(0.7)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      elevation: 5,
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
      surface: AppColors.cardDark,
      error: AppColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: AppColors.textDark,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.accent),
      titleTextStyle: TextStyle(
        fontFamily: AppTextStyles.cairo.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.accent),
    dividerColor: Colors.grey.shade800,
    textTheme: TextTheme(
      titleMedium: const TextStyle(
          color: AppColors.textDark, fontWeight: FontWeight.bold),
      bodyLarge: const TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textDark.withOpacity(0.7)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.black,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: Colors.grey,
      elevation: 5,
    ),
  );
}
