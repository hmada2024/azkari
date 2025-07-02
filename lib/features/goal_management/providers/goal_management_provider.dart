// lib/features/goal_management/providers/goal_management_provider.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/core/providers/core_providers.dart';
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

  const GoalManagementState({
    this.items = const AsyncValue.loading(),
    this.isSaving = false,
  });

  GoalManagementState copyWith({
    AsyncValue<List<GoalManagementItem>>? items,
    bool? isSaving,
  }) {
    return GoalManagementState(
      items: items ?? this.items,
      isSaving: isSaving ?? this.isSaving,
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
  final goalRepo = await ref.watch(goalsRepositoryProvider.future);
  return AddTasbihUseCase(repo, goalRepo);
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
    _ref.listen<AsyncValue<List<GoalManagementItem>>>(
        goalManagementListProvider, (previous, next) {
      if (mounted) {
        state = state.copyWith(items: next);
      }
    }, fireImmediately: true);
  }

  Future<bool> _performAction(
    Future<Either<Failure, void>> Function() action, {
    required List<ProviderOrFamily> providersToInvalidate,
    String? successMessage,
  }) async {
    state = state.copyWith(isSaving: true);
    final result = await action();
    final messenger = _ref.read(messengerServiceProvider);
    bool wasSuccessful = false;

    result.fold(
      (failure) {
        messenger.showErrorSnackBar(failure.message);
        wasSuccessful = false;
      },
      (_) {
        for (var provider in providersToInvalidate) {
          _ref.invalidate(provider);
        }
        if (successMessage != null) {
          messenger.showSuccessSnackBar(successMessage);
        }
        wasSuccessful = true;
      },
    );
    if (mounted) {
      state = state.copyWith(isSaving: false);
    }
    return wasSuccessful;
  }

  Future<bool> setGoal(int tasbihId, int count) async {
    // ✨ [جديد] تطبيق قاعدة العمل هنا
    if (count > 0 && count < 10) {
      _ref
          .read(messengerServiceProvider)
          .showErrorSnackBar('الحد الأدنى للهدف هو 10 مرات.');
      return false;
    }
    return await _performAction(
      () async {
        final useCase = await _ref.read(setTasbihGoalUseCaseProvider.future);
        return useCase.execute(tasbihId, count);
      },
      providersToInvalidate: [dailyGoalsStateProvider],
    );
  }

  Future<bool> addTasbih(String text) async {
    return await _performAction(
      () async {
        final useCase = await _ref.read(addTasbihUseCaseProvider.future);
        return useCase.execute(text);
      },
      providersToInvalidate: [tasbihListProvider, dailyGoalsStateProvider],
      successMessage: 'تمت إضافة الذكر بنجاح',
    );
  }

  Future<void> deleteTasbih(int id) async {
    // ... (لا تغيير هنا)
    final originalItems = state.items.value;
    if (originalItems == null) return;
    final optimisticItems = List<GoalManagementItem>.from(originalItems)
      ..removeWhere((item) => item.tasbih.id == id);
    state = state.copyWith(items: AsyncValue.data(optimisticItems));
    final useCase = await _ref.read(deleteTasbihUseCaseProvider.future);
    final result = await useCase.execute(id);
    final messenger = _ref.read(messengerServiceProvider);
    result.fold(
      (failure) {
        messenger.showErrorSnackBar("فشل الحذف: ${failure.message}");
        state = state.copyWith(items: AsyncValue.data(originalItems));
      },
      (success) {
        messenger.showSuccessSnackBar('تم حذف الذكر بنجاح');
        _ref.invalidate(tasbihListProvider);
        _ref.invalidate(dailyGoalsStateProvider);
      },
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
