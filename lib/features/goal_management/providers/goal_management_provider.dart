// lib/features/goal_management/providers/goal_management_providers.dart

import 'package:azkari/core/error/failures.dart'; // [جديد]
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/goal_management/use_cases/add_tasbih_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/delete_tasbih_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/reorder_tasbih_list_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/set_tasbih_goal_use_case.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:dartz/dartz.dart'; // [جديد]
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class GoalManagementItem {
  final TasbihModel tasbih;
  final int targetCount;
  const GoalManagementItem({required this.tasbih, required this.targetCount});
}

final goalManagementProvider =
    FutureProvider.autoDispose<List<GoalManagementItem>>((ref) async {
  final List<TasbihModel> tasbihList =
      await ref.watch(tasbihListProvider.future);
  final List<DailyGoalModel> goals = await ref.watch(dailyGoalsProvider.future);

  final goalMap = {for (var g in goals) g.tasbihId: g.targetCount};

  return tasbihList.map((tasbih) {
    return GoalManagementItem(
      tasbih: tasbih,
      targetCount: goalMap[tasbih.id] ?? 0,
    );
  }).toList();
});

// ... (Use Case providers remain the same)
final addTasbihUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(tasbihRepositoryProvider.future);
  return AddTasbihUseCase(repo);
});

final deleteTasbihUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(tasbihRepositoryProvider.future);
  return DeleteTasbihUseCase(repo);
});

final reorderTasbihListUseCaseProvider =
    FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(tasbihRepositoryProvider.future);
  return ReorderTasbihListUseCase(repo);
});

final setTasbihGoalUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(goalsRepositoryProvider.future);
  return SetTasbihGoalUseCase(repo);
});

// [مُعدَّل] الـ Notifier الآن يتعامل مع Either
final goalManagementStateProvider =
    StateNotifierProvider.autoDispose<GoalManagementNotifier, AsyncValue<void>>(
        (ref) {
  return GoalManagementNotifier(ref);
});

class GoalManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  GoalManagementNotifier(this._ref) : super(const AsyncData(null));

  // [مُعدَّل] دالة مساعدة للتعامل مع نتيجة Either
  Future<void> _performAction(
    Future<Either<Failure, void>> Function() action, {
    required List<ProviderOrFamily> providersToInvalidate,
  }) async {
    state = const AsyncValue.loading();
    final result = await action();

    result.fold(
      (failure) {
        // في حالة الفشل، نمرر كائن الفشل للواجهة
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (success) {
        // في حالة النجاح، نبطل الـ providers ونعيد الحالة للنجاح
        for (var provider in providersToInvalidate) {
          _ref.invalidate(provider);
        }
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> setGoal(int tasbihId, int count) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(setTasbihGoalUseCaseProvider.future);
        return useCase.execute(tasbihId, count);
      },
      providersToInvalidate: [dailyGoalsProvider, goalManagementProvider],
    );
  }

  Future<void> addTasbih(String text) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(addTasbihUseCaseProvider.future);
        return useCase.execute(text);
      },
      providersToInvalidate: [tasbihListProvider, goalManagementProvider],
    );
  }

  Future<void> deleteTasbih(int id) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(deleteTasbihUseCaseProvider.future);
        return useCase.execute(id);
      },
      providersToInvalidate: [
        tasbihListProvider,
        dailyGoalsProvider,
        goalManagementProvider
      ],
    );
  }

  Future<void> reorderTasbih(int oldIndex, int newIndex) async {
    await _performAction(
      () async {
        final list = await _ref.read(goalManagementProvider.future);
        final useCase =
            await _ref.read(reorderTasbihListUseCaseProvider.future);
        return useCase.execute(list, oldIndex, newIndex);
      },
      providersToInvalidate: [tasbihListProvider, goalManagementProvider],
    );
  }
}
