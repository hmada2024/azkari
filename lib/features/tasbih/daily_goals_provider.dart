// lib/features/tasbih/daily_goals_provider.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [مهم] هذا الـ Provider أصبح للقراءة فقط، وظيفته جلب أهداف اليوم لعرضها
// في شاشتي "السبحة" و "تقدمي".
final dailyGoalsProvider = FutureProvider<List<DailyGoalModel>>((ref) async {
  final repository = await ref.watch(adhkarRepositoryProvider.future);
  // [تصحيح] استخدام اسم الدالة الجديد من المستودع
  return repository.getTodayGoalsWithProgress();
});

// [ملاحظة] لم نعد بحاجة إلى DailyGoalsNotifier هنا.
// تم نقل منطق الكتابة (التعديل والإضافة) إلى GoalManagementNotifier
// مما يجعل هذا الملف أبسط وأكثر تركيزاً على وظيفته.