// lib/features/progress/progress_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // نراقب حالة الأهداف اليومية كالعادة
    final dailyGoalsAsync = ref.watch(dailyGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقدمي'),
      ),
      body: dailyGoalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
        data: (goals) {
          // ✨ --- المنطق الذكي الجديد --- ✨

          // 1. الحالة الأولى: المستخدم لم يحدد أي أهداف من الأساس.
          if (goals.isEmpty) {
            return _buildNoGoalsSetView(context);
          }

          // 2. نحسب إجمالي التقدم اليومي لمعرفة ما إذا كان المستخدم قد بدأ.
          final totalTodayProgress =
              goals.fold<int>(0, (sum, goal) => sum + goal.currentProgress);

          // 3. الحالة الثانية: المستخدم بدأ بالفعل في التسبيح (التقدم أكبر من صفر).
          if (totalTodayProgress > 0) {
            return const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DailyGoalsView(),
            );
          }
          // 4. الحالة الثالثة: توجد أهداف، لكن المستخدم لم يبدأ بعد (التقدم صفر).
          else {
            return _buildInitialView(context);
          }
        },
      ),
    );
  }

  // ويدجت للحالة الابتدائية (توجد أهداف، لكن لم يبدأ التسبيح)
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

  // ويدجت لحالة عدم وجود أي أهداف محددة
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
            Text(
              'اذهب إلى شاشة السبحة واضغط على أيقونة "تعديل القائمة" لتحديد أهدافك اليومية.',
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
}
