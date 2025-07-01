// integration_test/tasbih_flow_test.dart
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tasbih End-to-End Flow Test', () {
    testWidgets(
      'Full user journey: Using tasbih, changing dhikr, and verifying progress',
      (WidgetTester tester) async {
        // الخطوة 1: ابدأ التطبيق
        await tester.pumpWidget(const ProviderScope(child: app.MyApp()));

        // ✨ [الإصلاح] انتظار ديناميكي بدلاً من فترة زمنية ثابتة
        // ننتظر ظهور عنوان الشاشة الرئيسية "أذكاري" كدليل على اكتمال التحميل.
        // هذا يضمن أن AppShell قد تم بناؤه وأن أزرار التنقل موجودة.
        await tester.pumpAndSettle(const Duration(seconds: 1)); // ضخ أولي
        await tester.pumpUntilFound(find.text('أذكاري'),
            timeout: const Duration(seconds: 15));

        // -- رحلة السبحة --

        // الخطوة 2: انتقل إلى شاشة السبحة
        await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
        await tester.pumpAndSettle();

        // تحقق من أننا في شاشة السبحة وأن الذكر الافتراضي (الاستغفار) ظاهر
        expect(find.text('السبحة'), findsOneWidget);
        // تم تعديل هذا البحث ليكون أكثر مرونة ويجد الذكر الأول في القائمة
        // بناءً على بيانات V4، الذكر الأول هو "أَسْتَغْفِرُ اللَّهَ"
        expect(find.textContaining('أَسْتَغْفِرُ اللَّهَ'), findsOneWidget);

        // الخطوة 3: قم بزيادة العداد للذكر الأول 3 مرات
        final counterButton = find.byType(TasbihCounterButton);
        expect(counterButton, findsOneWidget);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.pump();
        expect(find.text('3'), findsOneWidget);

        // الخطوة 4: افتح قائمة اختيار الذكر
        await tester.tap(find.byTooltip('اختيار الذكر'));
        await tester.pumpAndSettle();

        // الخطوة 5: اختر ذكرًا آخر (الحوقلة)
        // نفترض أن "الحوقلة" موجودة في القائمة بناءً على بياناتنا الافتراضية
        final dhikrToSelect =
            find.text('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ');
        await tester
            .ensureVisible(dhikrToSelect); // تأكد من أن العنصر مرئي قبل النقر
        await tester.tap(dhikrToSelect);
        await tester.pumpAndSettle();

        // الخطوة 6: تحقق من أن الذكر تغير، وقم بزيادة العداد الجديد 5 مرات
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

        // الخطوة 7: انتقل إلى شاشة "تقدمي"
        await tester.tap(find.byKey(const Key('bottom_nav_progress')));
        await tester.pumpAndSettle();

        // الخطوة 8: تحقق من أن التقدم الذي قمنا به قد انعكس بشكل صحيح
        expect(find.text('تقدمي'), findsOneWidget);

        // البحث عن بطاقة الهدف الأول والتأكد من تقدمها
        final goal1Finder = find.ancestor(
            of: find.text('الاستغفار'), matching: find.byType(Column));
        expect(find.descendant(of: goal1Finder, matching: find.text('3 / 100')),
            findsOneWidget);

        // البحث عن بطاقة الهدف الثاني والتأكد من تقدمها
        final goal2Finder = find.ancestor(
            of: find.text('الحوقلة'), matching: find.byType(Column));
        expect(find.descendant(of: goal2Finder, matching: find.text('5 / 100')),
            findsOneWidget);

        // لقد نجح الاختبار! الرحلة الكاملة تعمل كما هو متوقع.
      },
    );
  });
}

/// امتداد مساعد لـ WidgetTester للانتظار حتى يتم العثور على ويدجت معين.
extension on WidgetTester {
  Future<void> pumpUntilFound(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    bool found = false;
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      if (any(finder)) {
        found = true;
        break;
      }
      await pump(const Duration(milliseconds: 100));
    }

    if (!found) {
      throw StateError('Widget not found after timeout: $finder');
    }
  }
}
