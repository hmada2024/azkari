// lib/features/tasbih/widgets/completed_goals_view.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/achievement_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ويدجت جديد مسؤول عن عرض شرائح الإنجاز للأهداف اليومية المكتملة
class CompletedGoalsView extends ConsumerWidget {
  const CompletedGoalsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final completedGoals = ref.watch(completedGoalsProvider);

    if (completedGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.responsiveSize(8.0),
            horizontal: context.responsiveSize(4.0),
          ),
          child: Text(
            'إنجازات اليوم',
            style: TextStyle(
              fontSize: context.responsiveSize(16),
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
        SizedBox(height: context.responsiveSize(4)),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: completedGoals
              .map((goal) => AchievementChip(
                    key: ValueKey('achieve_${goal.tasbihId}'),
                    goal: goal,
                  ))
              .toList(),
        ),
      ],
    );
  }
}
