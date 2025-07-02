// lib/features/tasbih/widgets/active_tasbih_view.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:flutter/material.dart';

class ActiveTasbihView extends StatelessWidget {
  final TasbihModel activeTasbih;
  const ActiveTasbihView({super.key, required this.activeTasbih});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(20)),
      decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(context.responsiveSize(15)),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5))),
      child: Text(
        activeTasbih.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: context.responsiveSize(22),
          color: theme.textTheme.bodyLarge?.color,
          height: 1.7,
        ),
      ),
    );
  }
}
