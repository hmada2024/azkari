// lib/core/utils/size_config.dart
import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late Orientation orientation;

  // يجب استدعاء هذه الدالة في بداية كل شاشة (في بداية دالة build)
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }

  /// دالة لحساب حجم متجاوب (نص، أيقونة، هامش، إلخ) بناءً على عرض الشاشة.
  /// الفكرة هي أن الحجم يتناسب مع عرض الشاشة.
  /// تم اختيار 375.0 كعرض معياري (مثل شاشة iPhone X) لتكون أساس الحساب.
  static double getResponsiveSize(double baseSize) {
    double scaleFactor = screenWidth / 375.0;
    // نضع حداً أدنى وأقصى للمعامل لتجنب الأحجام الكبيرة جداً أو الصغيرة جداً
    // على الشاشات الضخمة أو الصغيرة جداً.
    scaleFactor = scaleFactor.clamp(0.85, 1.2); 
    return baseSize * scaleFactor;
  }
}