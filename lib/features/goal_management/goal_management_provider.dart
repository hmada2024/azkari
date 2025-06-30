// lib/features/goal_management/goal_management_provider.dart
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

// نموذج عرض مخصص لهذه الشاشة فقط
@immutable
class GoalManagementItem {
  final TasbihModel tasbih;
  final int targetCount;
  const GoalManagementItem({required this.tasbih, required this.targetCount});
}

// Provider لجلب البيانات ودمجها (Read-only)
final goalManagementProvider =
    FutureProvider<List<GoalManagementItem>>((ref) async {
  final repo = await ref.watch(adhkarRepositoryProvider.future);
  final tasbihList = await repo.getCustomTasbihList();
  final goals = await repo.getTodayGoalsWithProgress();

  final goalMap = {for (var g in goals) g.tasbihId: g.targetCount};

  return tasbihList.map((tasbih) {
    return GoalManagementItem(
      tasbih: tasbih,
      targetCount: goalMap[tasbih.id] ?? 0,
    );
  }).toList();
});

// Provider لإدارة عمليات التعديل (Write)
final goalManagementStateProvider =
    StateNotifierProvider.autoDispose<GoalManagementNotifier, AsyncValue<void>>(
        (ref) {
  return GoalManagementNotifier(ref);
});

class GoalManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  GoalManagementNotifier(this._ref) : super(const AsyncData(null));

  // دالة مساعدة لتنفيذ الأوامر وتحديث الواجهة
  Future<void> _performAction(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      _ref.invalidate(
          goalManagementProvider); // [مهم] إعادة تحميل البيانات بعد التعديل
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setGoal(int tasbihId, int count) async {
    await _performAction(() async {
      final repo = await _ref.read(adhkarRepositoryProvider.future);
      await repo.setGoal(tasbihId, count);
    });
  }

  Future<void> addTasbih(String text) async {
    await _performAction(() async {
      final repo = await _ref.read(adhkarRepositoryProvider.future);
      await repo.addTasbih(text);
    });
  }

  Future<void> deleteTasbih(int id) async {
    await _performAction(() async {
      final repo = await _ref.read(adhkarRepositoryProvider.future);
      await repo.deleteTasbih(id);
    });
  }

  Future<void> reorderTasbih(int oldIndex, int newIndex) async {
    final list = _ref.read(goalManagementProvider).value;
    if (list == null) return;

    if (oldIndex < newIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    final Map<int, int> newOrders = {
      for (int i = 0; i < list.length; i++) list[i].tasbih.id: i
    };

    await _performAction(() async {
      final repo = await _ref.read(adhkarRepositoryProvider.future);
      await repo.updateSortOrders(newOrders);
    });
  }
}
