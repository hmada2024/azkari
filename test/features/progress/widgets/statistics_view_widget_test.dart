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

    // ✨ [إصلاح نهائي ومؤكد] هذا هو أبسط وأقوى Finder.
    // 1. يجد كل الحاويات (Containers).
    // 2. يبحث عن الحاوية التي تحتوي بداخلها على نص رقم اليوم المطلوب.
    final cellFinder = find
        .ancestor(
            of: find.text(completedDay.day.toString()),
            matching: find.byType(Container))
        .first;

    final containerWidget = tester.widget<Container>(cellFinder);

    // بما أن هناك حاوية خارجية وحاوية داخلية للون، نحتاج للتأكد من أننا نختبر الحاوية الصحيحة.
    // الحاوية الداخلية هي التي لها decoration.
    final decoration = containerWidget.decoration as BoxDecoration?;

    expect(decoration, isNotNull,
        reason: 'The day cell container should have a decoration');
    expect(decoration!.color, AppColors.success.withOpacity(0.9));
  });
}
