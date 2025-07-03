// lib/features/goal_management/providers/goal_management_provider.dart
import 'package:azkari/core/providers/core_providers.dart';
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/managed_goal_model.dart';
import 'package:azkari/features/goal_management/use_cases/add_tasbih_use_case.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class GoalManagementState {
  final AsyncValue<List<ManagedGoal>> items;
  final bool isSaving;
  const GoalManagementState({
    this.items = const AsyncValue.loading(),
    this.isSaving = false,
  });
  GoalManagementState copyWith({
    AsyncValue<List<ManagedGoal>>? items,
    bool? isSaving,
  }) {
    return GoalManagementState(
      items: items ?? this.items,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final managedGoalsProvider =
    FutureProvider.autoDispose<List<ManagedGoal>>((ref) async {
  final repo = await ref.watch(goalsRepositoryProvider.future);
  return repo.getManagedGoals();
});

final addTasbihUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(tasbihRepositoryProvider.future);
  return AddTasbihUseCase(repo);
});

// تم حذف deleteTasbihUseCaseProvider بالكامل

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
    _ref.listen<AsyncValue<List<ManagedGoal>>>(managedGoalsProvider,
        (previous, next) {
      if (mounted) {
        state = state.copyWith(items: next);
      }
    }, fireImmediately: true);
  }

  void _invalidateData() {
    _ref.invalidate(managedGoalsProvider);
    _ref.invalidate(dailyGoalsStateProvider);
    _ref.invalidate(tasbihListProvider);
    _ref.invalidate(activeTasbihProvider);
  }

  Future<void> _performAction(Future<void> Function() action,
      {String? successMessage, String? errorMessage}) async {
    state = state.copyWith(isSaving: true);
    try {
      await action();
      if (successMessage != null) {
        _ref.read(messengerServiceProvider).showSuccessSnackBar(successMessage);
      }
      _invalidateData();
    } catch (e) {
      _ref
          .read(messengerServiceProvider)
          .showErrorSnackBar(errorMessage ?? 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Future<void> setGoal(int tasbihId, int count) async {
    await _performAction(
      () async {
        final repo = await _ref.read(goalsRepositoryProvider.future);
        await repo.setGoal(tasbihId, count);
      },
    );
  }

  Future<void> toggleActivation(int tasbihId, bool isActivating) async {
    await _performAction(
      () async {
        final repo = await _ref.read(goalsRepositoryProvider.future);
        if (isActivating) {
          await repo.activateGoal(tasbihId, 10); // Default value is 10
        } else {
          await repo.deactivateGoal(tasbihId);
        }
      },
      successMessage: isActivating ? 'تم تفعيل الهدف' : 'تم إلغاء تفعيل الهدف',
    );
  }

  Future<bool> addTasbih(String text) async {
    final useCase = await _ref.read(addTasbihUseCaseProvider.future);
    final result = await useCase.execute(text);
    return result.fold(
      (failure) {
        _ref.read(messengerServiceProvider).showErrorSnackBar(failure.message);
        return false;
      },
      (_) {
        _ref
            .read(messengerServiceProvider)
            .showSuccessSnackBar('تمت الإضافة بنجاح');
        _invalidateData();
        return true;
      },
    );
  }

  // تم حذف deleteTasbih بالكامل
}
