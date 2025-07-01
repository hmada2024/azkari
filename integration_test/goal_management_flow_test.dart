// integration_test/goal_management_flow_test.dart
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

        // هذا هو السطر الذي سيغير كل شيء
        await tester.tap(find.text('إضافة'));

ر        // بعد النقر، تحدث سلسلة من العمليات غير المتزامنة (حفظ في قاعدة البيانات،
        // إبطال الـ provider، إغلاق الـ dialog، إعادة بناء الواجهة).
        // يجب أن ننتظر حتى تستقر الواجهة تمامًا قبل محاولة العثور على العنصر الجديد.
        // `pumpAndSettle` يفعل ذلك بالضبط.
        await tester.pumpAndSettle(
            const Duration(seconds: 2)); // نعطيه وقتاً إضافياً للاحتياط

        // الآن بعد أن استقرت الواجهة، يمكننا البحث بثقة.
        expect(find.text(newDhikrText), findsOneWidget);

        final newDhikrRow = find.ancestor(
            of: find.text(newDhikrText), matching: find.byType(InkWell));
        expect(
            find.descendant(of: newDhikrRow, matching: find.text('غير محدد')),
            findsOneWidget);

        await tester.tap(find.text(newDhikrText));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '77');
        await tester.tap(find.text('حفظ'));
        await tester.pumpAndSettle(
            const Duration(seconds: 2)); // ننتظر الاستقرار هنا أيضًا

        // الآن `pumpUntilFound` لم يعد ضروريًا، ولكن يمكن استخدامه كطبقة أمان إضافية
        await tester.pumpUntilFound(find.text('77 مرة'));

        // للخروج من الشاشة، بدلاً من الاعتماد على السياق الداخلي، نستخدم زر الرجوع العام
        await tester.pageBack();
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
      // نستخدم pump فقط لتجنب الانتظار غير الضروري إذا كان pumpAndSettle يعلق
      await pump(const Duration(milliseconds: 200));
      if (any(finder)) {
        found = true;
        break;
      }
    }
    if (!found) {
      // لتصحيح الأخطاء، اطبع شجرة الويدجات
      // debugDumpApp();
      throw StateError('Widget not found after timeout: $finder');
    }
  }
}
