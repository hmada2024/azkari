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
  final completedDay = today.subtract(const Duration(days: 2));

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
        child: MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: const Scaffold(body: StatisticsView())),
      ),
    );
    await tester.pumpAndSettle();

    final cellFinder = find.byWidgetPredicate((widget) {
      if (widget is! Container || widget.decoration == null) return false;

      final textFinder = find.descendant(
          of: find.byWidget(widget),
          matching: find.text(completedDay.day.toString()));
      return textFinder.evaluate().isNotEmpty;
    });

    expect(cellFinder, findsOneWidget);

    final cellWidget = tester.widget<Container>(cellFinder);
    expect((cellWidget.decoration as BoxDecoration).color,
        AppColors.success.withOpacity(0.9));
  });
}
