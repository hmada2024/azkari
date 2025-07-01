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
  };

  testWidgets('StatisticsView renders COMPLETED day cell correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsProvider.overrideWith((ref) => MockStatisticsNotifier(
              StatisticsState(isLoading: false, data: mockData)))
        ],
        // ✨ [إصلاح] تم إزالة كلمة const من هنا.
        child: MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: const Scaffold(body: StatisticsView())),
      ),
    );
    await tester.pumpAndSettle();

    final dayTextFinder = find.text(completedDay.day.toString());
    final cellFinder = find
        .descendant(
            of: find.ancestor(
                of: dayTextFinder, matching: find.byType(GridView)),
            matching: find.byWidgetPredicate(
                (widget) => widget is Container && widget.decoration != null))
        .at(completedDay.day - 1);

    final cellWidget = tester.widget<Container>(cellFinder);
    expect((cellWidget.decoration as BoxDecoration).color,
        AppColors.success.withOpacity(0.9));
  });
}
