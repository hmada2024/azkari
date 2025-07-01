// test/features/tasbih/widgets/tasbih_selection_sheet_widget_test.dart

import 'dart:async';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../tasbih/providers/tasbih_provider_test.mocks.dart';
import '../providers/tasbih_provider_test.mocks.dart';

void main() {
  final mockItems = [
    TasbihListItem(
      tasbih: TasbihModel(
          id: 1, text: 'سبحان الله', sortOrder: 1, isDeletable: false),
      count: 10,
    ),
    TasbihListItem(
      tasbih: TasbihModel(
          id: 2, text: 'الحمد لله', sortOrder: 2, isDeletable: false),
      count: 20,
    ),
  ];

  Widget createTestApp(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const TasbihSelectionSheet(),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('TasbihSelectionSheet Widget Tests', () {
    testWidgets('displays list of tasbihs when data is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp([
        tasbihListWithCountsProvider
            .overrideWith((ref) => Future.value(mockItems)),
      ]));

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('قائمة الذكر'), findsOneWidget);
      expect(find.text('سبحان الله'), findsOneWidget);
    });

    testWidgets('tapping an item calls setActiveTasbih and closes the sheet',
        (WidgetTester tester) async {
      final mockRepo = MockAzkarRepository();
      when(mockRepo.getCustomTasbihList())
          .thenAnswer((_) async => mockItems.map((e) => e.tasbih).toList());
      when(mockRepo.getTodayTasbihCounts())
          .thenAnswer((_) async => {1: 10, 2: 20});
      when(mockRepo.getTodayGoalsWithProgress()).thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        azkarRepositoryProvider.overrideWith((ref) => Future.value(mockRepo)),
      ]);
      addTearDown(container.dispose);

      await container.read(tasbihStateProvider.notifier).initializationComplete;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => const TasbihSelectionSheet(),
                      );
                    },
                    child: const Text('Open Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
      expect(find.text('قائمة الذكر'), findsOneWidget);

      await tester.tap(find.text('الحمد لله'));
      await tester.pumpAndSettle();

      expect(find.text('قائمة الذكر'), findsNothing);

      final state = container.read(tasbihStateProvider);
      expect(state.activeTasbihId, 2);
    });
  });
}
