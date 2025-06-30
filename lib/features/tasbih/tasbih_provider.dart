// lib/features/tasbih/tasbih_provider.dart
import 'dart:async';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:azkari/features/progress/providers/statistics_provider.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dailyTasbihCountsProvider = FutureProvider<Map<int, int>>((ref) async {
  final repo = await ref.watch(adhkarRepositoryProvider.future);
  return repo.getTodayTasbihCounts();
});

final tasbihListProvider = FutureProvider<List<TasbihModel>>((ref) async {
  final repository = await ref.watch(adhkarRepositoryProvider.future);
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
            id: -1, text: 'أضف ذكرًا للبدء', sortOrder: 0, isDeletable: false);
      }
      return tasbihList.firstWhere((t) => t.id == activeId,
          orElse: () => tasbihList.first);
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

  TasbihState({this.count = 0, this.activeTasbihId});

  TasbihState copyWith({int? count, int? activeTasbihId}) {
    return TasbihState(
      count: count ?? this.count,
      activeTasbihId: activeTasbihId ?? this.activeTasbihId,
    );
  }
}

class TasbihStateNotifier extends StateNotifier<TasbihState> {
  final Ref _ref;
  late final SharedPreferences _prefs;
  static const _activeTasbihIdKey = 'active_tasbih_id_v2';
  static const _lastResetDateKey = 'last_reset_date_v2';

  TasbihStateNotifier(this._ref) : super(TasbihState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay();
    final activeId = _prefs.getInt(_activeTasbihIdKey);
    final countsValue = await _ref.read(dailyTasbihCountsProvider.future);

    state = state.copyWith(
      activeTasbihId: activeId,
      count: activeId != null ? (countsValue[activeId] ?? 0) : 0,
    );
  }

  Future<void> _resetIfNewDay() async {
    final lastOpenDate = _prefs.getString(_lastResetDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastOpenDate != today) {
      await _prefs.setString(_lastResetDateKey, today);
    }
  }

  Future<void> increment() async {
    if (state.activeTasbihId == null) return;

    state = state.copyWith(count: state.count + 1);

    final repo = await _ref.read(adhkarRepositoryProvider.future);
    await repo.incrementTasbihDailyCount(state.activeTasbihId!);
    _ref.invalidate(dailyTasbihCountsProvider);
    _ref.invalidate(dailyGoalsProvider);
    _ref.invalidate(statisticsProvider); // [مهم] تحديث الإحصائيات فوراً
  }

  // [تصحيح وإعادة تفعيل]
  Future<void> resetCount() async {
    // هذا سيعيد العداد في الواجهة إلى 0 مؤقتاً
    // وعند اختيار ذكر آخر ثم العودة إليه، سيعرض الإجمالي اليومي مرة أخرى
    // وهو السلوك المطلوب (تصفير الجلسة الحالية)
    state = state.copyWith(count: 0);
  }

  Future<void> setActiveTasbih(int id) async {
    final countsValue = await _ref.read(dailyTasbihCountsProvider.future);
    state = state.copyWith(
      activeTasbihId: id,
      count: countsValue[id] ?? 0,
    );
    await _prefs.setInt(_activeTasbihIdKey, id);
  }
}
