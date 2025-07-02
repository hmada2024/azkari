// lib/core/widgets/app_background.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? AppColors.backgroundGradientDark
            : AppColors.backgroundGradientLight,
      ),
      child: child,
    );
  }
}
