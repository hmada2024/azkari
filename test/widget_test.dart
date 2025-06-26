// test/widget_test.dart
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/presentation/shell/app_shell.dart'; // ١. استيراد الشاشة الرئيسية مباشرة
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // سنقوم بإنشاء اختبار جديد أكثر تركيزاً
  testWidgets('AppShell (Home Screen) builds successfully',
      (WidgetTester tester) async {
    // الخطوة 1: قم ببناء الشاشة الرئيسية مباشرة
    // نحن نلفها بـ MaterialApp لتوفير البيئة التي تحتاجها (مثل Theming, Directionality)
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // قم بتوفير أي بيانات وهمية تحتاجها الشاشة الرئيسية لتعمل
          categoriesProvider.overrideWith((ref) => ['أذكار الصباح']),
          // أضف أي overrides أخرى إذا لزم الأمر
        ],
        child: const MaterialApp(
          // ٢. نلف الويدجت بـ MaterialApp
          home: AppShell(), // ٣. نبني AppShell مباشرة، ونتجاهل SplashScreen
        ),
      ),
    );

    // الخطوة 2: انتظر إطاراً واحداً حتى يكتمل البناء
    await tester.pump();

    // الخطوة 3: تحقق من وجود العناصر الأساسية في الشاشة الرئيسية
    // لا يوجد مؤشر دوار، لا يوجد تأخير، لا يوجد pumpAndSettle
    expect(find.text('أذكاري'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
