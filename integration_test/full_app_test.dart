// integration_test/full_app_test.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // ✨ [الإصلاح] زيادة وقت الانتظار الافتراضي
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    const dbName = "azkar.db";
    String path = join(documentsDirectory.path, dbName);
    final dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      debugPrint("Deleted existing database at $path for a clean test run.");
    }
  });

  // ✨ [الإصلاح] تشغيل التطبيق مرة واحدة فقط خارج الـ group
  // هذا يضمن أن التطبيق جاهز قبل بدء أي اختبار
  testWidgets('Setup: Start the application', (WidgetTester tester) async {
    app.main();
    // انتظار أطول لضمان تهيئة كل شيء، خاصة على الأجهزة البطيئة
    await tester.pumpAndSettle(const Duration(seconds: 10));
    // التحقق من أن الشاشة الرئيسية قد ظهرت
    expect(find.text('أذكاري'), findsOneWidget);
    debugPrint('SUCCESS: Application started and HomeScreen is visible.');
  });

  group('Full App E2E Tests', () {
    testWidgets('Favorites Flow: Add and verify adhkar in favorites screen',
        (WidgetTester tester) async {
      // التطبيق يعمل بالفعل وجاهز
      expect(find.text('أذكار الصباح'), findsOneWidget);

      await tester.tap(find.text('أذكار الصباح'));
      await tester.pumpAndSettle();

      // ✨ [الإصلاح] انتظار ظهور البطاقات
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(AdhkarCard), findsWidgets,
          reason: 'Adhkar cards should be displayed');

      final firstUnfavorited = find.byIcon(Icons.star_border).first;
      final card =
          find.ancestor(of: firstUnfavorited, matching: find.byType(Card));
      final textFinder =
          find.descendant(of: card, matching: find.byType(Text)).first;
      final targetAdhkarText = tester.widget<Text>(textFinder).data!;

      await tester.tap(firstUnfavorited);
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bottom_nav_favorites')));
      await tester.pumpAndSettle();

      expect(
          find.descendant(
              of: find.byType(AppBar), matching: find.text('المفضلة')),
          findsOneWidget);
      expect(find.text(targetAdhkarText), findsOneWidget);
      debugPrint('SUCCESS: Favorites flow test completed.');
    });

    testWidgets('Tasbih Add/Delete Flow: Add and delete a custom tasbih',
        (WidgetTester tester) async {
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
      await tester.pumpAndSettle(); // انتظار ظهور SnackBar
      expect(find.text('تمت الإضافة بنجاح'), findsOneWidget);
      await tester
          .pumpAndSettle(const Duration(seconds: 2)); // انتظار اختفاء SnackBar

      // القائمة لا تزال مفتوحة
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
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text(uniqueTasbihText), findsNothing);
      debugPrint('SUCCESS: Tasbih add/delete flow test completed.');

      await tester.pageBack();
      await tester.pumpAndSettle();
    });

    testWidgets('Daily Goal Flow: Set, Progress, Complete, and Remove',
        (WidgetTester tester) async {
      // التأكد من أننا في شاشة السبحة
      await tester.tap(find.byKey(const Key('bottom_nav_home')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
      await tester.pumpAndSettle();

      const tasbihTextToTrack = 'سبحان الله';

      final openListButton = find.byTooltip('اختيار الذكر');
      await tester.tap(openListButton);
      await tester.pumpAndSettle();

      final goalIconFinder = find.descendant(
        of: find.widgetWithText(ListTile, tasbihTextToTrack),
        matching: find.byIcon(Icons.flag_outlined),
      );
      await tester.tap(goalIconFinder);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '3');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('أهدافي اليومية'), findsOneWidget);
      expect(find.text('0 / 3'), findsOneWidget);

      final counterButton = find.byType(TasbihCounterButton);
      await tester.tap(counterButton);
      await tester.pump(); // Pump لإعادة بناء الواجهة
      await tester.tap(counterButton);
      await tester.pump();
      await tester.tap(counterButton);
      await tester.pumpAndSettle(); // Settle في النهاية

      expect(find.text('3 / 3'), findsOneWidget);
      final completedGoalRow =
          find.ancestor(of: find.text('3 / 3'), matching: find.byType(Row));
      expect(
          find.descendant(
              of: completedGoalRow, matching: find.byIcon(Icons.check_circle)),
          findsOneWidget);

      await tester.tap(openListButton);
      await tester.pumpAndSettle();

      final removeGoalIcon = find.descendant(
        of: find.widgetWithText(ListTile, tasbihTextToTrack),
        matching: find.byIcon(Icons.flag_rounded),
      );
      await tester.tap(removeGoalIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('إزالة الهدف'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('أهدافي اليومية'), findsNothing);
      debugPrint('SUCCESS: Daily goals flow test completed.');
    });
  });
}
