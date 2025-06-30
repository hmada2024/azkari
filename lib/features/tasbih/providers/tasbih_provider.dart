// lib/features/tasbih/tasbih_provider.dart
import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✨ [جديد] موديل مدمج لواجهة قائمة اختيار الذكر.
class TasbihListItem {
  final TasbihModel tasbih;
  final int count;
  TasbihListItem({required this.tasbih, required this.count});
}

// ✨ [جديد] Provider مدمج يجمع بين قائمة التسابيح وعداداتها.
// هذا يحل مشكلة مراقبة اثنين FutureProviders في الواجهة.
final tasbihListWithCountsProvider =
    FutureProvider.autoDispose<List<TasbihListItem>>((ref) async {
  // استخدام Future.wait لانتظار الاثنين معاً بكفاءة.
  final results = await Future.wait([
    ref.watch(tasbihListProvider.future),
    ref.watch(dailyTasbihCountsProvider.future),
  ]);

  final tasbihList = results[0] as List<TasbihModel>;
  final counts = results[1] as Map<int, int>;

  return tasbihList.map((tasbih) {
    return TasbihListItem(
      tasbih: tasbih,
      count: counts[tasbih.id] ?? 0,
    );
  }).toList();
});

final dailyTasbihCountsProvider =
    FutureProvider.autoDispose<Map<int, int>>((ref) async {
  final repo = await ref.watch(azkarRepositoryProvider.future);
  return repo.getTodayTasbihCounts();
});

final tasbihListProvider = FutureProvider<List<TasbihModel>>((ref) async {
  final repository = await ref.watch(azkarRepositoryProvider.future);
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

  TasbihStateNotifier(this._ref) : super(TasbihState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay();
    final activeId = _prefs.getInt(AppConstants.activeTasbihIdKey);
    final countsValue = await _ref.read(dailyTasbihCountsProvider.future);

    state = state.copyWith(
      activeTasbihId: activeId,
      count: activeId != null ? (countsValue[activeId] ?? 0) : 0,
    );
  }

  Future<void> _resetIfNewDay() async {
    final lastOpenDate = _prefs.getString(AppConstants.lastResetDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastOpenDate != today) {
      await _prefs.setString(AppConstants.lastResetDateKey, today);
    }
  }

  Future<void> increment() async {
    if (state.activeTasbihId == null) return;

    state = state.copyWith(count: state.count + 1);

    final repo = await _ref.read(azkarRepositoryProvider.future);
    await repo.incrementTasbihDailyCount(state.activeTasbihId!);

    // ✨ [تعديل] إزالة الإبطال اليدوي المتعدد (Invalidation Cascade).
    // الآن، نحن نبطل فقط المصدر المباشر للبيانات.
    // الـ Providers الأخرى ستتحدث تلقائياً بفضل الاعتمادية التي أنشأناها.
    _ref.invalidate(dailyTasbihCountsProvider);
  }

  Future<void> resetCount() async {
    state = state.copyWith(count: 0);
  }

  Future<void> setActiveTasbih(int id) async {
    final countsValue = await _ref.read(dailyTasbihCountsProvider.future);
    state = state.copyWith(
      activeTasbihId: id,
      count: countsValue[id] ?? 0,
    );
    await _prefs.setInt(AppConstants.activeTasbihIdKey, id);
  }
}
