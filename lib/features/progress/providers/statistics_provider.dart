// lib/features/progress/providers/statistics_provider.dart
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
enum StatDayType { past, today, future }
class DailyStat {
  final StatDayType type;
  final double percentage;
  DailyStat({required this.type, this.percentage = 0.0});
  bool get isCompleted => percentage >= 1.0;
}
class StatisticsState {
  final bool isLoading;
  final Map<DateTime, DailyStat> data;
  final String? error;
  const StatisticsState(
      {this.isLoading = true, this.data = const {}, this.error});
  StatisticsState copyWith(
      {bool? isLoading, Map<DateTime, DailyStat>? data, String? error}) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}
class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final Ref _ref;
  bool _isFetching = false;
  int _totalDailyTarget = 0;
  StatisticsNotifier(this._ref) : super(const StatisticsState()) {
    fetchMonthlyStats();
  }
  Future<void> fetchMonthlyStats() async {
    if (_isFetching) return;
    if (!mounted) return;
    _isFetching = true;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = await _ref.read(goalsRepositoryProvider.future);
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      final startDate = DateTime(today.year, today.month, 1);
      final endDate = DateTime(today.year, today.month + 1, 0);
      final formatter = intl.DateFormat('yyyy-MM-dd');
      final monthlyProgress = await repo.getMonthlyProgressSummary(
          formatter.format(startDate), formatter.format(endDate));
      final dailyGoals =
          _ref.read(dailyGoalsStateProvider).goals.valueOrNull ?? [];
      _totalDailyTarget =
          dailyGoals.fold(0, (sum, goal) => sum + goal.targetCount);
      if (!mounted) return;
      Map<DateTime, DailyStat> dailyStatuses = {};
      for (var i = 0; i < endDate.day; i++) {
        final date = startDate.add(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (dateOnly.isAfter(todayDateOnly)) {
          dailyStatuses[dateOnly] = DailyStat(type: StatDayType.future);
          continue;
        }
        final percentage = monthlyProgress[formatter.format(dateOnly)] ?? 0.0;
        dailyStatuses[dateOnly] = DailyStat(
          type: dateOnly.isAtSameMomentAs(todayDateOnly)
              ? StatDayType.today
              : StatDayType.past,
          percentage: percentage,
        );
      }
      state = state.copyWith(isLoading: false, data: dailyStatuses);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      _isFetching = false;
    }
  }
  void updateTodayProgress(List<DailyGoalModel> currentGoals) {
    if (state.isLoading || !mounted) return;
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final currentTotalProgress =
        currentGoals.fold(0, (sum, goal) => sum + goal.currentProgress);
    final newPercentage = (_totalDailyTarget > 0)
        ? (currentTotalProgress / _totalDailyTarget).clamp(0.0, 1.0)
        : 0.0;
    final updatedData = Map<DateTime, DailyStat>.from(state.data);
    updatedData[todayDateOnly] =
        DailyStat(type: StatDayType.today, percentage: newPercentage);
    state = state.copyWith(data: updatedData);
  }
}
final statisticsProvider =
    StateNotifierProvider.autoDispose<StatisticsNotifier, StatisticsState>(
        (ref) {
  final notifier = StatisticsNotifier(ref);
  ref.listen<GoalManagementState>(goalManagementStateProvider,
      (previous, next) {
    if (previous?.items.value != next.items.value) {
      notifier.fetchMonthlyStats();
    }
  });
  ref.listen<DailyGoalsState>(dailyGoalsStateProvider, (_, next) {
    if (next.goals.hasValue) {
      notifier.updateTodayProgress(next.goals.value!);
    }
  });
  return notifier;
});