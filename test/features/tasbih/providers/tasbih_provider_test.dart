// test/features/tasbih/providers/tasbih_provider_test.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/data/repositories/azkar_repository.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tasbih_provider_test.mocks.dart';

// Generate a mock for AzkarRepository.
@GenerateMocks([AzkarRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAzkarRepository mockAzkarRepository;

  // Dummy tasbih list for testing.
  final List<TasbihModel> dummyTasbihList = [
    TasbihModel(id: 1, text: 'سبحان الله', sortOrder: 1, isDeletable: false),
    TasbihModel(id: 2, text: 'الحمد لله', sortOrder: 2, isDeletable: false),
  ];

  // Helper to create a ProviderContainer with a mocked repository.
  ProviderContainer createContainer({
    required Map<String, Object> preferences,
    Map<int, int> todayCounts = const {},
  }) {
    SharedPreferences.setMockInitialValues(preferences);
    mockAzkarRepository = MockAzkarRepository();

    // Mock the repository methods to return dummy data.
    when(mockAzkarRepository.getCustomTasbihList())
        .thenAnswer((_) async => dummyTasbihList);
    when(mockAzkarRepository.getTodayTasbihCounts())
        .thenAnswer((_) async => todayCounts);
    when(mockAzkarRepository.incrementTasbihDailyCount(any))
        .thenAnswer((_) async {});
    // ✨ [الإصلاح] إضافة المحاكاة (Stub) الناقصة.
    when(mockAzkarRepository.getTodayGoalsWithProgress())
        .thenAnswer((_) async => []); // Return an empty list for simplicity.

    final container = ProviderContainer(
      overrides: [
        azkarRepositoryProvider
            .overrideWith((ref) async => mockAzkarRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('TasbihStateNotifier Tests', () {
    test('Initial state loads correctly with active ID and counts from storage',
        () async {
      // Arrange
      final container = createContainer(
        preferences: {AppConstants.activeTasbihIdKey: 2},
        todayCounts: {1: 10, 2: 33},
      );

      // Act
      // Wait for the async _init method to complete.
      await container.read(tasbihStateProvider.notifier).initializationComplete;
      final state = container.read(tasbihStateProvider);

      // Assert
      expect(state.activeTasbihId, 2);
      expect(state.count, 33);
    });

    test('Initial state uses first tasbih if no active ID is saved', () async {
      // Arrange
      final container = createContainer(
        preferences: {}, // No active ID
        todayCounts: {1: 5},
      );

      // Act
      await container.read(tasbihStateProvider.notifier).initializationComplete;
      final state = container.read(tasbihStateProvider);

      // ✨ [الإصلاح] انتظر اكتمال الـ FutureProvider قبل قراءته.
      final activeTasbih = await container.read(activeTasbihProvider.future);

      // Assert
      expect(state.activeTasbihId, null);
      expect(state.count, 0);
      expect(activeTasbih.id, 1);
    });

    test('setActiveTasbih updates state and saves ID to SharedPreferences',
        () async {
      // Arrange
      final container = createContainer(
        preferences: {AppConstants.activeTasbihIdKey: 1},
        todayCounts: {1: 10, 2: 33},
      );
      final notifier = container.read(tasbihStateProvider.notifier);
      await notifier.initializationComplete;

      // Act
      await notifier.setActiveTasbih(2);

      // Assert
      final state = container.read(tasbihStateProvider);
      expect(state.activeTasbihId, 2);
      expect(state.count, 33);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(AppConstants.activeTasbihIdKey), 2);
    });

    test('increment updates count, calls repository, and invalidates provider',
        () async {
      // Arrange
      final container = createContainer(
        preferences: {AppConstants.activeTasbihIdKey: 1},
        todayCounts: {1: 10},
      );
      final notifier = container.read(tasbihStateProvider.notifier);
      await notifier.initializationComplete;

      // Act
      await notifier.increment();

      // Assert - State
      final state = container.read(tasbihStateProvider);
      expect(state.count, 11);

      // Assert - Repository Interaction
      verify(mockAzkarRepository.incrementTasbihDailyCount(1)).called(1);
    });

    test('resetCount sets the count to 0 but does not affect stored progress',
        () async {
      // Arrange
      final container = createContainer(
        preferences: {AppConstants.activeTasbihIdKey: 1},
        todayCounts: {1: 10},
      );
      final notifier = container.read(tasbihStateProvider.notifier);
      await notifier.initializationComplete;
      expect(container.read(tasbihStateProvider).count, 10);

      // Act
      await notifier.resetCount();

      // Assert
      expect(container.read(tasbihStateProvider).count, 0);

      verifyNever(mockAzkarRepository.incrementTasbihDailyCount(any));
    });

    // ✨ [الإصلاح] إضافة `Completer` للتحكم في التهيئة داخل Notifier
    // هذا سيجعل الاختبارات أكثر موثوقية.
    // افتح ملف "tasbih_provider.dart" وأضف السطرين التاليين:
    /*
    class TasbihStateNotifier extends StateNotifier<TasbihState> {
      ...
      final Completer<void> _initCompleter = Completer<void>();
      Future<void> get initializationComplete => _initCompleter.future;

      TasbihStateNotifier(this._ref) : super(TasbihState()) {
        _init();
      }

      Future<void> _init() async {
        ...
        state = state.copyWith(...);
        _initCompleter.complete(); // أضف هذا السطر في نهاية دالة _init
      }
      ...
    }
    */
    // لقد قمت بتطبيق هذا المنطق في الاختبار بالفعل.
  });
}
