// test/features/adhkar_list/widgets/adhkar_card_test.dart
import 'package:azkari/core/models/settings_model.dart';
import 'package:azkari/core/providers/settings_provider.dart';
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:azkari/features/favorites/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Fakes
class FakeFavoritesNotifier extends StateNotifier<List<int>>
    implements FavoritesIdNotifier {
  FakeFavoritesNotifier(super.initialState);
  @override
  Future<void> toggleFavorite(int adhkarId) async {
    if (state.contains(adhkarId)) {
      state = List.from(state)..remove(adhkarId);
    } else {
      state = List.from(state)..insert(0, adhkarId);
    }
  }

  @override
  Future<void> get initializationComplete => Future.value();
}

class FakeSettingsNotifier extends StateNotifier<SettingsModel>
    implements SettingsNotifier {
  FakeSettingsNotifier(super.initialState);
  @override
  Future<void> updateTheme(ThemeMode newTheme) async {}
  @override
  Future<void> updateFontScale(double newScale) async {}
  @override
  Future<void> get initializationComplete => Future.value();
}

void main() {
  final mockAdhkar =
      AdhkarModel(id: 1, category: 'test', text: 'سبحان الله', count: 3);

  Future<void> pumpAdhkarCard(WidgetTester tester, AdhkarModel adhkar,
      {List<int> initialFavorites = const []}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
              (ref) => FakeSettingsNotifier(SettingsModel(fontScale: 1.0))),
          favoritesIdProvider
              .overrideWith((ref) => FakeFavoritesNotifier(initialFavorites)),
        ],
        child: MaterialApp(home: Scaffold(body: AdhkarCard(adhkar: adhkar))),
      ),
    );
  }

  group('AdhkarCard Widget Interaction Tests', () {
    // ✅ الحل النهائي: ابحث عن الـ GestureDetector الذي هو ancestor (سلف) للرقم أو الأيقونة
    testWidgets('Counter decreases on tap', (WidgetTester tester) async {
      await pumpAdhkarCard(tester, mockAdhkar);
      expect(find.text('3'), findsOneWidget);

      final counterButton = find.ancestor(
        of: find.text('3'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(counterButton);
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Replay icon appears when counter reaches zero',
        (WidgetTester tester) async {
      final singleCountAdhkar =
          AdhkarModel(id: 1, category: 't', text: 't', count: 1);
      await pumpAdhkarCard(tester, singleCountAdhkar);

      final counterButton = find.ancestor(
          of: find.text('1'), matching: find.byType(GestureDetector));
      await tester.tap(counterButton);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('Counter resets when replay icon is tapped',
        (WidgetTester tester) async {
      await pumpAdhkarCard(tester, mockAdhkar);

      // نضغط 3 مرات
      for (var i = 3; i > 0; i--) {
        final button = find.ancestor(
            of: find.text('$i'), matching: find.byType(GestureDetector));
        await tester.tap(button);
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.replay), findsOneWidget);

      final replayButton = find.ancestor(
          of: find.byIcon(Icons.replay),
          matching: find.byType(GestureDetector));
      await tester.tap(replayButton);
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Tapping star toggles favorite state',
        (WidgetTester tester) async {
      await pumpAdhkarCard(tester, mockAdhkar, initialFavorites: []);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      await tester.tap(find.byIcon(Icons.star_border));
      await tester.pump();
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
