// lib/features/progress/progress_screen.dart
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقدمي'),
      ),
      // نستخدم SingleChildScrollView لضمان أن الواجهة قابلة للتمرير
      // إذا زاد عدد الأهداف في المستقبل.
      body: const SingleChildScrollView(
        // نضيف Padding لكي لا تلتصق الواجهة بحواف الشاشة.
        padding: EdgeInsets.all(16.0),
        child: DailyGoalsView(),
      ),
    );
  }
}
