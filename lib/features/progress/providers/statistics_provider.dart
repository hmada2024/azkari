// lib/features/progress/providers/statistics_provider.dart
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:azkari/features/goal_management/goal_management_provider.dart';
import 'package:flutter/foundation.dart';
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

  const StatisticsState({
    this.isLoading = true,
    this.data = const {},
    this.error,
  });

  StatisticsState copyWith({
    bool? isLoading,
    Map<DateTime, DailyStat>? data,
    String? error,
  }) {
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

  StatisticsNotifier(this._ref) : super(const StatisticsState()) {
    fetchMonthlyStats();
  }

  Future<void> fetchMonthlyStats() async {
    if (_isFetching) return;

    _isFetching = true;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = await _ref.read(adhkarRepositoryProvider.future);
      final formatter = intl.DateFormat('yyyy-MM-dd');
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);

      final startDate = DateTime(today.year, today.month, 1);
      final endDate = today;

      final currentGoalsSetup = await repo.getTodayGoalsWithProgress();

      Map<DateTime, DailyStat> dailyStatuses = {};

      for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final date = startDate.add(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (dateOnly.isAfter(todayDateOnly)) {
          dailyStatuses[dateOnly] = DailyStat(type: StatDayType.future);
          continue;
        }

        final goalsForDay =
            await repo.getGoalsWithProgressForDate(formatter.format(date));

        if (currentGoalsSetup.isEmpty) {
          dailyStatuses[dateOnly] = DailyStat(
            type: dateOnly.isAtSameMomentAs(todayDateOnly)
                ? StatDayType.today
                : StatDayType.past,
            percentage: 1.0,
          );
          continue;
        }

        if (goalsForDay.isEmpty) {
          dailyStatuses[dateOnly] = DailyStat(
            type: dateOnly.isAtSameMomentAs(todayDateOnly)
                ? StatDayType.today
                : StatDayType.past,
            percentage: 0.0,
          );
          continue;
        }

        int totalTarget =
            goalsForDay.fold(0, (sum, goal) => sum + goal.targetCount);
        int totalProgress =
            goalsForDay.fold(0, (sum, goal) => sum + goal.currentProgress);

        double percentage = (totalTarget > 0)
            ? (totalProgress / totalTarget).clamp(0.0, 1.0)
            : 1.0;

        dailyStatuses[dateOnly] = DailyStat(
          type: dateOnly.isAtSameMomentAs(todayDateOnly)
              ? StatDayType.today
              : StatDayType.past,
          percentage: percentage,
        );
      }

      state = state.copyWith(isLoading: false, data: dailyStatuses);
    } catch (e, st) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (kDebugMode) {
        print(st);
      }
    } finally {
      _isFetching = false;
    }
  }
}

final statisticsProvider =
    StateNotifierProvider.autoDispose<StatisticsNotifier, StatisticsState>(
        (ref) {
  final notifier = StatisticsNotifier(ref);
  ref.listen(goalManagementProvider, (_, __) {
    // ✨ [تبسيط] استدعاء الدالة المحدثة عند تغيير الأهداف
    notifier.fetchMonthlyStats();
  });
  return notifier;
});
