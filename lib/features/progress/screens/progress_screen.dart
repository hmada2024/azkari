//lib/features/progress/screens/progress_screen.dart
import 'package:azkari/features/goal_management/screens/goal_management_screen.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:azkari/features/progress/widgets/statistics_view.dart';
import 'package:azkari/features/progress/widgets/initial_progress_view.dart'; // [جديد] استيراد الويدجت
import 'package:azkari/features/progress/widgets/no_goals_set_view.dart'; // [جديد] استيراد الويدجت
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
          // [تعديل] أصبح المنطق أكثر وضوحًا
          if (goals.isEmpty) {
            return const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: NoGoalsSetView(), // [تعديل] استدعاء الويدجت الجديد
            );
          }

          final totalTodayProgress =
              goals.fold<int>(0, (sum, goal) => sum + goal.currentProgress);

          if (totalTodayProgress > 0) {
            // [بدون تغيير] عرض التقدم الفعلي
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
            // [تعديل] الحالة التي فيها أهداف ولكن لا يوجد تقدم بعد
            return const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: InitialProgressView(), // [تعديل] استدعاء الويدجت الجديد
            );
          }
        },
      ),
    );
  }
}
