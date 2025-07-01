// lib/features/progress/providers/statistics_provider.dart
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
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

  StatisticsNotifier(this._ref) : super(const StatisticsState()) {
    fetchMonthlyStats();
  }

  Future<void> fetchMonthlyStats() async {
    if (_isFetching) return;

    // ✨ [الإصلاح] إضافة حارس للتأكد من أن الـ Notifier لم يتم تدميره قبل بدء العملية.
    if (!mounted) return;

    _isFetching = true;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = await _ref.read(azkarRepositoryProvider.future);
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);

      final startDate = DateTime(today.year, today.month, 1);
      final endDate =
          DateTime(today.year, today.month + 1, 0); // آخر يوم في الشهر

      final formatter = intl.DateFormat('yyyy-MM-dd');

      final monthlyProgress = await repo.getMonthlyProgressSummary(
          formatter.format(startDate), formatter.format(endDate));

      // ✨ [الإصلاح] إضافة حارس آخر بعد عمليات الـ await، لأن الـ Notifier قد يتم تدميره أثناء الانتظار.
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
    } catch (e, st) {
      if (kDebugMode) {
        print("Error in StatisticsNotifier: $e");
        print(st);
      }

      // ✨ [الإصلاح] إضافة الحارس الأهم هنا، قبل تحديث الحالة في كتلة الـ catch.
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
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
    notifier.fetchMonthlyStats();
  });

  ref.listen(dailyGoalsProvider, (_, __) {
    notifier.fetchMonthlyStats();
  });

  return notifier;
});
