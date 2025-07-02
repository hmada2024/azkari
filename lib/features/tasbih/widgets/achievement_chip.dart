// lib/features/tasbih/widgets/achievement_chip.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:flutter/material.dart';

/// ويدجت جديد لعرض شريحة إنجاز جذابة عند إكمال هدف.
class AchievementChip extends StatelessWidget {
  final DailyGoalModel goal;

  const AchievementChip({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(12),
        vertical: context.responsiveSize(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.success.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: context.responsiveSize(18),
          ),
          SizedBox(width: context.responsiveSize(6)),
          Flexible(
            child: Text(
              goal.tasbihText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.success.withOpacity(0.9),
                fontSize: context.responsiveSize(13),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
