// test/features/tasbih/tasbih_provider_test.dart
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_goals_provider_test.mocks.dart';

class FakeDailyGoalsNotifier extends StateNotifier<AsyncValue<void>>
    implements DailyGoalsNotifier {
  FakeDailyGoalsNotifier() : super(const AsyncData(null));
  int incrementCalls = 0;
  int? lastCalledWithId;

  @override
  Future<void> incrementProgressForTasbih(int tasbihId) async {
    incrementCalls++;
    lastCalledWithId = tasbihId;
  }

  @override
  Future<void> setOrUpdateGoal(int tasbihId, int targetCount) async {}
  @override
  Future<void> removeGoal(int tasbihId) async {}
  @override
  Future<void> noSuchMethod(Invocation invocation) async {}
}

void main() {
  late MockAdhkarRepository mockRepository;
  late FakeDailyGoalsNotifier fakeDailyGoalsNotifier;

  ProviderContainer createContainer() {
    final container = ProviderContainer(overrides: [
      // ✨ [تعديل] استخدام overrideWith لتوفير Future مكتمل
      adhkarRepositoryProvider.overrideWith(
        (ref) => Future.value(mockRepository),
      ),
      dailyGoalsNotifierProvider.overrideWith((ref) => fakeDailyGoalsNotifier),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockAdhkarRepository();
    fakeDailyGoalsNotifier = FakeDailyGoalsNotifier();

    when(mockRepository.getGoalsWithTodayProgress())
        .thenAnswer((_) async => []);
    when(mockRepository.getGoalForTasbih(any)).thenAnswer((_) async => null);
  });

  group('TasbihStateNotifier Tests', () {
    test('Initial state count should be 0 after loading', () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);
      // انتظر اكتمال التهيئة
      await container.read(adhkarRepositoryProvider.future);
      await Future.delayed(Duration.zero);

      expect(notifier.mounted, true);
      expect(container.read(tasbihStateProvider).count, 0);
    });

    test('increment() should increase count by 1 and call goals notifier',
        () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);
      await container.read(adhkarRepositoryProvider.future);
      await Future.delayed(Duration.zero);
      await notifier.setActiveTasbih(123);

      expect(fakeDailyGoalsNotifier.incrementCalls, 0);
      await notifier.increment();

      expect(container.read(tasbihStateProvider).count, 1);
      expect(fakeDailyGoalsNotifier.incrementCalls, 1);
      expect(fakeDailyGoalsNotifier.lastCalledWithId, 123);
    });
  });
}
