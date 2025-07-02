// lib/core/widgets/primary_button.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:flutter/material.dart';
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      textStyle: TextStyle(
        fontSize: context.responsiveSize(15),
        fontFamily: 'Cairo',
      ),
    );
    return icon != null
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: context.responsiveSize(18)),
            label: Text(text),
            style: style,
          )
        : FilledButton(
            onPressed: onPressed,
            style: style,
            child: Text(text),
          );
  }
}