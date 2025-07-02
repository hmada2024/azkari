// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // New Modern & Serene Palette
  static const Color primary = Color(0xFF34495E); // Deep Slate Blue
  static const Color accent = Color(0xFFF39C12); // Warm Gold
  static const Color success = Color(0xFF2ECC71); // Emerald Green
  static const Color error = Color(0xFFE74C3C); // Alizarin Crimson

  // Light Theme
  static const Color backgroundLight = Color(0xFFECF0F1); // Very Light Grey
  static const Color cardLight = Colors.white;
  static const Color textLight = Color(0xFF2C3E50); // Dark Slate

  // Dark Theme
  static const Color backgroundDark = Color(0xFF212F3D); // Darker Slate
  static const Color cardDark = Color(0xFF2C3E50); // Deep Slate Blue
  static const Color textDark = Color(0xFFEAECEE); // Light Greyish Blue

  // Gradients
  static const Gradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF4F6F8), Color(0xFFE5E8E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF212F3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient primaryGradient = LinearGradient(
    colors: [accent, Color(0xFFE67E22)], // Gold to Orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradientLight = LinearGradient(
    colors: [Colors.white, Color(0xFFFDFEFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
