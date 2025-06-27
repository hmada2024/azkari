// test/features/tasbih/tasbih_provider_test.dart
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_goals_provider_test.mocks.dart';

// ✨ [الحل] 1. إنشاء نسخة "مزيفة" (Fake) من DailyGoalsNotifier
// هذه النسخة ستقوم بتسجيل ما إذا تم استدعاء دوالها أم لا
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

  // الدوال الأخرى غير ضرورية للاختبار الحالي
  @override
  Future<void> setOrUpdateGoal(int tasbihId, int targetCount) async {}
  @override
  Future<void> removeGoal(int tasbihId) async {}
  @override
  Future<void> noSuchMethod(Invocation invocation) async {}
}

void main() {
  late MockAdhkarRepository mockRepository;
  // ✨ [الحل] 2. إنشاء نسخة من الـ Notifier المزيف
  late FakeDailyGoalsNotifier fakeDailyGoalsNotifier;

  ProviderContainer createContainer() {
    final container = ProviderContainer(overrides: [
      adhkarRepositoryProvider.overrideWithValue(mockRepository),
      // ✨ [الحل] 3. استبدال الـ Provider الحقيقي بالـ Notifier المزيف
      dailyGoalsNotifierProvider.overrideWith((ref) => fakeDailyGoalsNotifier),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockAdhkarRepository();
    // إعادة تهيئة الـ Notifier المزيف قبل كل اختبار
    fakeDailyGoalsNotifier = FakeDailyGoalsNotifier();

    when(mockRepository.getGoalsWithTodayProgress())
        .thenAnswer((_) async => []);
    when(mockRepository.getGoalForTasbih(any)).thenAnswer((_) async => null);
  });

  group('TasbihStateNotifier Tests', () {
    test('Initial state count should be 0 after loading', () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);
      await Future.delayed(Duration.zero);
      expect(notifier.mounted, true);
      expect(container.read(tasbihStateProvider).count, 0);
    });

    test('increment() should increase count by 1 and call goals notifier',
        () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);

      await Future.delayed(Duration.zero);
      await notifier.setActiveTasbih(123);

      // التحقق قبل الاستدعاء
      expect(fakeDailyGoalsNotifier.incrementCalls, 0);

      await notifier.increment();

      expect(container.read(tasbihStateProvider).count, 1);
      // ✨ [الحل] 4. التحقق من الـ Notifier المزيف مباشرة بدلاً من استخدام spy و verify
      expect(fakeDailyGoalsNotifier.incrementCalls, 1);
      expect(fakeDailyGoalsNotifier.lastCalledWithId, 123);
    });

    test('resetCount() should reset count to 0', () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);
      await Future.delayed(Duration.zero);

      await notifier.increment();
      await notifier.increment();
      expect(container.read(tasbihStateProvider).count, 2);

      await notifier.resetCount();
      expect(container.read(tasbihStateProvider).count, 0);
    });

    test('setActiveTasbih() should set new active ID and reset count',
        () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);
      await Future.delayed(Duration.zero);

      await notifier.increment();
      await notifier.setActiveTasbih(123);

      final state = container.read(tasbihStateProvider);
      expect(state.activeTasbihId, 123);
      expect(state.count, 0);
    });
  });
}
