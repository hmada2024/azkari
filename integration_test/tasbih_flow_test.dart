// integration_test/tasbih_flow_test.dart
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_header.dart';
import 'package:azkari/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupIntegrationTest();
  });

  group('Tasbih End-to-End Flow Test', () {
    testWidgets(
      'Full user journey: Using tasbih, changing dhikr, and verifying progress',
      (WidgetTester tester) async {
        await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
        await tester.pumpUntilFound(find.text('أذكاري'));

        // -- رحلة السبحة --
        await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
        await tester.pumpAndSettle();

        // ✨ [الإصلاح] البحث عن العنوان داخل الـ TasbihHeader لضمان الدقة
        expect(
            find.descendant(
                of: find.byType(TasbihHeader), matching: find.text('السبحة')),
            findsOneWidget);
        expect(find.textContaining('أَسْتَغْفِرُ اللَّهَ'), findsOneWidget);

        final counterButton = find.byType(TasbihCounterButton);
        expect(counterButton, findsOneWidget);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.pump();
        expect(find.text('3'), findsOneWidget);

        await tester.tap(find.byTooltip('اختيار الذكر'));
        await tester.pumpAndSettle();
        final dhikrToSelect =
            find.text('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ');
        await tester.ensureVisible(dhikrToSelect);
        await tester.tap(dhikrToSelect);
        await tester.pumpAndSettle();

        expect(find.textContaining('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ'),
            findsOneWidget);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.pump();
        expect(find.text('5'), findsOneWidget);

        // -- التحقق من شاشة التقدم --
        await tester.tap(find.byKey(const Key('bottom_nav_progress')));
        await tester.pumpAndSettle();

        // ✨ [الإصلاح] البحث عن العنوان داخل الـ AppBar لضمان الدقة
        expect(
            find.descendant(
                of: find.byType(AppBar), matching: find.text('تقدمي')),
            findsOneWidget);

        final goal1Finder = find.ancestor(
            of: find.text('الاستغفار'), matching: find.byType(Column));
        expect(find.descendant(of: goal1Finder, matching: find.text('3 / 100')),
            findsOneWidget);

        final goal2Finder = find.ancestor(
            of: find.text('الحوقلة'), matching: find.byType(Column));
        expect(find.descendant(of: goal2Finder, matching: find.text('5 / 100')),
            findsOneWidget);
      },
    );
  });
}

extension on WidgetTester {
  Future<void> pumpUntilFound(Finder finder,
      {Duration timeout = const Duration(seconds: 20)}) async {
    bool found = false;
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pumpAndSettle();
      if (any(finder)) {
        found = true;
        break;
      }
    }
    if (!found) {
      throw StateError('Widget not found after timeout: $finder');
    }
  }
}
