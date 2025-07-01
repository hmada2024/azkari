// test/features/tasbih/widgets/tasbih_selection_sheet_widget_test.dart

import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/data/repositories/azkar_repository.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAzkarRepository extends Mock implements AzkarRepository {}

void main() {
  late MockAzkarRepository mockRepo;

  setUp(() {
    mockRepo = MockAzkarRepository();
  });

  final mockItems = [
    TasbihListItem(
        tasbih: TasbihModel(
            id: 1, text: 'سبحان الله', sortOrder: 1, isDeletable: false),
        count: 10),
  ];

  testWidgets('tapping an item calls setActiveTasbih and closes sheet',
      (WidgetTester tester) async {
    // ✨ [إصلاح] تم إضافة الـ mock الناقص
    when(mockRepo.getCustomTasbihList())
        .thenAnswer((_) async => mockItems.map((e) => e.tasbih).toList());
    when(mockRepo.getTodayTasbihCounts()).thenAnswer((_) async => {1: 10});
    when(mockRepo.getTodayGoalsWithProgress())
        .thenAnswer((_) async => []); // هذا كان ناقصًا

    final container = ProviderContainer(
      overrides: [
        azkarRepositoryProvider.overrideWith((ref) => Future.value(mockRepo)),
      ],
    );
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
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (_) => const TasbihSelectionSheet(),
                        ),
                        child: const Text('Open Sheet'),
                      ),
                    ),
                  )),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('سبحان الله'), findsOneWidget);

    await tester.tap(find.text('سبحان الله'));
    await tester.pumpAndSettle();

    expect(find.text('سبحان الله'), findsNothing);

    final state = container.read(tasbihStateProvider);
    expect(state.activeTasbihId, 1);
  });
}
