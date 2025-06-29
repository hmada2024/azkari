import 'package:azkari/core/utils/size_config.dart'; // سيعمل الآن كـ extension
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:flutter/material.dart';

class ActiveTasbihView extends StatelessWidget {
  final TasbihModel activeTasbih;
  const ActiveTasbihView({super.key, required this.activeTasbih});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      // [تحسين] ✨: استخدام الـ extension الجديد
      padding: EdgeInsets.all(context.responsiveSize(16)),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(context.responsiveSize(12)),
          border: Border.all(color: theme.dividerColor)),
      child: Text(
        activeTasbih.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: context.responsiveSize(20), // [تحسين] ✨
          color: theme.textTheme.bodyLarge?.color,
          height: 1.7,
        ),
      ),
    );
  }
}
