// lib/core/utils/size_config.dart
import 'package:flutter/widgets.dart';

extension ResponsiveSize on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double responsiveSize(double baseSize) {
    const double standardScreenWidth = 375.0;
    final double scaleFactor = screenWidth / standardScreenWidth;
    return baseSize * scaleFactor.clamp(0.85, 1.2);
  }
}
