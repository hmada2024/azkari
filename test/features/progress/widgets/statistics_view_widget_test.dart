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
            theme: ThemeData(
                brightness: Brightness.light, cardColor: Colors.white),
            home: const Scaffold(body: StatisticsView())),
      ),
    );
    await tester.pumpAndSettle();

    // ✨ [الإصلاح القاطع]
    // 1. نجد النص الفريد لليوم المطلوب.
    final dayTextFinder = find.text(completedDay.day.toString());
    expect(dayTextFinder, findsOneWidget);

    // 2. نبحث عن "الجد" (ancestor) الذي هو من نوع Container والذي هو "ابن" (descendant) للـ GridView.
    // هذا يضمن أننا نختار الخلية الصحيحة من الشبكة.
    final parentCellFinder = find.ancestor(
        of: dayTextFinder,
        matching: find.descendant(
            of: find.byType(GridView), matching: find.byType(Container)));
    expect(parentCellFinder, findsWidgets);

    // 3. الآن بعد أن وجدنا الخلية الأبوية، نتحقق من لونها.
    final container = tester.widget<Container>(parentCellFinder.first);
    expect((container.decoration as BoxDecoration).color,
        AppColors.success.withOpacity(0.9));
  });
}
