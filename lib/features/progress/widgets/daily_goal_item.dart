// lib/features/progress/widgets/daily_goal_item.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyGoalItem extends ConsumerWidget {
  final int tasbihId;
  const DailyGoalItem({
    super.key,
    required this.tasbihId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final DailyGoalModel? goal = ref.watch(
      dailyGoalsStateProvider.select((state) {
        final goals = state.goals.valueOrNull;
        if (goals == null) return null;
        final index = goals.indexWhere((g) => g.tasbihId == tasbihId);
        return index != -1 ? goals[index] : null;
      }),
    );
    if (goal == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.tasbihText,
                style: TextStyle(
                    fontSize: context.responsiveSize(15),
                    fontWeight: FontWeight.w600),
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
        SizedBox(height: context.responsiveSize(8)),
        Container(
          height: 8,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.scaffoldBackgroundColor,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: goal.progressFraction,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: goal.isCompleted
                      ? [AppColors.success.withOpacity(0.7), AppColors.success]
                      : [
                          theme.colorScheme.secondary.withOpacity(0.7),
                          theme.colorScheme.secondary
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
