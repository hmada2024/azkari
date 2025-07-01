// lib/features/goal_management/providers/goal_management_provider.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class GoalManagementItem {
  final TasbihModel tasbih;
  final int targetCount;
  const GoalManagementItem({required this.tasbih, required this.targetCount});
}

final goalManagementProvider =
    Provider.autoDispose<List<GoalManagementItem>>((ref) {
  final List<TasbihModel> tasbihList =
      ref.watch(tasbihListProvider).asData?.value ?? [];
  final List<DailyGoalModel> goals =
      ref.watch(dailyGoalsProvider).asData?.value ?? [];

  final goalMap = {for (var g in goals) g.tasbihId: g.targetCount};

  return tasbihList.map((tasbih) {
    return GoalManagementItem(
      tasbih: tasbih,
      targetCount: goalMap[tasbih.id] ?? 0,
    );
  }).toList();
});

final goalManagementStateProvider =
    StateNotifierProvider.autoDispose<GoalManagementNotifier, AsyncValue<void>>(
        (ref) {
  return GoalManagementNotifier(ref);
});

class GoalManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  GoalManagementNotifier(this._ref) : super(const AsyncData(null));

  Future<void> _performAction(Future<void> Function() action,
      {required List<ProviderOrFamily> providersToInvalidate}) async {
    state = const AsyncValue.loading();
    try {
      // ✨ [الإصلاح] تم حذف السطر غير المستخدم من هنا
      await action();

      for (var provider in providersToInvalidate) {
        _ref.invalidate(provider);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setGoal(int tasbihId, int count) async {
    await _performAction(
      () async {
        final repo = await _ref.read(azkarRepositoryProvider.future);
        await repo.setGoal(tasbihId, count);
      },
      providersToInvalidate: [dailyGoalsProvider],
    );
  }

  Future<void> addTasbih(String text) async {
    await _performAction(
      () async {
        final repo = await _ref.read(azkarRepositoryProvider.future);
        await repo.addTasbih(text);
      },
      providersToInvalidate: [tasbihListProvider],
    );
  }

  Future<void> deleteTasbih(int id) async {
    await _performAction(
      () async {
        final repo = await _ref.read(azkarRepositoryProvider.future);
        await repo.deleteTasbih(id);
      },
      providersToInvalidate: [tasbihListProvider, dailyGoalsProvider],
    );
  }

  Future<void> reorderTasbih(int oldIndex, int newIndex) async {
    state = const AsyncValue.loading();
    try {
      final list = _ref.read(goalManagementProvider);

      if (oldIndex < newIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);

      final Map<int, int> newOrders = {
        for (int i = 0; i < list.length; i++) list[i].tasbih.id: i
      };

      final repo = await _ref.read(azkarRepositoryProvider.future);
      await repo.updateSortOrders(newOrders);
      _ref.invalidate(tasbihListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
