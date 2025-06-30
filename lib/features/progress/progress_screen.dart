// lib/features/progress/progress_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/primary_button.dart';
import 'package:azkari/features/goal_management/goal_management_screen.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:azkari/features/progress/widgets/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyGoalsAsync = ref.watch(dailyGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقدمي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'إدارة الأهداف',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const GoalManagementScreen(),
              ));
            },
          )
        ],
      ),
      body: dailyGoalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
        data: (goals) {
          if (goals.isEmpty) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildNoGoalsSetView(context),
            );
          }

          final totalTodayProgress =
              goals.fold<int>(0, (sum, goal) => sum + goal.currentProgress);

          if (totalTodayProgress > 0 || goals.isNotEmpty) {
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
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildInitialView(context),
            );
          }
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: context.responsiveSize(80),
              color: theme.primaryColor.withOpacity(0.6),
            ),
            SizedBox(height: context.responsiveSize(24)),
            Text(
              'ابدأ رحلتك اليومية',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(12)),
            Text(
              'سيظهر تقدمك في أهدافك اليومية هنا بمجرد البدء في التسبيح من شاشة السبحة.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGoalsSetView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: context.responsiveSize(70),
              color: theme.disabledColor,
            ),
            SizedBox(height: context.responsiveSize(20)),
            Text(
              'لم تقم بتحديد أي أهداف بعد',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(10)),
            Text(
              'حدد أهدافك اليومية للبدء في تتبع تقدمك.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(20)),
            PrimaryButton(
              icon: Icons.add_task_outlined,
              text: 'تحديد الأهداف الآن',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GoalManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
