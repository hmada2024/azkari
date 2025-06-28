// integration_test/app_test.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/data/services/database_helper.dart';
import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/main.dart' as app;
import 'package:flutter/foundation.dart';
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

  tearDown(() async {
    await DatabaseHelper.closeDatabaseForTest();
  });

  testWidgets('Full E2E App Flow: Favorites, Tasbih, and Daily Goals',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const app.MyApp(),
    ));

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

    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    final uniqueTasbihText =
        'ذكر اختباري ${DateTime.now().millisecondsSinceEpoch}';
    await tester.tap(find.byTooltip('إضافة ذكر جديد'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), uniqueTasbihText);
    await tester.tap(find.text('إضافة'));

    await tester.pumpAndSettle();
    debugPrint("✅ Add successful dialog closed.");

    // ✅✅✅ هذا هو الحل الحاسم والنهائي ✅✅✅
    // 1. أجبِر الـ Provider على التحديث
    container.invalidate(tasbihListProvider);
    // 2. أجبِر الواجهة على إعادة البناء وانتظر حتى تستقر
    await tester.pumpAndSettle();
    // 3. الآن اقرأ البيانات من الـ Provider بعد أن تم تحديث الواجهة
    final List<TasbihModel> tasbihList =
        await container.read(tasbihListProvider.future);

    final newTasbih = tasbihList.firstWhere((t) => t.text == uniqueTasbihText,
        orElse: () => throw StateError('New Tasbih not found in provider'));
    final deleteButtonFinder = find.byKey(Key('delete_tasbih_${newTasbih.id}'));

    expect(deleteButtonFinder, findsOneWidget,
        reason:
            'Delete button should be present in the UI after pumpAndSettle');

    await tester.ensureVisible(deleteButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));

    // نفس المنطق عند الحذف: أبلغ الـ provider وأعد بناء الواجهة
    container.invalidate(tasbihListProvider);
    await tester.pumpAndSettle();

    expect(find.text(uniqueTasbihText, findRichText: true), findsNothing);
    debugPrint("✅ Delete successful. Item is no longer visible in the sheet.");

    await tester.pageBack();
    await tester.pumpAndSettle();
    debugPrint('✅ SUCCESS: Step 2 - Tasbih add/delete flow test completed.');

    debugPrint('▶️ STARTING: Step 3 - Daily Goals Flow Test...');
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

    await tester.pageBack();
    await tester.pumpAndSettle();

    await DatabaseHelper.closeDatabaseForTest();
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

    await DatabaseHelper.closeDatabaseForTest();
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

    await tester.pageBack();
    await tester.pumpAndSettle();

    await DatabaseHelper.closeDatabaseForTest();
    container.invalidate(dailyGoalsProvider);
    await tester.pumpAndSettle();
    expect(find.text('أهدافي اليومية'), findsNothing);
    debugPrint('✅ SUCCESS: Step 3 - Daily goals flow test completed.');
  });
}
