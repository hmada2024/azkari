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
        // الخطوة 1: تشغيل التطبيق والانتظار حتى يتم تحميله بالكامل
        await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
        await tester.pumpAndSettle(); // انتظار أولي للاستقرار
        expect(find.text('أذكاري'), findsOneWidget);

        // الخطوة 2: الانتقال إلى شاشة "تقدمي"
        await tester.tap(find.byKey(const Key('bottom_nav_progress')));
        await tester.pumpAndSettle(); // انتظر اكتمال الانتقال
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

        // [الإصلاح الحاسم] هنا يكمن مفتاح الحل.
        // بعد النقر على "إضافة"، تحدث سلسلة من العمليات:
        // 1. استدعاء await notifier.addTasbih()
        // 2. إغلاق النافذة المنبثقة
        // 3. إبطال الـ provider
        // 4. إعادة بناء الواجهة بالبيانات الجديدة
        // `pumpAndSettle` يجبر الاختبار على انتظار اكتمال كل هذه السلسلة.
        await tester.pumpAndSettle();

        // الآن بعد أن استقرت الواجهة، يمكننا التحقق بثقة
        expect(find.text(newDhikrText), findsOneWidget);
        final newDhikrRow = find.ancestor(
            of: find.text(newDhikrText), matching: find.byType(InkWell));
        expect(
            find.descendant(of: newDhikrRow, matching: find.text('غير محدد')),
            findsOneWidget);

        // الخطوة 5: تحديد هدف للذكر الجديد
        await tester.tap(find.text(newDhikrText));
        await tester.pumpAndSettle(); // انتظر ظهور نافذة تعديل الهدف

        await tester.enterText(find.byType(TextField).last, '77');
        await tester.tap(find.text('حفظ'));
        await tester.pumpAndSettle(); // انتظر اكتمال الحفظ وإعادة بناء الواجهة

        // تحقق من أن الهدف قد تم تحديثه في القائمة
        expect(find.text('77 مرة'), findsOneWidget);

        // الخطوة 6: العودة إلى شاشة "تقدمي" والتحقق من التغيير
        await tester.pageBack(); // طريقة أكثر موثوقية للعودة
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

        // الخطوة 7: العودة إلى "إدارة أهدافي" لحذف الذكر
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // الخطوة 8: حذف الذكر بالسحب
        await tester.drag(find.text(newDhikrText), const Offset(500.0, 0.0));
        await tester
            .pumpAndSettle(); // انتظر اكتمال انيميشن الحذف وإعادة بناء الواجهة

        // تحقق من أن الذكر قد تم حذفه بالفعل
        expect(find.text(newDhikrText), findsNothing);
      },
    );
  });
}
