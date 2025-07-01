// test/features/progress/widgets/statistics_view_widget_test.dart

import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/features/progress/providers/statistics_provider.dart';
import 'package:azkari/features/progress/widgets/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class MockStatisticsNotifier extends StateNotifier<StatisticsState>
    implements StatisticsNotifier {
  MockStatisticsNotifier(super.state);

  @override
  Future<void> fetchMonthlyStats() async {}

  @override
  bool get mounted => true;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  final dayBeforeYesterday = todayDateOnly.subtract(const Duration(days: 2));

  final mockData = {
    dayBeforeYesterday: DailyStat(type: StatDayType.past, percentage: 1.0),
    todayDateOnly: DailyStat(type: StatDayType.today, percentage: 0.2),
  };

  testWidgets('StatisticsView renders day cells with correct styles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsProvider.overrideWith((ref) => MockStatisticsNotifier(
              StatisticsState(isLoading: false, data: mockData)))
        ],
        child: const MaterialApp(home: Scaffold(body: StatisticsView())),
      ),
    );
    await tester.pumpAndSettle();

    Finder findDayCellByNumber(int day) {
      return find
          .ancestor(
              of: find.text(day.toString()), matching: find.byType(Container))
          .first;
    }

    final completedCell =
        tester.widget<Container>(findDayCellByNumber(dayBeforeYesterday.day));
    expect((completedCell.decoration as BoxDecoration).color,
        AppColors.success.withOpacity(0.9));

    final todayCell =
        tester.widget<Container>(findDayCellByNumber(todayDateOnly.day));
    expect(((todayCell.decoration as BoxDecoration).border as Border).top.color,
        AppColors.primary);
  });
}
