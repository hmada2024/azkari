// integration_test/app_test.dart
import 'dart:io';

import 'package:azkari/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  group('App End-to-End Tests', () {
    testWidgets('Full flow: favorite an adhkar and verify in favorites screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('أذكاري'), findsOneWidget);
      expect(find.text('أذكار الصباح'), findsOneWidget);

      await tester.tap(find.text('أذكار الصباح'));
      await tester.pumpAndSettle();

      late final String targetAdhkarText;

      final unfavoritedFinder = find.byIcon(Icons.star_border);
      await tester.pumpAndSettle();

      if (unfavoritedFinder.evaluate().isEmpty) {
        debugPrint(
            "All items are already favorited. Picking the first one to verify.");
        final firstFavorited = find.byIcon(Icons.star).first;
        await tester.ensureVisible(firstFavorited);
        await tester.pumpAndSettle();

        final card =
            find.ancestor(of: firstFavorited, matching: find.byType(Card));
        final textFinder =
            find.descendant(of: card, matching: find.byType(Text)).first;
        targetAdhkarText = tester.widget<Text>(textFinder).data!;
      } else {
        debugPrint("Found an unfavorited item. Favoriting it now.");
        final firstUnfavorited = unfavoritedFinder.first;
        await tester.ensureVisible(firstUnfavorited);
        await tester.pumpAndSettle();

        final card =
            find.ancestor(of: firstUnfavorited, matching: find.byType(Card));
        final textFinder =
            find.descendant(of: card, matching: find.byType(Text)).first;
        targetAdhkarText = tester.widget<Text>(textFinder).data!;

        await tester.tap(firstUnfavorited);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bottom_nav_favorites')));
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byType(AppBar), matching: find.text('المفضلة')),
          findsOneWidget);

      expect(find.text(targetAdhkarText), findsOneWidget);
      debugPrint('SUCCESS: Found "$targetAdhkarText" in favorites screen.');
    });
  });
}
