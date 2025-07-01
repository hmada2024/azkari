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
  // تأكد من أن اليوم المكتمل ليس في بداية الشهر لتجنب النجاح بالصدفة
  final completedDay = DateTime(today.year, today.month, 25);

  final mockData = {
    completedDay: DailyStat(type: StatDayType.past, percentage: 1.0),
  };

  testWidgets('StatisticsView renders COMPLETED day cell correctly',
      (WidgetTester tester) async {
    // ✨ [الإصلاح النهائي القاطع] - نجعل شاشة الاختبار طويلة جداً
    // هذا يضمن أن GridView بالكامل سيتم بناؤه ورسمه.
    await tester.binding.setSurfaceSize(const Size(800, 3000));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsProvider.overrideWith((ref) => MockStatisticsNotifier(
              StatisticsState(isLoading: false, data: mockData)))
        ],
        child: const MaterialApp(
            home:
                Scaffold(body: SingleChildScrollView(child: StatisticsView()))),
      ),
    );
    await tester.pumpAndSettle();

    // الآن بما أن الشاشة طويلة، فإن البحث بالمفتاح سيعمل 100%
    final cellFinder = find.byKey(ValueKey('stat_cell_${completedDay.day}'));

    expect(cellFinder, findsOneWidget);

    final container = tester.widget<Container>(cellFinder);
    expect((container.decoration as BoxDecoration).color,
        AppColors.success.withOpacity(0.9));

    // إعادة حجم الشاشة لوضعه الطبيعي بعد الاختبار
    await tester.binding.setSurfaceSize(null);
  });
}
