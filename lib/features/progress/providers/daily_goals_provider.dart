// lib/features/progress/providers/daily_goals_provider.dart
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// 1. كلاس الحالة المخصص
/// يمثل الحالة الكاملة لميزة الأهداف اليومية.
@immutable
class DailyGoalsState {
  final AsyncValue<List<DailyGoalModel>> goals;

  const DailyGoalsState({
    this.goals = const AsyncValue.loading(),
  });

  DailyGoalsState copyWith({
    AsyncValue<List<DailyGoalModel>>? goals,
  }) {
    return DailyGoalsState(
      goals: goals ?? this.goals,
    );
  }
}

/// 2. المتحكم/المنطق (Notifier)
/// هذا هو مصدر الحقيقة الوحيد للأهداف اليومية.
class DailyGoalsNotifier extends StateNotifier<DailyGoalsState> {
  final Ref _ref;
  DailyGoalsNotifier(this._ref) : super(const DailyGoalsState()) {
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    state = state.copyWith(goals: const AsyncValue.loading());
    try {
      final repository = await _ref.read(goalsRepositoryProvider.future);
      final goalsList = await repository.getTodayGoalsWithProgress();
      if (!mounted) return;
      state = state.copyWith(goals: AsyncValue.data(goalsList));
    } catch (e, st) {
      if (!mounted) return;
      state = state.copyWith(goals: AsyncValue.error(e, st));
    }
  }

  /// دالة عامة لتحديث التقدم في الذاكرة مباشرة دون إعادة جلب البيانات.
  /// هذا هو مفتاح حل مشكلة الأداء.
  void incrementProgress(int tasbihId) {
    // التأكد من أن الحالة تحتوي على بيانات قبل المتابعة
    final currentGoals = state.goals.valueOrNull;
    if (currentGoals == null) return;

    final goalIndex = currentGoals.indexWhere((g) => g.tasbihId == tasbihId);
    if (goalIndex == -1) return;

    final targetGoal = currentGoals[goalIndex];
    // لا نزيد العداد إذا كان الهدف قد اكتمل بالفعل
    if (targetGoal.isCompleted) return;

    final updatedGoal = DailyGoalModel(
      tasbihId: targetGoal.tasbihId,
      tasbihText: targetGoal.tasbihText,
      targetCount: targetGoal.targetCount,
      currentProgress: targetGoal.currentProgress + 1,
    );

    final newGoalsList = List<DailyGoalModel>.from(currentGoals);
    newGoalsList[goalIndex] = updatedGoal;

    state = state.copyWith(goals: AsyncValue.data(newGoalsList));
  }
}

/// 3. الرابط (Provider) الرئيسي
/// يوفر نسخة واحدة من الـ Notifier على مستوى التطبيق.
final dailyGoalsStateProvider =
    StateNotifierProvider<DailyGoalsNotifier, DailyGoalsState>(
  (ref) => DailyGoalsNotifier(ref),
);

/// 4. Provider مشتق لعرض الأهداف المكتملة فقط
/// يستخدم في شاشة السبحة لعرض شرائح الإنجاز.
final completedGoalsProvider = Provider<List<DailyGoalModel>>((ref) {
  final goalsState = ref.watch(dailyGoalsStateProvider);
  return goalsState.goals.maybeWhen(
    data: (goals) => goals.where((goal) => goal.isCompleted).toList(),
    orElse: () => [],
  );
});
