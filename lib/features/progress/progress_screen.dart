// lib/features/progress/progress_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/management/tasbih_management_screen.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:azkari/features/progress/widgets/statistics_view.dart'; // ✨ [جديد] استيراد
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

          if (totalTodayProgress > 0) {
            // ✨ [تعديل] استخدام ListView بدلاً من SingleChildScrollView
            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: const [
                DailyGoalsView(),
                SizedBox(height: 24), // فاصل
                StatisticsView(), // ✨ [جديد] إضافة واجهة الإحصائيات
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
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
              color: Colors.grey.shade400,
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(20)),
            FilledButton.icon(
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('تحديد الأهداف الآن'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(20),
                  vertical: context.responsiveSize(10),
                ),
                textStyle: TextStyle(
                  fontSize: context.responsiveSize(15),
                  fontFamily: 'Cairo',
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TasbihManagementScreen(),
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
