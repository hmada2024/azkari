// lib/features/progress/providers/daily_goals_provider.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyGoalsProvider = FutureProvider<List<DailyGoalModel>>((ref) async {
  ref.watch(dailyTasbihCountsProvider);

  // [مُعدَّل] الاعتماد على goalsRepositoryProvider الجديد
  final repository = await ref.watch(goalsRepositoryProvider.future);
  return repository.getTodayGoalsWithProgress();
});
