// lib/core/constants/app_text_styles.dart
import 'package:flutter/material.dart';

/// يحتوي هذا الكلاس على أنماط النصوص الأساسية التي يمكن إعادة استخدامها.
/// تم تعريف معظم الأنماط الرئيسية مباشرة داخل `AppTheme` لربطها بالثيم العام،
/// ولكن يمكن تعريف أنماط متخصصة هنا.
class AppTextStyles {
  /// نمط خط أميري، يستخدم غالبًا لنصوص الأذكار.
  static const TextStyle amiri = TextStyle(
    fontFamily: 'Amiri',
    height: 1.8,
  );

  /// نمط خط كايرو، يستخدم للنصوص العامة في التطبيق.
  static const TextStyle cairo = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.normal,
  );
}
