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
  setUpAll(() => initializeDateFormatting('ar'));

  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  final completedDay = todayDateOnly.subtract(const Duration(days: 2));

  final mockData = {
    completedDay: DailyStat(type: StatDayType.past, percentage: 1.0),
    todayDateOnly: DailyStat(type: StatDayType.today, percentage: 0.2),
  };

  testWidgets('StatisticsView renders day cells correctly',
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

    // ✨ [إصلاح] هذه الدالة أكثر دقة في العثور على الخلية نفسها.
    Widget findDayCellWidget(int day) {
      final dayTextFinder = find.text(day.toString());
      final dayCellFinder =
          find.ancestor(of: dayTextFinder, matching: find.byType(Container));
      // نتأكد من أننا نختار الحاوية التي لها decoration، وهي الخلية الداخلية.
      final cellWidgets = tester.widgetList<Container>(dayCellFinder);
      return cellWidgets.firstWhere((w) =>
          (w.decoration as BoxDecoration?)?.color != null ||
          (w.decoration as BoxDecoration?)?.border != null);
    }

    final completedCell = findDayCellWidget(completedDay.day) as Container;
    expect((completedCell.decoration as BoxDecoration).color,
        AppColors.success.withOpacity(0.9));

    final todayCell = findDayCellWidget(todayDateOnly.day) as Container;
    expect(((todayCell.decoration as BoxDecoration).border as Border).top.color,
        AppColors.primary);
  });
}
