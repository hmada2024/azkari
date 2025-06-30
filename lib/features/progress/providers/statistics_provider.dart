// lib/features/progress/providers/statistics_provider.dart
import 'package:azkari/features/adhkar_list/azkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:meta/meta.dart';

enum StatPeriod { weekly, monthly }

@immutable
class StatisticsState {
  final bool isLoading;
  final StatPeriod period;
  final Map<String, int> data; // <date_string, total_count>
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
    Map<String, int>? data,
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

  StatisticsNotifier(this._ref) : super(const StatisticsState()) {
    fetchStatsForPeriod(StatPeriod.weekly);
  }

  Future<void> fetchStatsForPeriod(StatPeriod period) async {
    state = state.copyWith(isLoading: true, period: period, error: null);
    try {
      final now = DateTime.now();
      late DateTime startDate;
      final endDate = now;

      if (period == StatPeriod.weekly) {
        // الأسبوع يبدأ من يوم الإثنين
        startDate = now.subtract(Duration(days: now.weekday - 1));
      } else {
        // monthly
        startDate = DateTime(now.year, now.month, 1);
      }

      final formatter = intl.DateFormat('yyyy-MM-dd');
      final startDateString = formatter.format(startDate);
      final endDateString = formatter.format(endDate);

      final repository = await _ref.read(adhkarRepositoryProvider.future);
      final fetchedData = await repository.getProgressForDateRange(
          startDateString, endDateString);

      state = state.copyWith(isLoading: false, data: fetchedData);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final statisticsProvider =
    StateNotifierProvider.autoDispose<StatisticsNotifier, StatisticsState>(
        (ref) {
  return StatisticsNotifier(ref);
});
