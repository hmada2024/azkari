// test/widget_test.dart
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/features/favorites/favorites_provider.dart';
import 'package:azkari/features/home/home_screen.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_header.dart';
import 'package:azkari/presentation/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  Future<void> pumpAppShell(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesProvider
              .overrideWith((ref) => Future.value(['أذكار الصباح'])),
          tasbihListProvider.overrideWith((ref) => Future.value([
                TasbihModel(
                    id: 1, text: 'تسبيح وهمي', sortOrder: 1, isDeletable: false)
              ])),
          favoriteAdhkarProvider
              .overrideWith((ref) => Future.value(<AdhkarModel>[])),
        ],
        child: const MaterialApp(
          home: AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AppShell Widget Tests', () {
    testWidgets('Home screen is displayed by default',
        (WidgetTester tester) async {
      await pumpAppShell(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('أذكار الصباح'), findsOneWidget);
    });

    testWidgets('Tapping Tasbih tab navigates to TasbihScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpAppShell(tester);
      await tester.tap(find.byIcon(Icons.fingerprint));
      await tester.pumpAndSettle();

      expect(find.byType(TasbihHeader), findsOneWidget);
      expect(find.text('تسبيح وهمي'), findsOneWidget);
    });

    testWidgets('Tapping Favorites tab navigates to FavoritesScreen',
        (WidgetTester tester) async {
      await pumpAppShell(tester);

      await tester.tap(find.byIcon(Icons.star_border_outlined));
      await tester.pumpAndSettle();

      // ✅ تصحيح: البحث عن الأيقونة المميزة في شاشة المفضلة الفارغة
      expect(
          find.byIcon(Icons.star_border, skipOffstage: false), findsOneWidget);
      expect(find.text('لم تقم بإضافة أي ذكر إلى المفضلة بعد'), findsOneWidget);
    });
  });
}
