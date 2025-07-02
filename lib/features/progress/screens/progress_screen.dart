//lib/features/progress/screens/progress_screen.dart
import 'package:azkari/features/goal_management/screens/goal_management_screen.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:azkari/features/progress/widgets/statistics_view.dart';
import 'package:azkari/features/progress/widgets/initial_progress_view.dart';
import 'package:azkari/features/progress/widgets/no_goals_set_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyGoalsState = ref.watch(dailyGoalsStateProvider);
    final appBarTextStyle =
        Theme.of(context).appBarTheme.titleTextStyle ?? const TextStyle();
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقدمي'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const GoalManagementScreen(),
                ));
              },
              child: Text(
                'إدارة أهدافي',
                style: appBarTextStyle.copyWith(fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: dailyGoalsState.goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
        data: (goals) {
          if (goals.isEmpty) {
            return const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: NoGoalsSetView(),
            );
          }
          final totalTodayProgress =
              goals.fold<int>(0, (sum, goal) => sum + goal.currentProgress);
          if (totalTodayProgress > 0) {
            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: const [
                DailyGoalsView(),
                SizedBox(height: 24),
                StatisticsView(),
              ],
            );
          } else {
            return const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: InitialProgressView(),
            );
          }
        },
      ),
    );
  }
}
