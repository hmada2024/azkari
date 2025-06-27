// test/features/tasbih/widgets/tasbih_header_test.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_header.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockTasbihStateNotifier extends StateNotifier<TasbihState>
    implements TasbihStateNotifier {
  MockTasbihStateNotifier() : super(TasbihState());

  int resetCountCalls = 0;

  @override
  Future<void> resetCount() async {
    resetCountCalls++;
  }

  @override
  Future<void> noSuchMethod(Invocation invocation) async {}
}

void main() {
  late MockTasbihStateNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockTasbihStateNotifier();
  });

  Future<void> pumpTasbihHeader(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasbihStateProvider.overrideWith((ref) => mockNotifier),
          // ✨ [الإصلاح] تزييف الاعتماديات التي يحتاجها BottomSheet
          tasbihListProvider
              .overrideWith((ref) => Future.value(<TasbihModel>[])),
          dailyGoalsProvider
              .overrideWith((ref) => Future.value(<DailyGoalModel>[])),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TasbihHeader(),
          ),
        ),
      ),
    );
  }

  group('TasbihHeader Interaction Tests', () {
    testWidgets('Tapping refresh icon calls resetCount() on the notifier',
        (WidgetTester tester) async {
      await pumpTasbihHeader(tester);

      expect(mockNotifier.resetCountCalls, 0);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(mockNotifier.resetCountCalls, 1);
    });

    testWidgets('Tapping list icon shows TasbihSelectionSheet',
        (WidgetTester tester) async {
      await pumpTasbihHeader(tester);

      expect(find.byType(TasbihSelectionSheet), findsNothing);
      await tester.tap(find.byIcon(Icons.list_alt_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TasbihSelectionSheet), findsOneWidget);
    });
  });
}
