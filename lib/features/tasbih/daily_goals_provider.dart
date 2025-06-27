// lib/features/tasbih/daily_goals_provider.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider 1: يجلب قائمة الأهداف مع تقدمها اليومي
final dailyGoalsProvider = FutureProvider<List<DailyGoalModel>>((ref) async {
  final repository = ref.watch(adhkarRepositoryProvider);
  return repository.getGoalsWithTodayProgress();
});

// Provider 2: Notifier لإدارة عمليات الأهداف
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
      final repository = _ref.read(adhkarRepositoryProvider);
      await repository.setOrUpdateGoal(tasbihId, targetCount);
    });
  }

  Future<void> removeGoal(int tasbihId) async {
    await _performAction(() async {
      final repository = _ref.read(adhkarRepositoryProvider);
      await repository.removeGoal(tasbihId);
    });
  }

  Future<void> incrementProgressForTasbih(int tasbihId) async {
    final repository = _ref.read(adhkarRepositoryProvider);

    // 1. احصل على الهدف من قاعدة البيانات مباشرة
    final goalData = await repository.getGoalForTasbih(tasbihId);

    // 2. إذا كان هناك هدف، قم بتحديث التقدم
    if (goalData != null && goalData['id'] != null) {
      final int goalId = goalData['id'];
      await repository.incrementGoalProgress(goalId);

      // 3. أعد تحميل البيانات لتحديث الواجهة
      _ref.invalidate(dailyGoalsProvider);
    }
  }
}
