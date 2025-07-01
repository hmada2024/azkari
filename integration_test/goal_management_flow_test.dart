// integration_test/goal_management_flow_test.dart
import 'package:azkari/features/goal_management/screens/goal_management_screen.dart';
import 'package:azkari/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ✨ [الإصلاح] تصحيح مسار الاستيراد ليكون نسبيًا من المجلد الجذر
import '../test/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // استخدام setUp لضمان بيئة نظيفة قبل كل اختبار في هذا الملف
  setUp(() async {
    await setupIntegrationTest();
  });

  group('Goal Management End-to-End Flow Test', () {
    testWidgets(
      'Full user journey: Adding, setting a goal for, and deleting a custom dhikr',
      (WidgetTester tester) async {
        // --- الإعداد والبدء ---
        await tester.pumpWidget(const ProviderScope(child: app.MyApp()));

        // الانتظار الديناميكي يبقى كما هو لأنه الأفضل
        await tester.pumpUntilFound(find.text('أذكاري'),
            timeout: const Duration(seconds: 20));

        // --- رحلة إدارة الأهداف ---

        // الخطوة 1: انتقل إلى شاشة "تقدمي"
        await tester.tap(find.byKey(const Key('bottom_nav_progress')));
        await tester.pumpAndSettle();
        expect(find.text('تقدمي'), findsOneWidget);

        // الخطوة 2: انتقل إلى شاشة "إدارة الأهداف"
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();
        expect(find.text('إدارة أهدافي'), findsOneWidget);

        // الخطوة 3: أضف ذكرًا جديدًا
        const newDhikrText = 'ذكر جديد للاختبار';
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), newDhikrText);
        await tester.tap(find.text('إضافة'));
        await tester.pumpAndSettle();

        // تحقق من ظهور الذكر الجديد في القائمة
        expect(find.text(newDhikrText), findsOneWidget);
        final newDhikrRow = find.ancestor(
            of: find.text(newDhikrText), matching: find.byType(InkWell));
        expect(
            find.descendant(of: newDhikrRow, matching: find.text('غير محدد')),
            findsOneWidget);

        // الخطوة 4: حدد هدفًا عدديًا لهذا الذكر
        await tester.tap(find.text(newDhikrText));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).last, '77');
        await tester.tap(find.text('حفظ'));
        await tester.pumpAndSettle();

        // تحقق من تحديث الهدف في القائمة
        expect(find.descendant(of: newDhikrRow, matching: find.text('77 مرة')),
            findsOneWidget);

        // الخطوة 5: عد إلى شاشة "تقدمي" وتحقق من ظهور الهدف الجديد
        Navigator.of(tester.element(find.byType(GoalManagementScreen))).pop();
        await tester.pumpAndSettle();

        expect(find.text('تقدمي'), findsOneWidget);
        expect(find.text(newDhikrText), findsOneWidget);
        final progressRow = find.ancestor(
            of: find.text(newDhikrText), matching: find.byType(Column));
        expect(find.descendant(of: progressRow, matching: find.text('0 / 77')),
            findsOneWidget);

        // الخطوة 6: قم بحذف الذكر الذي أضفته وتأكد من اختفائه
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.drag(find.text(newDhikrText), const Offset(500.0, 0.0));
        await tester.pumpAndSettle();

        // تحقق من اختفاء الذكر
        expect(find.text(newDhikrText), findsNothing);
      },
    );
  });
}

extension on WidgetTester {
  Future<void> pumpUntilFound(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    bool found = false;
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      // تم تعديل هذه لتعمل بشكل أفضل مع pumpAndSettle
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
