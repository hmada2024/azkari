// lib/features/tasbih/daily_goals_provider.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart'; // ✨ استيراد جديد
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyGoalsProvider = FutureProvider<List<DailyGoalModel>>((ref) async {
  // ✨ [تعديل] إضافة .watch لـ dailyTasbihCountsProvider.
  // هذا يخلق اعتمادية صريحة. عندما تتغير العدادات، سيعاد بناء هذا الـ Provider تلقائياً.
  ref.watch(dailyTasbihCountsProvider);

  final repository = await ref.watch(adhkarRepositoryProvider.future);
  return repository.getTodayGoalsWithProgress();
});
