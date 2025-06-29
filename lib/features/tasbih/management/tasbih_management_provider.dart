// lib/features/tasbih/management/tasbih_management_provider.dart
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✨ [تعديل] التعامل مع المستودع كـ Future
final tasbihForManagementProvider =
    FutureProvider<List<TasbihModel>>((ref) async {
  final repository = await ref.watch(adhkarRepositoryProvider.future);
  return repository.getCustomTasbihList();
});

final tasbihManagementProvider = StateNotifierProvider.autoDispose<
    TasbihManagementNotifier, AsyncValue<void>>((ref) {
  return TasbihManagementNotifier(ref);
});

class TasbihManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TasbihManagementNotifier(this._ref) : super(const AsyncData(null));

  Future<bool> _performAction(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      _invalidateProviders();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void _invalidateProviders() {
    _ref.invalidate(tasbihForManagementProvider);
    _ref.invalidate(tasbihListProvider);
    _ref.invalidate(dailyGoalsProvider);
  }

  Future<bool> addTasbih(String text) async {
    // ✨ [تعديل] انتظار المستودع قبل استخدامه
    final repository = await _ref.read(adhkarRepositoryProvider.future);
    return _performAction(() => repository.addTasbih(text));
  }

  Future<bool> updateTasbihText(int id, String newText) async {
    // ✨ [تعديل] انتظار المستودع قبل استخدامه
    final repository = await _ref.read(adhkarRepositoryProvider.future);
    return _performAction(() => repository.updateTasbihText(id, newText));
  }

  Future<bool> deleteTasbih(int id) async {
    // ✨ [تعديل] انتظار المستودع قبل استخدامه
    final repository = await _ref.read(adhkarRepositoryProvider.future);
    return _performAction(() => repository.deleteTasbih(id));
  }

  Future<bool> reorderTasbihList(int oldIndex, int newIndex) async {
    final list = _ref.read(tasbihForManagementProvider).value;
    if (list == null) return false;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    final Map<int, int> newOrders = {};
    for (int i = 0; i < list.length; i++) {
      newOrders[list[i].id] = i;
    }

    // ✨ [تعديل] انتظار المستودع قبل استخدامه
    final repository = await _ref.read(adhkarRepositoryProvider.future);
    return _performAction(() => repository.updateSortOrders(newOrders));
  }
}
