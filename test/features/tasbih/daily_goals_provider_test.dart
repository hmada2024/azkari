// test/features/tasbih/daily_goals_provider_test.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/repositories/adhkar_repository.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'daily_goals_provider_test.mocks.dart';

@GenerateMocks([AdhkarRepository])
void main() {
  late MockAdhkarRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAdhkarRepository();
    when(mockRepository.getGoalsWithTodayProgress())
        .thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        // ✨ [تعديل] استخدام overrideWith لتوفير Future مكتمل
        adhkarRepositoryProvider.overrideWith(
          (ref) => Future.value(mockRepository),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DailyGoalsNotifier Unit Tests', () {
    test('setOrUpdateGoal calls repository and invalidates provider', () async {
      // Arrange
      // [تعديل] يجب أن ترجع الدالة Future
      when(mockRepository.setOrUpdateGoal(any, any))
          .thenAnswer((_) async => Future.value());
      final notifier = container.read(dailyGoalsNotifierProvider.notifier);
      final listener = ProviderListener<AsyncValue<List<DailyGoalModel>>>();
      container.listen(dailyGoalsProvider, listener.call,
          fireImmediately: true);
      // انتظر حتى يكتمل التحميل الأولي
      await container.read(dailyGoalsProvider.future);
      expect(listener.log.length, 1);

      // Act
      await notifier.setOrUpdateGoal(1, 100);

      // Assert
      verify(mockRepository.setOrUpdateGoal(1, 100)).called(1);
      expect(listener.log.length, 2);
    });

    test('removeGoal calls repository and invalidates provider', () async {
      // Arrange
      // [تعديل] يجب أن ترجع الدالة Future
      when(mockRepository.removeGoal(any))
          .thenAnswer((_) async => Future.value());
      final notifier = container.read(dailyGoalsNotifierProvider.notifier);
      final listener = ProviderListener<AsyncValue<List<DailyGoalModel>>>();
      container.listen(dailyGoalsProvider, listener.call,
          fireImmediately: true);
      await container.read(dailyGoalsProvider.future);
      expect(listener.log.length, 1);

      // Act
      await notifier.removeGoal(1);

      // Assert
      verify(mockRepository.removeGoal(1)).called(1);
      expect(listener.log.length, 2);
    });

    test('incrementProgressForTasbih calls repository and invalidates provider',
        () async {
      // Arrange
      when(mockRepository.getGoalForTasbih(1)).thenAnswer(
          (_) async => {'id': 101, 'tasbih_id': 1, 'target_count': 100});
      when(mockRepository.incrementGoalProgress(101))
          .thenAnswer((_) async => Future.value());
      final notifier = container.read(dailyGoalsNotifierProvider.notifier);
      final listener = ProviderListener<AsyncValue<List<DailyGoalModel>>>();
      container.listen(dailyGoalsProvider, listener.call,
          fireImmediately: true);
      await container.read(dailyGoalsProvider.future);
      expect(listener.log.length, 1);

      // Act
      await notifier.incrementProgressForTasbih(1);

      // Assert
      verify(mockRepository.getGoalForTasbih(1)).called(1);
      verify(mockRepository.incrementGoalProgress(101)).called(1);
      expect(listener.log.length, 2);
    });
  });
}

class ProviderListener<T> {
  final List<T> log = [];
  void call(T? previous, T next) {
    log.add(next);
  }
}
