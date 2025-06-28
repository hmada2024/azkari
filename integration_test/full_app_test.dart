// integration_test/full_app_test.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
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

  testWidgets('Full E2E App Flow: Favorites, Tasbih, and Daily Goals',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: app.MyApp(),
    ));

    await tester.pumpAndSettle(const Duration(seconds: 10));
    expect(find.text('أذكاري'), findsOneWidget);
    debugPrint(
        '✅ SUCCESS: Step 0 - Application started and HomeScreen is visible.');

    debugPrint('▶️ STARTING: Step 1 - Favorites Flow Test...');
    await tester.tap(find.text('أذكار الصباح'));
    await tester.pumpAndSettle();

    final firstCardFinder = find.byType(AdhkarCard).first;
    final textFinder = find.descendant(
      of: firstCardFinder,
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && widget.style?.fontFamily == 'Amiri',
      ),
    );
    final targetAdhkarText = tester.widget<Text>(textFinder).data!;
    final starIconFinder = find.descendant(
      of: firstCardFinder,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            (widget.icon == Icons.star || widget.icon == Icons.star_border),
      ),
    );
    final isAlreadyFavorite =
        tester.widget<Icon>(starIconFinder).icon == Icons.star;
    if (isAlreadyFavorite) {
      await tester.tap(starIconFinder);
      await tester.pumpAndSettle();
    }
    final starBorderIconFinder = find.descendant(
        of: firstCardFinder, matching: find.byIcon(Icons.star_border));
    await tester.tap(starBorderIconFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottom_nav_favorites')));
    await tester.pumpAndSettle();
    expect(find.text(targetAdhkarText), findsOneWidget);
    debugPrint('✅ SUCCESS: Step 1 - Favorites flow test completed.');

    debugPrint('▶️ STARTING: Step 2 - Tasbih Add/Delete Flow Test...');
    await tester.tap(find.byKey(const Key('bottom_nav_home')));
    await tester.pumpAndSettle();
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

    expect(find.byType(TasbihSelectionSheet), findsNothing);

    await tester.tap(openListButton);
    await tester.pumpAndSettle();

    final uniqueTextFinder = find.text(uniqueTasbihText);
    await tester.pumpUntilFound(uniqueTextFinder);

    final tileFinder =
        find.ancestor(of: uniqueTextFinder, matching: find.byType(ListTile));
    await tester.ensureVisible(tileFinder);
    await tester.pumpAndSettle();

    final deleteButtonFinder = find.descendant(
      of: tileFinder,
      matching: find.byIcon(Icons.delete_outline),
    );
    expect(deleteButtonFinder, findsOneWidget);

    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    await tester.pumpUntilNotFound(find.text('تأكيد الحذف'));
    expect(find.text(uniqueTasbihText), findsNothing);

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
    await tester.tap(goalIconFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '3');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    await tester.pageBack();
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
      await tester.pump();
    }
    await tester.pumpAndSettle();
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
    debugPrint('✅ SUCCESS: Step 3 - Daily goals flow test completed.');
  });
}

extension on WidgetTester {
  Future<void> pumpUntilFound(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    bool found = false;
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump();
      if (finder.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }
    expect(found, isTrue,
        reason: 'Failed to find ${finder.describeMatch(Plurality.one)}');
  }

  Future<void> pumpUntilNotFound(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    bool notFound = false;
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump();
      if (finder.evaluate().isEmpty) {
        notFound = true;
        break;
      }
    }
    expect(notFound, isTrue,
        reason:
            'Widget was still found after timeout: ${finder.describeMatch(Plurality.one)}');
  }
}
