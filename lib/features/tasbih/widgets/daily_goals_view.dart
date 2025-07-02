// lib/features/tasbih/widgets/daily_goals_view.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/progress/widgets/daily_goal_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class DailyGoalsView extends ConsumerWidget {
  const DailyGoalsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(dailyGoalsStateProvider);
    final theme = Theme.of(context);
    return goalsState.goals.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => CustomErrorWidget(
        errorMessage: 'خطأ في تحميل الأهداف: $error',
      ),
      data: (goals) {
        if (goals.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(8.0),
                  horizontal: context.responsiveSize(4.0)),
              child: Text(
                'أهدافي اليومية',
                style: TextStyle(
                  fontSize: context.responsiveSize(16),
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(context.responsiveSize(12)),
              decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius:
                      BorderRadius.circular(context.responsiveSize(12)),
                  border:
                      Border.all(color: theme.dividerColor.withOpacity(0.5))),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return DailyGoalItem(
                    key: ValueKey('goal_item_${goal.tasbihId}'),
                    tasbihId: goal.tasbihId,
                  );
                },
                separatorBuilder: (context, index) =>
                    Divider(height: context.responsiveSize(24)),
              ),
            ),
          ],
        );
      },
    );
  }
}