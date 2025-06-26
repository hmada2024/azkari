// test/features/favorites/favorites_screen_test.dart

import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:azkari/features/favorites/favorites_provider.dart';
import 'package:azkari/features/favorites/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FavoritesScreen Widget Tests', () {
    testWidgets('displays empty message when there are no favorites',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          // استراتيجية 1.2: تزييف بيانات الـ provider
          // نحن نوفر قائمة فارغة مباشرة
          overrides: [
            favoriteAdhkarProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );

      // انتظر اكتمال الـ FutureProvider
      await tester.pumpAndSettle();

      expect(find.text('المفضلة'), findsOneWidget);
      expect(find.text('لم تقم بإضافة أي ذكر إلى المفضلة بعد'), findsOneWidget);
      // ✨✨✨ هذا هو السطر المصحح ✨✨✨
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(AdhkarCard), findsNothing);
    });

    testWidgets('displays list of AdhkarCards when there are favorites',
        (WidgetTester tester) async {
      // إعداد بيانات وهمية
      final mockAdhkar = [
        AdhkarModel(id: 1, category: 'test', text: 'ذكر مفضل 1', count: 1),
        AdhkarModel(id: 2, category: 'test', text: 'ذكر مفضل 2', count: 3),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // استراتيجية 1.2: تزييف بيانات الـ provider
            // نحن نوفر قائمة وهمية من الأذكار
            favoriteAdhkarProvider
                .overrideWith((ref) => Future.value(mockAdhkar)),
          ],
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AdhkarCard), findsNWidgets(2));
      expect(find.text('ذكر مفضل 1'), findsOneWidget);
      expect(find.text('ذكر مفضل 2'), findsOneWidget);
      expect(find.text('لم تقم بإضافة أي ذكر إلى المفضلة بعد'), findsNothing);
    });
  });
}
