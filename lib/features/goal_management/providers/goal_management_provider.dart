// lib/features/goal_management/providers/goal_management_provider.dart

import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/goal_management/use_cases/add_tasbih_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/delete_tasbih_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/reorder_tasbih_list_use_case.dart';
import 'package:azkari/features/goal_management/use_cases/set_tasbih_goal_use_case.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

// -- Data Presentation Provider --
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

// -- Use Case Providers --
// [جديد] Provider لكل حالة استخدام.
final addTasbihUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(azkarRepositoryProvider.future);
  return AddTasbihUseCase(repo);
});

final deleteTasbihUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(azkarRepositoryProvider.future);
  return DeleteTasbihUseCase(repo);
});

final reorderTasbihListUseCaseProvider =
    FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(azkarRepositoryProvider.future);
  return ReorderTasbihListUseCase(repo);
});

final setTasbihGoalUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(azkarRepositoryProvider.future);
  return SetTasbihGoalUseCase(repo);
});

// -- State Notifier (The Coordinator) --
final goalManagementStateProvider =
    StateNotifierProvider.autoDispose<GoalManagementNotifier, AsyncValue<void>>(
        (ref) {
  return GoalManagementNotifier(ref);
});

class GoalManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  GoalManagementNotifier(this._ref) : super(const AsyncData(null));

  /// دالة مساعدة لتغليف منطق التحميل والخطأ.
  Future<void> _performAction(
    Future<void> Function() action, {
    required List<ProviderOrFamily> providersToInvalidate,
  }) async {
    state = const AsyncValue.loading();
    try {
      await action();

      for (var provider in providersToInvalidate) {
        _ref.invalidate(provider);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // [مُعدَّل] الـ Notifier أصبح "منسقاً" الآن.
  Future<void> setGoal(int tasbihId, int count) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(setTasbihGoalUseCaseProvider.future);
        await useCase.execute(tasbihId, count);
      },
      providersToInvalidate: [dailyGoalsProvider, goalManagementProvider],
    );
  }

  // [مُعدَّل]
  Future<void> addTasbih(String text) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(addTasbihUseCaseProvider.future);
        await useCase.execute(text);
      },
      providersToInvalidate: [tasbihListProvider, goalManagementProvider],
    );
  }

  // [مُعدَّل]
  Future<void> deleteTasbih(int id) async {
    await _performAction(
      () async {
        final useCase = await _ref.read(deleteTasbihUseCaseProvider.future);
        await useCase.execute(id);
      },
      providersToInvalidate: [
        tasbihListProvider,
        dailyGoalsProvider,
        goalManagementProvider
      ],
    );
  }

  // [مُعدَّل]
  Future<void> reorderTasbih(int oldIndex, int newIndex) async {
    // هذا الإجراء لا يتناسب تمامًا مع نمط `_performAction` لأنه لا يحتاج لإبطال
    // الـ providers بنفس الطريقة (الواجهة تعيد البناء فورًا).
    // يمكننا تحسينه لاحقًا إذا لزم الأمر.
    state = const AsyncValue.loading();
    try {
      final list = _ref.read(goalManagementProvider).asData!.value;
      final useCase = await _ref.read(reorderTasbihListUseCaseProvider.future);

      // تمرير البيانات اللازمة للـ Use Case لتنفيذ المنطق.
      await useCase.execute(list, oldIndex, newIndex);

      // إبطال الـ providers المتأثرة لإعادة تحميل البيانات من المصدر.
      _ref.invalidate(tasbihListProvider);
      _ref.invalidate(goalManagementProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
