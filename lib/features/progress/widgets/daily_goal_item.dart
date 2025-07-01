// lib/features/progress/widgets/daily_goal_item.dart

import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:flutter/material.dart';

/// ويدجت يمثل عنصر هدف يومي واحد في قائمة الأهداف.
/// مسؤول عن عرض نص الذكر، التقدم الحالي، وشريط التقدم.
class DailyGoalItem extends StatelessWidget {
  final DailyGoalModel goal;

  const DailyGoalItem({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.tasbihText,
                style: TextStyle(fontSize: context.responsiveSize(15)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.responsiveSize(8)),
            Text(
              '${goal.currentProgress} / ${goal.targetCount}',
              style: TextStyle(
                fontSize: context.responsiveSize(14),
                color: theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (goal.isCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.check_circle,
                    color: AppColors.success, size: context.responsiveSize(18)),
              ),
          ],
        ),
        SizedBox(height: context.responsiveSize(6)),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: goal.progressFraction,
            minHeight: 6,
            backgroundColor: theme.scaffoldBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? AppColors.success : theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
