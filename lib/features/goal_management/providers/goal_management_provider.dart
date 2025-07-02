// lib/features/goal_management/providers/goal_management_provider.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/goal_management/use_cases/add_tasbih_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/delete_tasbih_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/reorder_tasbih_list_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/set_tasbih_goal_use_case.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class GoalManagementItem {
  final TasbihModel tasbih;
  final int targetCount;
  const GoalManagementItem({required this.tasbih, required this.targetCount});
}

@immutable
class GoalManagementState {
  final AsyncValue<List<GoalManagementItem>> items;
  final bool isSaving;
  final Failure? error; // [جديد] لتضمين حالة الخطأ مباشرة

  const GoalManagementState({
    this.items = const AsyncValue.loading(),
    this.isSaving = false,
    this.error,
  });

  GoalManagementState copyWith({
    AsyncValue<List<GoalManagementItem>>? items,
    bool? isSaving,
    Failure? error,
    bool clearError = false, // للسماح بتصفير الخطأ
  }) {
    return GoalManagementState(
      items: items ?? this.items,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final goalManagementListProvider =
    Provider.autoDispose<AsyncValue<List<GoalManagementItem>>>((ref) {
  final tasbihListAsync = ref.watch(tasbihListProvider);
  final goalsAsync = ref.watch(dailyGoalsStateProvider.select((s) => s.goals));

  if (tasbihListAsync.isLoading || goalsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (tasbihListAsync.hasError) {
    return AsyncValue.error(
        tasbihListAsync.error!, tasbihListAsync.stackTrace!);
  }
  if (goalsAsync.hasError) {
    return AsyncValue.error(goalsAsync.error!, goalsAsync.stackTrace!);
  }

  final tasbihList = tasbihListAsync.value!;
  final goals = goalsAsync.value!;
  final goalMap = {for (var g in goals) g.tasbihId: g.targetCount};

  final result = tasbihList.map((tasbih) {
    return GoalManagementItem(
      tasbih: tasbih,
      targetCount: goalMap[tasbih.id] ?? 0,
    );
  }).toList();

  return AsyncValue.data(result);
});

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

final goalManagementStateProvider = StateNotifierProvider.autoDispose<
    GoalManagementNotifier, GoalManagementState>((ref) {
  return GoalManagementNotifier(ref);
});

class GoalManagementNotifier extends StateNotifier<GoalManagementState> {
  final Ref _ref;
  GoalManagementNotifier(this._ref) : super(const GoalManagementState()) {
    _fetchItems();
  }

  void _fetchItems() {
    // الاستماع إلى provider البيانات وتحديث حالة items
    _ref.listen<AsyncValue<List<GoalManagementItem>>>(
        goalManagementListProvider, (previous, next) {
      if (mounted) {
        state = state.copyWith(items: next);
      }
    });
  }

  Future<void> _performAction(
    Future<Either<Failure, void>> Function() action, {
    required List<ProviderOrFamily> providersToInvalidate,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final result = await action();

    result.fold(
      (failure) {
        // [الإصلاح] تحديث حالة الخطأ مباشرة في كائن الحالة
        state = state.copyWith(isSaving: false, error: failure);
      },
      (success) {
        for (var provider in providersToInvalidate) {
          _ref.invalidate(provider);
        }
        state = state.copyWith(isSaving: false);
      },
    );
  }

  Future<void> setGoal(int tasbihId, int count) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(setTasbihGoalUseCaseProvider.future);
        return useCase.execute(tasbihId, count);
      },
      providersToInvalidate: [dailyGoalsStateProvider],
    );
  }

  Future<void> addTasbih(String text) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(addTasbihUseCaseProvider.future);
        return useCase.execute(text);
      },
      providersToInvalidate: [tasbihListProvider, dailyGoalsStateProvider],
    );
  }

  Future<void> deleteTasbih(int id) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(deleteTasbihUseCaseProvider.future);
        return useCase.execute(id);
      },
      providersToInvalidate: [tasbihListProvider, dailyGoalsStateProvider],
    );
  }

  Future<void> reorderTasbih(int oldIndex, int newIndex) async {
    final currentList = state.items.value;
    if (currentList == null) return;

    await _performAction(
      () async {
        final useCase =
            await _ref.read(reorderTasbihListUseCaseProvider.future);
        return useCase.execute(currentList, oldIndex, newIndex);
      },
      providersToInvalidate: [tasbihListProvider, dailyGoalsStateProvider],
    );
  }
}
