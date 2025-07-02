// lib/features/progress/widgets/stat_day_cell.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/features/progress/providers/statistics_provider.dart';
import 'package:flutter/material.dart';

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
    final isDarkMode = theme.brightness == Brightness.dark;

    if (stat == null || stat!.type == StatDayType.future) {
      return Container(
        alignment: Alignment.center,
        child: Text(dayNumber.toString(),
            style: TextStyle(color: theme.disabledColor)),
      );
    }

    Color borderColor = Colors.transparent;
    FontWeight fontWeight = FontWeight.normal;
    Gradient? gradient;

    if (stat!.isCompleted) {
      gradient = LinearGradient(
        colors: [AppColors.success.withOpacity(0.7), AppColors.success],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (stat!.percentage > 0) {
      gradient = LinearGradient(
        colors: [
          theme.colorScheme.primary.withOpacity(0.1),
          theme.colorScheme.primary.withOpacity((stat!.percentage * 0.5) + 0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (stat!.type == StatDayType.today) {
      borderColor = theme.colorScheme.secondary;
      fontWeight = FontWeight.bold;
    }

    return Container(
      key: ValueKey('stat_cell_$dayNumber'),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? theme.scaffoldBackgroundColor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        dayNumber.toString(),
        style: TextStyle(
          color: (stat!.isCompleted && !isDarkMode)
              ? Colors.white
              : theme.textTheme.bodyLarge?.color,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
