// test/features/azkar_list/widgets/azkar_card_widget_test.dart

import 'package:azkari/data/models/azkar_model.dart';
import 'package:azkari/features/azkar_list/widgets/azkar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// A helper function to wrap our widget with necessary providers for testing.
Widget createWidgetUnderTest(AzkarModel adhkar) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: AzkarCard(adhkar: adhkar),
      ),
    ),
  );
}

void main() {
  // ✨ [الإصلاح] تم تعديل نص الفضيلة ليكون فريدًا ومختلفًا عن عنوان ExpansionTile.
  final sampleAdhkar = AzkarModel(
    id: 1,
    category: 'Test',
    text: 'سبحان الله',
    count: 3,
    virtue: 'هذا هو نص الفضيلة المحدد.', // نص فريد
  );

  group('AzkarCard Widget Tests', () {
    testWidgets('displays initial text and count, and virtue is hidden',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(sampleAdhkar));

      // Act & Assert
      expect(find.text(sampleAdhkar.text), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // العنوان "فضل الذكر" يجب أن يكون موجودًا دائمًا.
      expect(find.text('فضل الذكر'), findsOneWidget);

      // لكن النص الفعلي للفضيلة يجب أن يكون مخفيًا.
      expect(find.text(sampleAdhkar.virtue!), findsNothing);

      // الآن قم بفتح الـ ExpansionTile
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle(); // انتظر اكتمال التحريك.

      // تحقق من أن نص الفضيلة أصبح ظاهرًا الآن.
      expect(find.text(sampleAdhkar.virtue!), findsOneWidget);
    });

    testWidgets('tapping the counter decrements the count',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(sampleAdhkar));
      expect(find.text('3'), findsOneWidget);

      // Act: Tap the counter button
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();

      // Assert: The count has decremented.
      expect(find.text('3'), findsNothing);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('when count reaches zero, shows replay icon',
        (WidgetTester tester) async {
      // Arrange
      final singleCountAdhkar =
          AzkarModel(id: 2, category: 'Test', text: 'الله أكبر', count: 1);
      await tester.pumpWidget(createWidgetUnderTest(singleCountAdhkar));

      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsNothing);

      // Act: Tap once to make the count zero.
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();

      // Assert: The count is gone, and the replay icon is visible.
      expect(find.text('1'), findsNothing);
      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('tapping a finished card resets its count',
        (WidgetTester tester) async {
      // Arrange
      final singleCountAdhkar =
          AzkarModel(id: 2, category: 'Test', text: 'الله أكبر', count: 1);
      await tester.pumpWidget(createWidgetUnderTest(singleCountAdhkar));

      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.replay), findsOneWidget);

      // Act: Tap the finished card again.
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();

      // Assert: The replay icon is gone, and the count is back to its initial value.
      expect(find.byIcon(Icons.replay), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
