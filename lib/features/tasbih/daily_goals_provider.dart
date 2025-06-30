// lib/features/tasbih/daily_goals_provider.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/adhkar_list/azkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✨ [تعديل] التعامل مع المستودع كـ Future
final dailyGoalsProvider = FutureProvider<List<DailyGoalModel>>((ref) async {
  final repository = await ref.watch(adhkarRepositoryProvider.future);
  return repository.getGoalsWithTodayProgress();
});

final dailyGoalsNotifierProvider =
    StateNotifierProvider<DailyGoalsNotifier, AsyncValue<void>>((ref) {
  return DailyGoalsNotifier(ref);
});

class DailyGoalsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  DailyGoalsNotifier(this._ref) : super(const AsyncData(null));

  Future<void> _performAction(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      _ref.invalidate(dailyGoalsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setOrUpdateGoal(int tasbihId, int targetCount) async {
    await _performAction(() async {
      // ✨ [تعديل] انتظار المستودع قبل استخدامه
      final repository = await _ref.read(adhkarRepositoryProvider.future);
      await repository.setOrUpdateGoal(tasbihId, targetCount);
    });
  }

  Future<void> removeGoal(int tasbihId) async {
    await _performAction(() async {
      // ✨ [تعديل] انتظار المستودع قبل استخدامه
      final repository = await _ref.read(adhkarRepositoryProvider.future);
      await repository.removeGoal(tasbihId);
    });
  }

  Future<void> incrementProgressForTasbih(int tasbihId) async {
    // ✨ [تعديل] انتظار المستودع قبل استخدامه
    final repository = await _ref.read(adhkarRepositoryProvider.future);
    final goalData = await repository.getGoalForTasbih(tasbihId);

    if (goalData != null && goalData['id'] != null) {
      final int goalId = goalData['id'];
      await repository.incrementGoalProgress(goalId);
      _ref.invalidate(dailyGoalsProvider);
    }
  }
}
