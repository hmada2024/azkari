// integration_test/app_test.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:azkari/data/services/database_helper.dart';
import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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

  tearDown(() async {
    await DatabaseHelper.closeDatabaseForTest();
  });

  testWidgets('Full E2E App Flow: Favorites, Tasbih, and Daily Goals',
      (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 10));
    expect(find.text('أذكاري'), findsOneWidget);
    debugPrint(
        '✅ SUCCESS: Step 0 - Application started and HomeScreen is visible.');

    debugPrint('▶️ STARTING: Step 1 - Favorites Flow Test...');
    await tester.tap(find.text('أذكار الصباح'));
    await tester.pumpAndSettle();
    final firstCardWidget =
        tester.widget<AdhkarCard>(find.byType(AdhkarCard).first);
    final adhkarId = firstCardWidget.adhkar.id;
    final cardKey = Key('adhkar_card_$adhkarId');
    final specificCardFinder = find.byKey(cardKey);
    final starIconFinder = find.descendant(
      of: specificCardFinder,
      matching: find.byWidgetPredicate((widget) =>
          widget is Icon &&
          (widget.icon == Icons.star || widget.icon == Icons.star_border)),
    );
    final isAlreadyFavorite =
        tester.widget<Icon>(starIconFinder).icon == Icons.star;
    if (isAlreadyFavorite) {
      await tester.tap(starIconFinder);
      await tester.pumpAndSettle();
    }
    final starBorderIconFinder = find.descendant(
        of: specificCardFinder, matching: find.byIcon(Icons.star_border));
    await tester.tap(starBorderIconFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottom_nav_favorites')));
    await tester.pumpAndSettle();
    expect(specificCardFinder, findsOneWidget);
    debugPrint('✅ SUCCESS: Step 1 - Favorites flow test completed.');

    debugPrint('▶️ STARTING: Step 2 - Tasbih Add/Delete Flow Test...');
    await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
    await tester.pumpAndSettle();
    final openListButton = find.byTooltip('اختيار الذكر');

    // --- ADD FLOW ---
    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    final uniqueTasbihText =
        'ذكر اختباري ${DateTime.now().millisecondsSinceEpoch}';
    await tester.tap(find.byTooltip('إضافة ذكر جديد'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), uniqueTasbihText);
    await tester.tap(find.text('إضافة'));

    // الانتظار: دع التطبيق يقوم بكل شيء بنفسه.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    debugPrint("✅ Add action complete. UI has settled.");

    // التحقق
    expect(find.text(uniqueTasbihText, findRichText: true), findsOneWidget);
    debugPrint("✅ New tasbih text found in the UI.");

    // --- DELETE FLOW ---
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

    await tester.pumpAndSettle(const Duration(seconds: 2));
    debugPrint("✅ Delete action complete. UI has settled.");

    // التحقق
    expect(find.text(uniqueTasbihText, findRichText: true), findsNothing);
    debugPrint("✅ New tasbih text is no longer in the UI.");

    // ✅✅✅ الحل النهائي لمشكلة pageBack ✅✅✅
    // محاكاة نقر المستخدم خارج النافذة لإغلاقها
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    debugPrint('✅ SUCCESS: Step 2 - Tasbih add/delete flow test completed.');

    // --- GOALS FLOW ---
    debugPrint('▶️ STARTING: Step 3 - Daily Goals Flow Test...');
    final container =
        ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
    const tasbihTextToTrack = 'سبحان الله';

    await tester.tap(openListButton);
    await tester.pumpAndSettle();

    final goalIconFinder = find.descendant(
      of: find.widgetWithText(ListTile, tasbihTextToTrack),
      matching: find.byIcon(Icons.flag_outlined),
    );
    await tester.ensureVisible(goalIconFinder);
    await tester.pumpAndSettle();
    await tester.tap(goalIconFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '3');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    container.invalidate(dailyGoalsProvider);
    await tester.pumpAndSettle();

    expect(find.text('أهدافي اليومية'), findsOneWidget);
    expect(find.text('0 / 3'), findsOneWidget);

    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text(tasbihTextToTrack));
    await tester.pumpAndSettle();

    final counterButton = find.byType(TasbihCounterButton);
    for (int i = 0; i < 3; i++) {
      await tester.tap(counterButton);
      await tester.pump(const Duration(milliseconds: 50));
    }

    container.invalidate(dailyGoalsProvider);
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);

    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    final removeGoalIcon = find.descendant(
      of: find.widgetWithText(ListTile, tasbihTextToTrack),
      matching: find.byIcon(Icons.flag_rounded),
    );
    await tester.ensureVisible(removeGoalIcon);
    await tester.pumpAndSettle();
    await tester.tap(removeGoalIcon);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إزالة الهدف'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    container.invalidate(dailyGoalsProvider);
    await tester.pumpAndSettle();
    expect(find.text('أهدافي اليومية'), findsNothing);
    debugPrint('✅ SUCCESS: Step 3 - Daily goals flow test completed.');
  });
}
