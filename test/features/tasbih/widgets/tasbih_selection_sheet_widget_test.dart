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

// ✨ [إصلاح نهائي] تعريف الـ Mock يجب أن يكون خارج الـ main وأن يطبق الواجهة الصحيحة.
class MockAzkarRepository extends Mock implements AzkarRepository {
  // يجب أن نعرف الدوال التي سنستخدمها ونحدد نوع الإرجاع بشكل صريح.
  @override
  Future<List<TasbihModel>> getCustomTasbihList() => (super.noSuchMethod(
      Invocation.method(#getCustomTasbihList, []),
      returnValue: Future.value(<TasbihModel>[])) as Future<List<TasbihModel>>);

  @override
  Future<Map<int, int>> getTodayTasbihCounts() =>
      (super.noSuchMethod(Invocation.method(#getTodayTasbihCounts, []),
          returnValue: Future.value(<int, int>{})) as Future<Map<int, int>>);
}

void main() {
  late MockAzkarRepository mockRepo;

  setUp(() {
    mockRepo = MockAzkarRepository();
  });

  final mockTasbihList = [
    TasbihModel(id: 1, text: 'سبحان الله', sortOrder: 1, isDeletable: false),
  ];

  testWidgets('tapping an item calls setActiveTasbih and closes sheet',
      (WidgetTester tester) async {
    when(mockRepo.getCustomTasbihList())
        .thenAnswer((_) async => mockTasbihList);
    when(mockRepo.getTodayTasbihCounts()).thenAnswer((_) async => {1: 10});

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
