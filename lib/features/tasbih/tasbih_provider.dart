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

// ✨✨✨ Provider جديد ومخصص لجلب الذكر النشط ✨✨✨
// هذا الـ Provider يعزل منطق تحديد الذكر النشط عن الواجهة
final activeTasbihProvider = Provider<TasbihModel>((ref) {
  // 1. مشاهدة قائمة التسابيح الكاملة
  final tasbihListAsync = ref.watch(tasbihListProvider);
  // 2. مشاهدة الـ ID الخاص بالذكر النشط فقط
  final activeId =
      ref.watch(tasbihStateProvider.select((s) => s.activeTasbihId));

  // 3. التعامل مع حالة تحميل القائمة أو وجود خطأ
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
      // 4. البحث عن الذكر النشط، أو استخدام أول ذكر كخيار افتراضي
      return tasbihList.firstWhere(
        (t) => t.id == activeId,
        orElse: () => tasbihList.first,
      );
    },
  );
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
  late final SharedPreferences _prefs;

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(_prefs);

    final count = _prefs.getInt(_tasbihCounterKey) ?? 0;
    final activeTasbihId = _prefs.getInt(_activeTasbihIdKey);
    final usedIdsStringList = _prefs.getStringList(_usedTasbihIdsKey) ?? [];
    final usedTodayIds = usedIdsStringList.map(int.parse).toSet();

    // تأكد من أن الـ Notifier لم يتم التخلص منه قبل تحديث الحالة
    if (mounted) {
      state = state.copyWith(
        count: count,
        activeTasbihId: activeTasbihId,
        usedTodayIds: usedTodayIds,
      );
    }
  }

  Future<void> _saveState() async {
    await _prefs.setInt(_tasbihCounterKey, state.count);
    if (state.activeTasbihId != null) {
      await _prefs.setInt(_activeTasbihIdKey, state.activeTasbihId!);
    } else {
      await _prefs.remove(_activeTasbihIdKey);
    }
    await _prefs.setStringList(_usedTasbihIdsKey,
        state.usedTodayIds.map((id) => id.toString()).toList());
  }

  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final lastResetDateStr = prefs.getString(_lastResetDateKey);
    final today = DateTime.now();
    final todayDateStr = "${today.year}-${today.month}-${today.day}";

    if (lastResetDateStr != todayDateStr) {
      await prefs.remove(_usedTasbihIdsKey);
      await prefs.setString(_lastResetDateKey, todayDateStr);
    }
  }

  void increment() {
    state = state.copyWith(count: state.count + 1);

    if (state.activeTasbihId != null &&
        !state.usedTodayIds.contains(state.activeTasbihId!)) {
      final updatedUsedIds = Set<int>.from(state.usedTodayIds)
        ..add(state.activeTasbihId!);
      state = state.copyWith(usedTodayIds: updatedUsedIds);
    }
    _saveState();
  }

  void resetCount() {
    state = state.copyWith(count: 0);
    _saveState();
  }

  void setActiveTasbih(int id) {
    state = state.copyWith(activeTasbihId: id, count: 0);
    _saveState();
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
      _saveState();
    }
    _ref.invalidate(tasbihListProvider);
  }
}
