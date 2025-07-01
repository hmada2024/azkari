// integration_test/goal_management_flow_test.dart
import 'package:azkari/features/goal_management/screens/goal_management_screen.dart';
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

  group('Goal Management End-to-End Flow Test', () {
    testWidgets(
      'Full user journey: Adding, setting a goal for, and deleting a custom dhikr',
      (WidgetTester tester) async {
        await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
        await tester.pumpUntilFound(find.text('أذكاري'));

        await tester.tap(find.byKey(const Key('bottom_nav_progress')));
        await tester.pumpAndSettle();
        expect(
            find.descendant(
                of: find.byType(AppBar), matching: find.text('تقدمي')),
            findsOneWidget);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();
        expect(
            find.descendant(
                of: find.byType(AppBar), matching: find.text('إدارة أهدافي')),
            findsOneWidget);

        const newDhikrText = 'ذكر جديد للاختبار';
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), newDhikrText);
        await tester.tap(find.text('إضافة'));
        // ✨ [الإصلاح النهائي] هنا يكمن الحل.
        // بدلاً من pumpAndSettle، ننتظر تحديدًا ظهور النص الجديد.
        // هذا يضمن أننا ننتظر اكتمال دورة invalidate -> FutureProvider -> UI rebuild.
        await tester.pumpUntilFound(find.text(newDhikrText));

        final newDhikrRow = find.ancestor(
            of: find.text(newDhikrText), matching: find.byType(InkWell));
        expect(
            find.descendant(of: newDhikrRow, matching: find.text('غير محدد')),
            findsOneWidget);

        await tester.tap(find.text(newDhikrText));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '77');
        await tester.tap(find.text('حفظ'));
        // ننتظر أيضًا ظهور النتيجة الجديدة هنا لضمان الموثوقية
        await tester.pumpUntilFound(find.text('77 مرة'));

        Navigator.of(tester.element(find.byType(GoalManagementScreen))).pop();
        await tester.pumpAndSettle();

        expect(
            find.descendant(
                of: find.byType(AppBar), matching: find.text('تقدمي')),
            findsOneWidget);
        expect(find.text(newDhikrText), findsOneWidget);
        final progressRow = find.ancestor(
            of: find.text(newDhikrText), matching: find.byType(Column));
        expect(find.descendant(of: progressRow, matching: find.text('0 / 77')),
            findsOneWidget);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.drag(find.text(newDhikrText), const Offset(500.0, 0.0));
        await tester.pumpAndSettle();
        expect(find.text(newDhikrText), findsNothing);
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
      await pumpAndSettle(const Duration(milliseconds: 200));
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
