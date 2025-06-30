// lib/features/progress/providers/statistics_provider.dart
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:azkari/features/goal_management/goal_management_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

enum DayStatus { completed, notCompleted, isToday, future }

enum StatPeriod { weekly, monthly }

class StatisticsState {
  final bool isLoading;
  final StatPeriod period;
  final Map<DateTime, DayStatus> data;
  final String? error;

  const StatisticsState({
    this.isLoading = true,
    this.period = StatPeriod.weekly,
    this.data = const {},
    this.error,
  });

  StatisticsState copyWith({
    bool? isLoading,
    StatPeriod? period,
    Map<DateTime, DayStatus>? data,
    String? error,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      period: period ?? this.period,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final Ref _ref;
  bool _isFetching = false;

  StatisticsNotifier(this._ref) : super(const StatisticsState()) {
    fetchStatsForPeriod(StatPeriod.weekly);
  }

  // [جديد] Getter عام للوصول الآمن إلى الفترة الحالية من خارج الكلاس
  StatPeriod get currentPeriod => state.period;

  Future<void> fetchStatsForPeriod(StatPeriod period) async {
    if (_isFetching) return;

    _isFetching = true;
    if (state.period != period) {
      state = state.copyWith(isLoading: true, period: period, error: null);
    } else {
      state = state.copyWith(period: period, error: null);
    }

    try {
      final repo = await _ref.read(adhkarRepositoryProvider.future);
      final formatter = intl.DateFormat('yyyy-MM-dd');
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);

      late DateTime startDate;
      final endDate = today;

      if (period == StatPeriod.weekly) {
        startDate = today.subtract(Duration(days: today.weekday - 1));
      } else {
        startDate = DateTime(today.year, today.month, 1);
      }

      final goals = await repo.getTodayGoalsWithProgress();

      Map<DateTime, DayStatus> dailyStatuses = {};

      for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final date = startDate.add(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (dateOnly.isAfter(todayDateOnly)) {
          dailyStatuses[dateOnly] = DayStatus.future;
          continue;
        }

        if (dateOnly.isAtSameMomentAs(todayDateOnly)) {
          dailyStatuses[dateOnly] = DayStatus.isToday;
        }

        if (!dailyStatuses.containsKey(dateOnly)) {
          final goalsForDay =
              await repo.getGoalsWithProgressForDate(formatter.format(date));
          bool allCompleted = true;

          if (goalsForDay.isEmpty && goals.isNotEmpty) {
            allCompleted = false;
          } else if (goalsForDay.isEmpty && goals.isEmpty) {
            allCompleted = true;
          } else {
            for (var goal in goalsForDay) {
              if (!goal.isCompleted) {
                allCompleted = false;
                break;
              }
            }
          }
          dailyStatuses[dateOnly] =
              allCompleted ? DayStatus.completed : DayStatus.notCompleted;
        }
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
  // يتم إنشاء الـ Notifier أولاً
  final notifier = StatisticsNotifier(ref);

  // الآن، بعد أن تم إنشاء الـ Notifier، يمكننا الاستماع بأمان
  ref.listen(goalManagementProvider, (_, __) {
    // [تصحيح] نستخدم الـ getter العام بدلاً من الوصول المباشر لـ .state
    notifier.fetchStatsForPeriod(notifier.currentPeriod);
  });

  // أخيرًا، نعيد الـ Notifier الذي تم إنشاؤه
  return notifier;
});
