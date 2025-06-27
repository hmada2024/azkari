// integration_test/tasbih_add_delete_test.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:azkari/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ✨ [الإصلاح النهائي]: إعداد بيئة اختبار نظيفة قبل التشغيل.
  setUpAll(() async {
    // تهيئة FFI لمنصات سطح المكتب
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // الحصول على مسار قاعدة البيانات
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    const dbName = "azkar.db";
    String path = join(documentsDirectory.path, dbName);

    // حذف قاعدة البيانات الموجودة مسبقًا لضمان بدء الاختبار من حالة نظيفة
    final dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      debugPrint("Deleted existing database at $path for a clean test run.");
    }
  });

  const testTimeout = Timeout(Duration(minutes: 2));

  testWidgets('إضافة وحذف تسبيح مخصص بنجاح', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;

    app.main();
    await tester.pumpAndSettle();

    // يجب أن يظهر الآن سجل "Copying from assets..."

    await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
    await tester.pumpAndSettle();

    final openListButton = find.byTooltip('اختيار الذكر');
    await tester.tap(openListButton);
    await tester.pumpAndSettle();

    final uniqueTasbihText =
        'ذكر اختباري ${DateTime.now().millisecondsSinceEpoch}';

    await tester.tap(find.byTooltip('إضافة ذكر جديد'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), uniqueTasbihText);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة'));
    await tester.pumpAndSettle();

    expect(find.text('تمت الإضافة بنجاح'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // إغلاق قائمة الاختيار
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    // إعادة فتح القائمة للتحقق من وجود الذكر الجديد
    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    expect(find.text(uniqueTasbihText), findsOneWidget);

    final deleteButtonFinder = find.descendant(
      of: find.widgetWithText(ListTile, uniqueTasbihText),
      matching: find.byIcon(Icons.delete_outline),
    );
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    expect(find.text('تم الحذف بنجاح'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    expect(find.text(uniqueTasbihText), findsNothing);
  }, timeout: testTimeout);
}
