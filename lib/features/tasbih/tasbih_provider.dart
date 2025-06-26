// lib/features/tasbih/tasbih_provider.dart

import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- مفاتيح الحفظ ---
const String _tasbihCounterKey = 'tasbih_counter';
const String _activeTasbihIdKey = 'active_tasbih_id';
const String _lastResetDateKey = 'last_reset_date';
const String _usedTasbihIdsKey = 'used_tasbih_ids_today';

// --- الـ Providers ---

// 1. Provider لجلب قائمة التسابيح من قاعدة البيانات
final tasbihListProvider = FutureProvider<List<TasbihModel>>((ref) async {
  final repository = ref.watch(adhkarRepositoryProvider);
  return repository.getCustomTasbihList();
});

// 2. Provider لإدارة حالة السبحة (العداد، الذكر النشط، إلخ)
final tasbihStateProvider =
    StateNotifierProvider<TasbihStateNotifier, TasbihState>((ref) {
  return TasbihStateNotifier(ref);
});

// --- نماذج الحالة (State Models) ---

// موديل يمثل الحالة الكاملة لشاشة السبحة
class TasbihState {
  final int count;
  final int? activeTasbihId;
  final Set<int> usedTodayIds; // Set لمنع التكرار

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
  TasbihStateNotifier(this._ref) : super(TasbihState()) {
    _loadState();
  }

  final Ref _ref;

  // تحميل الحالة الكاملة عند بدء التشغيل
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs); // تحقق من اليوم الجديد أولاً

    final count = prefs.getInt(_tasbihCounterKey) ?? 0;
    final activeTasbihId = prefs.getInt(_activeTasbihIdKey);
    final usedIdsStringList = prefs.getStringList(_usedTasbihIdsKey) ?? [];
    final usedTodayIds = usedIdsStringList.map(int.parse).toSet();

    state = state.copyWith(
      count: count,
      activeTasbihId: activeTasbihId,
      usedTodayIds: usedTodayIds,
    );
  }

  // حفظ الحالة
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tasbihCounterKey, state.count);
    if (state.activeTasbihId != null) {
      await prefs.setInt(_activeTasbihIdKey, state.activeTasbihId!);
    }
    await prefs.setStringList(_usedTasbihIdsKey,
        state.usedTodayIds.map((id) => id.toString()).toList());
  }

  // منطق إعادة التعيين اليومي
  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final lastResetDateStr = prefs.getString(_lastResetDateKey);
    final today = DateTime.now();
    final todayDateStr = "${today.year}-${today.month}-${today.day}";

    if (lastResetDateStr != todayDateStr) {
      await prefs.remove(_usedTasbihIdsKey); // مسح قائمة المستخدمة اليوم
      await prefs.setString(
          _lastResetDateKey, todayDateStr); // تسجيل تاريخ اليوم
    }
  }

  // زيادة العداد
  void increment() {
    state = state.copyWith(count: state.count + 1);

    // تتبع الاستخدام اليومي
    if (state.activeTasbihId != null &&
        !state.usedTodayIds.contains(state.activeTasbihId!)) {
      final updatedUsedIds = Set<int>.from(state.usedTodayIds)
        ..add(state.activeTasbihId!);
      state = state.copyWith(usedTodayIds: updatedUsedIds);
    }
    _saveState();
  }

  // إعادة تعيين العداد الحالي فقط
  void resetCount() {
    state = state.copyWith(count: 0);
    _saveState();
  }

  // تغيير الذكر النشط
  void setActiveTasbih(int id) {
    state = state.copyWith(
        activeTasbihId: id, count: 0); // تصفير العداد عند تغيير الذكر
    _saveState();
  }

  // إضافة تسبيح جديد إلى قاعدة البيانات
  Future<void> addTasbih(String text) async {
    final repository = _ref.read(adhkarRepositoryProvider);
    await repository.addTasbih(text);
    // إعادة تحميل قائمة التسابيح لإظهار التغيير
    _ref.invalidate(tasbihListProvider);
  }

  Future<void> deleteTasbih(int id) async {
    final repository = _ref.read(adhkarRepositoryProvider);
    await repository.deleteTasbih(id);
    _ref.invalidate(tasbihListProvider);
  }
}
