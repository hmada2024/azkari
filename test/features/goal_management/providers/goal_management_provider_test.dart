// test/features/goal_management/providers/goal_management_provider_test.dart
import 'package:azkari/core/providers/core_providers.dart';
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helpers.dart';
import '../../../test_helpers.mocks.dart';

void main() {
  late MockGoalsRepository mockGoalsRepository;
  late MockTasbihRepository mockTasbihRepository;
  late MockMessengerService mockMessengerService;
  late MockAddTasbihUseCase mockAddTasbihUseCase;
  late ProviderContainer container;

  setUp(() {
    mockGoalsRepository = MockGoalsRepository();
    mockTasbihRepository = MockTasbihRepository();
    mockMessengerService = MockMessengerService();
    mockAddTasbihUseCase = MockAddTasbihUseCase();

    container = createContainer(
      overrides: {
        goalsRepositoryProvider.overrideWith((ref) async => mockGoalsRepository),
        tasbihRepositoryProvider.overrideWith((ref) async => mockTasbihRepository),
        messengerServiceProvider.overrideWithValue(mockMessengerService),
        addTasbihUseCaseProvider.overrideWith((ref) async => mockAddTasbihUseCase),
      },
    );
  });

  group('GoalManagementNotifier', () {
    test('initial state has items as loading', () {
      final state = container.read(goalManagementStateProvider);
      expect(state.items, const AsyncValue.loading());
      expect(state.isSaving, false);
    });

    test(
        'fetches and updates items from repository on initialization', () async {
      when(mockGoalsRepository.getManagedGoals())
          .thenAnswer((_) async => [tManagedGoal]);

      final listener = Listener<GoalManagementState>();
      container.listen(
        goalManagementStateProvider,
        listener.call,
        fireImmediately: true,
      );

      await container.read(managedGoalsProvider.future);

      verifyInOrder([
        listener(null, const GoalManagementState()),
        listener(
          const GoalManagementState(),
          const GoalManagementState(items: AsyncLoading()),
        ),
        listener(
          const GoalManagementState(items: AsyncLoading()),
          GoalManagementState(items: AsyncData([tManagedGoal])),
        ),
      ]);
    });

    test('toggleActivation calls activateGoal and shows success message',
        () async {
      when(mockGoalsRepository.activateGoal(any, any))
          .thenAnswer((_) async => {});

      final notifier = container.read(goalManagementStateProvider.notifier);
      await notifier.toggleActivation(1, true);

      verify(mockGoalsRepository.activateGoal(1, 10)).called(1);
      verify(mockMessengerService.showSuccessSnackBar('تم تفعيل الهدف'))
          .called(1);
    });

    test('toggleActivation calls deactivateGoal and shows success message',
        () async {
      when(mockGoalsRepository.deactivateGoal(any)).thenAnswer((_) async => {});

      final notifier = container.read(goalManagementStateProvider.notifier);
      await notifier.toggleActivation(1, false);

      verify(mockGoalsRepository.deactivateGoal(1)).called(1);
      verify(mockMessengerService
              .showSuccessSnackBar('تم إلغاء تفعيل الهدف'))
          .called(1);
    });

    test(
        'addTasbih calls use case, shows success, and invalidates providers on success',
        () async {
      const text = 'New Tasbih';
      when(mockAddTasbihUseCase.execute(text))
          .thenAnswer((_) async => const Right(null));

      final notifier = container.read(goalManagementStateProvider.notifier);
      final result = await notifier.addTasbih(text);

      expect(result, isTrue);
      verify(mockAddTasbihUseCase.execute(text)).called(1);
      verify(mockMessengerService.showSuccessSnackBar('تمت الإضافة بنجاح'))
          .called(1);
      
      expect(container.read(managedGoalsProvider), isA<AsyncValue<void>>());
      expect(container.read(dailyGoalsStateProvider), isA<DailyGoalsState>());
      expect(container.read(tasbihListProvider), isA<AsyncValue<void>>());
    });

    test('addTasbih calls use case and shows error on failure', () async {
      const text = 'New Tasbih';
      when(mockAddTasbihUseCase.execute(text))
          .thenAnswer((_) async => const Left(tDatabaseFailure));

      final notifier = container.read(goalManagementStateProvider.notifier);
      final result = await notifier.addTasbih(text);

      expect(result, isFalse);
      verify(mockAddTasbihUseCase.execute(text)).called(1);
      verify(mockMessengerService.showErrorSnackBar(tDatabaseFailure.message))
          .called(1);
    });
  });
}