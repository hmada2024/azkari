// lib/features/progress/widgets/stat_day_cell.dart

import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/features/progress/providers/statistics_provider.dart';
import 'package:flutter/material.dart';

/// ويدجت يمثل خلية يوم واحد في عرض إحصائيات التقويم الشهري.
class StatDayCell extends StatelessWidget {
  final DailyStat? stat;
  final int dayNumber;

  const StatDayCell({
    super.key,
    required this.stat,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stat == null || stat!.type == StatDayType.future) {
      return Container(
        alignment: Alignment.center,
        child: Text(dayNumber.toString(),
            style: TextStyle(color: theme.disabledColor)),
      );
    }

    Color cellColor = Colors.transparent;
    Color borderColor = Colors.transparent;
    FontWeight fontWeight = FontWeight.normal;

    if (stat!.isCompleted) {
      cellColor = AppColors.success.withOpacity(0.9);
    } else if (stat!.percentage > 0) {
      cellColor = AppColors.primary.withOpacity((stat!.percentage * 0.7) + 0.2);
    } else {
      cellColor = AppColors.error.withOpacity(0.15);
    }

    if (stat!.type == StatDayType.today) {
      borderColor = AppColors.primary;
      fontWeight = FontWeight.bold;
    }

    return Container(
      key: ValueKey('stat_cell_$dayNumber'),
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        dayNumber.toString(),
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
