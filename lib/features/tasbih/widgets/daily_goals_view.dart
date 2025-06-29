// lib/features/tasbih/widgets/daily_goals_view.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyGoalsView extends ConsumerWidget {
  const DailyGoalsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(dailyGoalsProvider);
    final theme = Theme.of(context);

    return goalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => Text('خطأ في تحميل الأهداف: $error',
          style: const TextStyle(color: Colors.red)),
      data: (goals) {
        if (goals.isEmpty) {
          // لا تعرض شيئاً إذا لم يحدد المستخدم أي أهداف
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
                                  fontSize: context.responsiveSize(15)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: context.responsiveSize(8)),
                          Text(
                            '${goal.currentProgress} / ${goal.targetCount}',
                            style: TextStyle(
                              fontSize: context.responsiveSize(14),
                              color: theme.textTheme.bodySmall?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (goal.isCompleted)
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(Icons.check_circle,
                                  color: Colors.green,
                                  size: context.responsiveSize(18)),
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
                            goal.isCompleted
                                ? Colors.green
                                : theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
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
