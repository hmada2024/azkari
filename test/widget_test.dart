// test/widget_test.dart
// ✨ [إصلاح]: تم إصلاح هذا الاختبار الافتراضي.
// المشكلة كانت أن MyApp تعتمد على Riverpod، ولكن الاختبار لم يقم بتوفير ProviderScope.
// الحل هو تغليف MyApp بـ ProviderScope تماماً كما نفعل في main.dart.
import 'package:azkari/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    // بناء تطبيقنا وتشغيل frame.
    // ✨ تم إضافة ProviderScope هنا لحل مشكلة الاختبار.
    await tester.pumpWidget(const ProviderScope(
      child: MyApp(),
    ));

    // انتظر حتى تنتهي جميع الـ frames والتحميلات الأولية (مثل شاشة البداية).
    await tester.pumpAndSettle();

    // تأكد من أننا وصلنا إلى الشاشة الرئيسية وأن عنوانها "أذكاري" موجود.
    expect(find.text('أذكاري'), findsOneWidget);

    // تأكد من وجود أيقونة الإعدادات.
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
