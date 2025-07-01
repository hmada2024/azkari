// lib/features/progress/providers/daily_goals_provider.dart
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyGoalsProvider = FutureProvider<List<DailyGoalModel>>((ref) async {
  ref.watch(dailyTasbihCountsProvider);

  final repository = await ref.watch(goalsRepositoryProvider.future);
  return repository.getTodayGoalsWithProgress();
});
