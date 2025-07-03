// lib/core/widgets/app_logo.dart
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.ico',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
