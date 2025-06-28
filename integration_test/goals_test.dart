// integration_test/goals_test.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:azkari/data/services/database_helper.dart';
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

  testWidgets('Daily Goals Full Flow', (WidgetTester tester) async {
    final container = ProviderContainer();
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const app.MyApp(),
    ));

    await tester.pumpAndSettle(const Duration(seconds: 10));

    // 1. اذهب إلى شاشة السبحة
    await tester.tap(find.byKey(const Key('bottom_nav_tasbih')));
    await tester.pumpAndSettle();
    debugPrint("✅ Navigated to Tasbih Screen.");

    // 2. افتح قائمة اختيار الذكر
    final openListButton = find.byTooltip('اختيار الذكر');
    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    debugPrint("✅ Opened Tasbih Selection Sheet.");

    // 3. حدد هدفاً
    const tasbihTextToTrack = 'سبحان الله';
    final tasbihTileFinder = find.widgetWithText(ListTile, tasbihTextToTrack);

    // ✅✅✅ الحل الحاسم: انتظر بصبر حتى يظهر العنصر ✅✅✅
    await tester.pumpUntilFound(tasbihTileFinder);
    await tester.pumpAndSettle();

    final goalIconFinder = find.descendant(
      of: tasbihTileFinder,
      matching: find.byIcon(Icons.flag_outlined),
    );

    // اضمن أن الأيقونة نفسها مرئية قبل النقر
    await tester.ensureVisible(goalIconFinder);
    await tester.pumpAndSettle();
    await tester.tap(goalIconFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '3');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    debugPrint("✅ Goal set for '$tasbihTextToTrack' to 3.");

    // 4. أغلق النافذة وتأكد من ظهور قسم الأهداف
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    container.invalidate(dailyGoalsProvider);
    await tester.pumpAndSettle();

    expect(find.text('أهدافي اليومية'), findsOneWidget);
    expect(find.text('0 / 3'), findsOneWidget);
    debugPrint("✅ Daily goals section is visible with correct initial count.");

    // 5. قم بالتسبيح لإكمال الهدف
    await tester.tap(openListButton);
    await tester.pumpAndSettle();
    await tester.pumpUntilFound(tasbihTileFinder); // انتظر ظهوره مرة أخرى
    await tester.tap(tasbihTileFinder);
    await tester.pumpAndSettle();

    final counterButton = find.byType(TasbihCounterButton);
    for (int i = 0; i < 3; i++) {
      await tester.tap(counterButton);
      await tester.pump(const Duration(milliseconds: 50));
    }

    container.invalidate(dailyGoalsProvider);
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    debugPrint("✅ Goal progress updated correctly to 3/3.");

    // 6. أزل الهدف
    await tester.tap(openListButton);
    await tester.pumpAndSettle();

    await tester.pumpUntilFound(tasbihTileFinder); // انتظر ظهوره للمرة الأخيرة
    await tester.ensureVisible(tasbihTileFinder);
    await tester.pumpAndSettle();

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

    container.invalidate(dailyGoalsProvider);
    await tester.pumpAndSettle();
    expect(find.text('أهدافي اليومية'), findsNothing);
    debugPrint("✅ SUCCESS: Daily goal removed and section disappeared.");
  });
}

// ✅✅✅ الدالة المساعدة القوية التي تضمن النصر ✅✅✅
extension on WidgetTester {
  Future<void> pumpUntilFound(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    bool found = false;
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }
    expect(found, isTrue,
        reason:
            'Failed to find ${finder.describeMatch(Plurality.one)} within timeout');
  }
}
