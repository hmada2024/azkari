// integration_test/full_app_test.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:azkari/data/services/database_helper.dart';
import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
import 'package:azkari/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    // تهيئة قاعدة البيانات لبيئة الاختبار (خاصة سطح المكتب)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // حذف قاعدة البيانات القديمة لضمان بداية نظيفة في كل مرة
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    const dbName = "azkar.db";
    String path = join(documentsDirectory.path, dbName);
    final dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      debugPrint("Deleted existing database at $path for a clean test run.");
    }

    // ✅✅✅ الحل النهائي: تنظيف شامل لذاكرة التفضيلات ✅✅✅
    // هذا يضمن أن حالة المفضلة والإعدادات تبدأ من الصفر تماماً
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("✅ Cleared SharedPreferences for a truly clean test run.");
  });

  tearDown(() async {
    // إغلاق اتصال قاعدة البيانات بعد كل اختبار لتجنب تداخل الحالات
    await DatabaseHelper.closeDatabaseForTest();
  });

  testWidgets('Full E2E App Flow: Favorites, Tasbih, and Goals',
      (WidgetTester tester) async {
    // الخطوة 0: تشغيل التطبيق والانتظار حتى يستقر
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('أذكاري'), findsOneWidget);
    debugPrint(
        '✅ SUCCESS: Step 0 - Application started and HomeScreen is visible.');

    // --- الخطوة 1: اختبار تدفق المفضلة ---
    debugPrint('▶️ STARTING: Step 1 - Favorites Flow Test...');
    await tester.tap(find.text('أذكار الصباح'));
    await tester.pumpAndSettle();
    // تحديد أول ذكر وإضافته للمفضلة
    final firstCardWidget =
        tester.widget<AdhkarCard>(find.byType(AdhkarCard).first);
    final adhkarId = firstCardWidget.adhkar.id;
    final cardKey = Key('adhkar_card_$adhkarId');
    final specificCardFinder = find.byKey(cardKey);
    // الآن يمكننا أن نكون واثقين 100% أن الأيقونة ستكون فارغة
    final starIconFinder = find.descendant(
      of: specificCardFinder,
      matching: find.byIcon(Icons.star_border),
    );
    await tester.tap(starIconFinder);
    await tester.pumpAndSettle();
    // العودة والتحقق من وجوده في شاشة المفضلة
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottom_nav_favorites')));
    await tester.pumpAndSettle();
    expect(specificCardFinder, findsOneWidget);
    debugPrint('✅ SUCCESS: Step 1 - Favorites flow test completed.');

    // --- الخطوة 2: اختبار إضافة وحذف ذكر في السبحة ---
    debugPrint('▶️ STARTING: Step 2 - Tasbih Add/Delete Flow Test...');
    await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
    await tester.pumpAndSettle();
    final openListButton = find.byTooltip('اختيار الذكر');

    // إضافة ذكر جديد
    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    final uniqueTasbihText =
        'ذكر اختباري ${DateTime.now().millisecondsSinceEpoch}';
    await tester.tap(find.byTooltip('إضافة ذكر جديد'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), uniqueTasbihText);
    await tester.tap(find.text('إضافة'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text(uniqueTasbihText, findRichText: true), findsOneWidget);

    // حذف الذكر المضاف
    final tileFinder = find.ancestor(
        of: find.text(uniqueTasbihText, findRichText: true),
        matching: find.byType(ListTile));
    final specificDeleteButton = find.descendant(
        of: tileFinder, matching: find.byIcon(Icons.delete_outline));
    await tester.ensureVisible(specificDeleteButton);
    await tester.pumpAndSettle();
    await tester.tap(specificDeleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text(uniqueTasbihText, findRichText: true), findsNothing);

    // أغلق القائمة
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    debugPrint('✅ SUCCESS: Step 2 - Tasbih add/delete flow test completed.');

    // --- الخطوة 3: اختبار تدفق الأهداف اليومية الكامل ---
    debugPrint('▶️ STARTING: Step 3 - Daily Goals Full Flow...');

    // 3.1 افتح قائمة اختيار الذكر مرة أخرى
    await tester.tap(openListButton);
    await tester.pumpAndSettle();

    // 3.2 حدد هدفاً لأول ذكر "سبحان الله"
    const tasbihTextToTrack = 'سبحان الله';
    final tasbihTileFinder = find.widgetWithText(ListTile, tasbihTextToTrack);

    // ابحث عن القائمة القابلة للتمرير داخل الـ BottomSheet
    final scrollableListFinder = find.descendant(
      of: find.byType(TasbihSelectionSheet),
      matching: find.byType(Scrollable),
    );
    // استمر في التمرير حتى يصبح العنصر مرئياً
    await tester.scrollUntilVisible(
      tasbihTileFinder,
      50.0,
      scrollable: scrollableListFinder,
    );

    // الآن نحن متأكدون أن العنصر مرئي، فلنتفاعل معه
    final goalIconFinder = find.descendant(
      of: tasbihTileFinder,
      matching: find.byIcon(Icons.flag_outlined),
    );
    await tester.tap(goalIconFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '3');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    debugPrint("✅ Goal set for '$tasbihTextToTrack' to 3.");

    // 3.3 أغلق النافذة وتأكد من ظهور قسم الأهداف
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('أهدافي اليومية'), findsOneWidget);
    expect(find.text('0 / 3'), findsOneWidget);
    debugPrint("✅ Daily goals section is visible with correct initial count.");

    // 3.4 قم بالتسبيح لإكمال الهدف
    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    await tester.tap(tasbihTileFinder);
    await tester.pumpAndSettle();

    final counterButton = find.byType(TasbihCounterButton);
    for (int i = 0; i < 3; i++) {
      await tester.tap(counterButton);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    final completedGoalContainer = find.ancestor(
        of: find.text('سبحان الله'), matching: find.byType(Column));
    expect(
        find.descendant(
            of: completedGoalContainer,
            matching: find.byIcon(Icons.check_circle)),
        findsOneWidget);
    debugPrint(
        "✅ Goal progress updated correctly to 3/3 and checkmark is visible.");

    // 3.5 أزل الهدف
    await tester.tap(openListButton);
    await tester.pumpAndSettle();

    // مرر للعنصر مرة أخرى لضمان العثور عليه
    await tester.scrollUntilVisible(
      tasbihTileFinder,
      50.0,
      scrollable: scrollableListFinder,
    );

    final removeGoalIcon = find.descendant(
      of: tasbihTileFinder,
      matching: find.byIcon(Icons.flag_rounded),
    );
    await tester.tap(removeGoalIcon);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إزالة الهدف'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('أهدافي اليومية'), findsNothing);
    debugPrint(
        "✅ SUCCESS: Step 3 - Daily goal removed and section disappeared.");

    debugPrint("🏆🏆🏆 VICTORY: All E2E tests passed successfully! 🏆🏆🏆");
  });
}
