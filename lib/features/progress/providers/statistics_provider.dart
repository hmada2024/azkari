// lib/features/progress/providers/statistics_provider.dart
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:azkari/features/goal_management/goal_management_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

// ✨ [تغيير] استبدال DayStatus بكلاس أكثر تفصيلاً
enum StatDayType { past, today, future }

/// يمثل بيانات الإحصاء ليوم واحد.
class DailyStat {
  final StatDayType type;

  /// نسبة إنجاز الأهداف (من 0.0 إلى 1.0)
  final double percentage;

  DailyStat({required this.type, this.percentage = 0.0});

  /// هل تم إنجاز جميع الأهداف لهذا اليوم؟
  bool get isCompleted => percentage >= 1.0;
}

enum StatPeriod { weekly, monthly }

class StatisticsState {
  final bool isLoading;
  final StatPeriod period;
  // ✨ [تغيير] استخدام الموديل الجديد
  final Map<DateTime, DailyStat> data;
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
    Map<DateTime, DailyStat>? data,
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

  StatPeriod get currentPeriod => state.period;

  // ✨ [إعادة بناء] تم تحديث منطق هذه الدالة بالكامل لحساب النسب المئوية
  Future<void> fetchStatsForPeriod(StatPeriod period) async {
    if (_isFetching) return;

    _isFetching = true;
    // عرض التحميل فقط عند التبديل بين أسبوعي/شهري
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

      // جلب الأهداف المحددة حاليًا لتحديد ما إذا كان المستخدم قد وضع أهدافًا أم لا
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

        // إذا لم يكن لدى المستخدم أي أهداف محددة على الإطلاق، نعتبر كل الأيام مكتملة
        if (currentGoalsSetup.isEmpty) {
          dailyStatuses[dateOnly] = DailyStat(
            type: dateOnly.isAtSameMomentAs(todayDateOnly)
                ? StatDayType.today
                : StatDayType.past,
            percentage: 1.0,
          );
          continue;
        }

        // إذا كان لدى المستخدم أهداف، ولكن لا توجد بيانات لهذا اليوم (يعني لم يفعل شيئًا)
        if (goalsForDay.isEmpty) {
          dailyStatuses[dateOnly] = DailyStat(
            type: dateOnly.isAtSameMomentAs(todayDateOnly)
                ? StatDayType.today
                : StatDayType.past,
            percentage: 0.0,
          );
          continue;
        }

        // حساب النسبة المئوية الإجمالية لليوم
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
    notifier.fetchStatsForPeriod(notifier.currentPeriod);
  });
  return notifier;
});
