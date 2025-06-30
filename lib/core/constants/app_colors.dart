// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية الجديدة
  static const Color primary =
      Color(0xFF00695C); // درجة أعمق وأكثر هدوءاً من Teal
  static const Color accent =
      Color(0xFFB2DFDB); // درجة فاتحة جداً من اللون الأساسي للتحديد

  // لون ثانوي دافئ للموازنة (للبطاقات أو الخلفيات)
  static const Color warmSand = Color(0xFFFDF8F1);

  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50); // أخضر للنجاح
  static const Color error = Color(0xFFE57373); // أحمر ناعم للخطأ

  // ألوان الخلفيات
  static const Color backgroundLight =
      Color(0xFFF7F9FA); // أبيض مائل للرمادي الفاتح
  static const Color backgroundDark = Color(0xFF121212);

  // ألوان البطاقات
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // ألوان محايدة
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFE0E0E0); // للحدود والفواصل
}
