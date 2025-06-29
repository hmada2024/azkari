// lib/features/progress/progress_screen.dart
import 'package:azkari/core/utils/size_config.dart';
// ✨ 1. استيراد شاشة الإدارة للتمكن من الانتقال إليها
import 'package:azkari/features/tasbih/management/tasbih_management_screen.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
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
            return _buildNoGoalsSetView(context);
          }

          final totalTodayProgress =
              goals.fold<int>(0, (sum, goal) => sum + goal.currentProgress);

          if (totalTodayProgress > 0) {
            return const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DailyGoalsView(),
            );
          } else {
            return _buildInitialView(context);
          }
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    // ... هذا الجزء يبقى كما هو بدون تغيير
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

  // ✨ --- هذا هو الجزء الذي تم تعديله بالكامل --- ✨
  Widget _buildNoGoalsSetView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: context.responsiveSize(80),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: context.responsiveSize(24)),
            Text(
              'لم تقم بتحديد أي أهداف بعد',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(12)),
            // 2. تغيير نص التعليمات إلى دعوة للعمل (Call to Action)
            Text(
              'حدد أهدافك اليومية للبدء في تتبع تقدمك.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(24)),
            // 3. إضافة زر للانتقال المباشر
            FilledButton.icon(
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('تحديد الأهداف الآن'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo', // ضمان استخدام نفس خط التطبيق
                ),
              ),
              onPressed: () {
                // عند الضغط، انتقل مباشرة إلى شاشة إدارة التسابيح
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
