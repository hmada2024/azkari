// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

/// يحتوي هذا الكلاس على جميع الألوان الأساسية المستخدمة في التطبيق.
/// يفضل دائمًا استخدام الألوان من خلال `Theme.of(context)` لضمان التوافق
/// مع الوضع الفاتح والداكن، ولكن يمكن استخدام هذه الثوابت مباشرة
/// في الحالات التي لا يتغير فيها اللون مع الثيم (مثل لون النجاح أو الخطأ).
class AppColors {
  // الألوان الأساسية
  static const Color primary = Colors.teal;
  static const Color accent = Colors.tealAccent;

  // ألوان الحالة
  static const Color success = Colors.green;
  static const Color error = Colors.red;

  // ألوان الخلفيات
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // ألوان البطاقات
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // ألوان محايدة
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFBDBDBD); // for borders
}
