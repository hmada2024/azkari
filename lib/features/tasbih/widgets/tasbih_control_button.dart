// lib/features/tasbih/widgets/tasbih_control_button.dart

import 'package:azkari/core/utils/size_config.dart';
import 'package:flutter/material.dart';

/// ويدجت يمثل زر تحكم دائري في هيدر شاشة السبحة (مثل زر القائمة أو التصفير).
class TasbihControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const TasbihControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSize(10)),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.cardColor,
              border: Border.all(color: theme.dividerColor.withOpacity(0.5))),
          child: Icon(
            icon,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            size: context.responsiveSize(24),
          ),
        ),
      ),
    );
  }
}
