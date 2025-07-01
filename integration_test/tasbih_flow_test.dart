// integration_test/tasbih_flow_test.dart

import 'package:azkari/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  // التأكد من تهيئة بيئة الاختبار التكاملي
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tasbih End-to-End Flow Test', () {
    testWidgets(
      'Full user journey: Using tasbih, changing dhikr, and verifying progress',
      (WidgetTester tester) async {
        // الخطوة 1: ابدأ التطبيق وانتظر اكتمال التحميل (شاشة البداية)
        await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
        // انتظر حتى تختفي شاشة البداية وتظهر الشاشة الرئيسية
        // نضع مدة طويلة لضمان تحميل قاعدة البيانات بشكل كامل في المرة الأولى
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // -- رحلة السبحة --

        // الخطوة 2: انتقل إلى شاشة السبحة
        await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
        await tester.pumpAndSettle();

        // تحقق من أننا في شاشة السبحة وأن الذكر الافتراضي (الاستغفار) ظاهر
        expect(find.text('السبحة'), findsOneWidget);
        expect(find.textContaining('أَسْتَغْفِرُ اللَّهَ'), findsOneWidget);

        // الخطوة 3: قم بزيادة العداد للذكر الأول 3 مرات
        final counterButton = find.byType(GestureDetector).last;
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.tap(counterButton);
        await tester.pump(); // pump واحد لرؤية التغيير
        expect(find.text('3'), findsOneWidget);

        // الخطوة 4: افتح قائمة اختيار الذكر
        await tester.tap(find.byTooltip('اختيار الذكر'));
        await tester.pumpAndSettle();

        // الخطوة 5: اختر ذكرًا آخر (الحوقلة)
        // نفترض أن "الحوقلة" موجودة في القائمة بناءً على بياناتنا الافتراضية
        await tester
            .tap(find.text('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ'));
        await tester.pumpAndSettle(); // انتظر إغلاق النافذة وتحديث الواجهة

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

        // تحقق من تقدم الذكر الأول (الاستغفار)
        final goal1Finder = find.ancestor(
            of: find.text('الاستغفار'), matching: find.byType(Column));
        expect(find.descendant(of: goal1Finder, matching: find.text('3 / 100')),
            findsOneWidget);

        // تحقق من تقدم الذكر الثاني (الحوقلة)
        final goal2Finder = find.ancestor(
            of: find.text('الحوقلة'), matching: find.byType(Column));
        expect(find.descendant(of: goal2Finder, matching: find.text('5 / 100')),
            findsOneWidget);

        // لقد نجح الاختبار! الرحلة الكاملة تعمل كما هو متوقع.
      },
    );
  });
}
