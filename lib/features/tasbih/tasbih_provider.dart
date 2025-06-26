// lib/features/tasbih/tasbih_provider.dart
import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tasbihListProvider = FutureProvider<List<TasbihModel>>((ref) async {
  final repository = ref.watch(adhkarRepositoryProvider);
  return repository.getCustomTasbihList();
});

final activeTasbihProvider = Provider<TasbihModel>((ref) {
  final tasbihListAsync = ref.watch(tasbihListProvider);
  final activeId =
      ref.watch(tasbihStateProvider.select((s) => s.activeTasbihId));

  return tasbihListAsync.when(
    loading: () => TasbihModel(
        id: -1, text: 'جاري التحميل...', sortOrder: 0, isDeletable: false),
    error: (err, st) =>
        TasbihModel(id: -1, text: 'حدث خطأ', sortOrder: 0, isDeletable: false),
    data: (tasbihList) {
      if (tasbihList.isEmpty) {
        return TasbihModel(
          id: -1,
          text: 'أضف ذكرًا للبدء من القائمة',
          sortOrder: 0,
          isDeletable: false,
        );
      }
      return tasbihList.firstWhere(
        (t) => t.id == activeId,
        orElse: () => tasbihList.first,
      );
    },
  );
});

final tasbihStateProvider =
    StateNotifierProvider<TasbihStateNotifier, TasbihState>((ref) {
  return TasbihStateNotifier(ref);
});

class TasbihState {
  final int count;
  final int? activeTasbihId;
  final Set<int> usedTodayIds;

  TasbihState({
    this.count = 0,
    this.activeTasbihId,
    this.usedTodayIds = const {},
  });

  TasbihState copyWith({
    int? count,
    int? activeTasbihId,
    Set<int>? usedTodayIds,
  }) {
    return TasbihState(
      count: count ?? this.count,
      activeTasbihId: activeTasbihId ?? this.activeTasbihId,
      usedTodayIds: usedTodayIds ?? this.usedTodayIds,
    );
  }
}

class TasbihStateNotifier extends StateNotifier<TasbihState> {
  final Completer<void> _initCompleter = Completer<void>();
  final Ref _ref;
  late final SharedPreferences _prefs;

  TasbihStateNotifier(this._ref) : super(TasbihState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _resetIfNewDay(_prefs);

      final count = _prefs.getInt(AppConstants.tasbihCounterKey) ?? 0;
      final activeTasbihId = _prefs.getInt(AppConstants.activeTasbihIdKey);
      final usedIdsStringList =
          _prefs.getStringList(AppConstants.usedTasbihIdsKey) ?? [];
      final usedTodayIds = usedIdsStringList.map(int.parse).toSet();

      if (mounted) {
        state = state.copyWith(
          count: count,
          activeTasbihId: activeTasbihId,
          usedTodayIds: usedTodayIds,
        );
      }
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
    }
  }

  Future<void> _saveState() async {
    await _initCompleter.future;
    if (!mounted) return;

    await Future.wait([
      _prefs.setInt(AppConstants.tasbihCounterKey, state.count),
      if (state.activeTasbihId != null)
        _prefs.setInt(AppConstants.activeTasbihIdKey, state.activeTasbihId!)
      else
        _prefs.remove(AppConstants.activeTasbihIdKey),
      _prefs.setStringList(AppConstants.usedTasbihIdsKey,
          state.usedTodayIds.map((id) => id.toString()).toList()),
    ]);
  }

  // ✅ [تم الإصلاح]: استخدام الاسم الصحيح للثابت
  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final lastOpenDate = prefs.getString(AppConstants.lastResetDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastOpenDate != today) {
      await prefs.setString(AppConstants.lastResetDateKey, today);
      await prefs.setStringList(AppConstants.usedTasbihIdsKey, []);
    }
  }

  Future<void> increment() async {
    await _initCompleter.future;
    if (!mounted) return;
    state = state.copyWith(count: state.count + 1);
    await _saveState();
  }

  Future<void> resetCount() async {
    await _initCompleter.future;
    state = state.copyWith(count: 0);
    await _saveState();
  }

  Future<void> setActiveTasbih(int id) async {
    await _initCompleter.future;
    state = state.copyWith(activeTasbihId: id, count: 0);
    await _saveState();
  }

  Future<void> addTasbih(String text) async {
    final repository = _ref.read(adhkarRepositoryProvider);
    await repository.addTasbih(text);
    _ref.invalidate(tasbihListProvider);
  }

  Future<void> deleteTasbih(int id) async {
    final repository = _ref.read(adhkarRepositoryProvider);
    await repository.deleteTasbih(id);
    if (state.activeTasbihId == id) {
      state = state.copyWith(activeTasbihId: null, count: 0);
    }
    _ref.invalidate(tasbihListProvider);
    await _saveState();
  }
}
