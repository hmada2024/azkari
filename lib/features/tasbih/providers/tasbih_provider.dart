// lib/features/tasbih/providers/tasbih_provider.dart
import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/providers/core_providers.dart';
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/use_cases/increment_daily_count_use_case.dart';
import 'package:azkari/features/tasbih/use_cases/set_active_tasbih_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -- Data Presentation Providers --
final tasbihListProvider =
    FutureProvider.autoDispose<List<TasbihModel>>((ref) async {
  final repository = await ref.watch(tasbihRepositoryProvider.future);
  return repository.getCustomTasbihList();
});

final activeTasbihProvider =
    FutureProvider.autoDispose<TasbihModel>((ref) async {
  final tasbihList = await ref.watch(tasbihListProvider.future);
  final activeId =
      ref.watch(tasbihStateProvider.select((s) => s.activeTasbihId));

  if (tasbihList.isEmpty) {
    return TasbihModel(
        id: -1, text: 'أضف ذكرًا للبدء', sortOrder: 0, isDeletable: false);
  }
  return tasbihList.firstWhere((t) => t.id == activeId,
      orElse: () => tasbihList.first);
});

// -- Use Case Providers --
final incrementDailyCountUseCaseProvider =
    FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(goalsRepositoryProvider.future);
  return IncrementDailyCountUseCase(repo);
});

final setActiveTasbihUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SetActiveTasbihUseCase(prefs);
});

// -- State Model and Notifier --
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

final tasbihStateProvider =
    StateNotifierProvider.autoDispose<TasbihStateNotifier, TasbihState>((ref) {
  return TasbihStateNotifier(ref);
});

class TasbihStateNotifier extends StateNotifier<TasbihState> {
  final Ref _ref;
  ProviderSubscription? _subscription;
  Timer? _debounceTimer; // [جديد] مؤقت لتأجيل الكتابة في قاعدة البيانات

  TasbihStateNotifier(this._ref) : super(TasbihState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      await _resetIfNewDay(prefs);
      final activeId = prefs.getInt(AppConstants.activeTasbihIdKey);

      _listenToGoalChanges();

      if (mounted) {
        state = state.copyWith(activeTasbihId: activeId);
        _updateCountForActiveId(activeId);
      }
    } catch (e) {
      // Handle init error
    }
  }

  void _listenToGoalChanges() {
    _subscription?.close();
    _subscription =
        _ref.listen<DailyGoalsState>(dailyGoalsStateProvider, (_, next) {
      if (next.goals.hasValue) {
        _updateCountForActiveId(state.activeTasbihId);
      }
    });
  }

  void _updateCountForActiveId(int? activeId) {
    if (activeId == null) {
      if (mounted) state = state.copyWith(count: 0);
      return;
    }
    final goals = _ref.read(dailyGoalsStateProvider).goals.valueOrNull ?? [];
    final goalIndex = goals.indexWhere((g) => g.tasbihId == activeId);

    if (mounted) {
      final newCount = goalIndex != -1 ? goals[goalIndex].currentProgress : 0;
      state = state.copyWith(count: newCount);
    }
  }

  @override
  void dispose() {
    _subscription?.close();
    _debounceTimer?.cancel(); // [جديد] التأكد من إلغاء المؤقت عند الخروج
    super.dispose();
  }

  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final lastOpenDate = prefs.getString(AppConstants.lastResetDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastOpenDate != today) {
      await prefs.setString(AppConstants.lastResetDateKey, today);
    }
  }

  /// [مُعاد هيكلته بالكامل] لتحقيق الأداء الأمثل
  void increment() {
    // 1. التأكد من وجود ذكر نشط. إذا لم يوجد، لا تفعل شيئًا.
    final activeId = state.activeTasbihId;
    if (activeId == null) {
      return;
    }

    // 2. تحديث فوري للحالة في الذاكرة (سريع جدًا ولا يسبب أي تهنيج)
    _ref.read(dailyGoalsStateProvider.notifier).incrementProgress(activeId);

    // 3. تأجيل الكتابة في قاعدة البيانات (Debouncing)
    _debounceTimer?.cancel(); // إلغاء أي عملية كتابة مؤجلة سابقة
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // هذه الكتلة لن تنفذ إلا بعد 500 ميللي ثانية من آخر ضغطة
      try {
        final useCase =
            await _ref.read(incrementDailyCountUseCaseProvider.future);
        await useCase.execute(activeId);
      } catch (e) {
        // يمكن تسجيل الخطأ هنا إذا لزم الأمر
      }
    });
  }

  Future<void> resetCount() {
    // هذه عملية معقدة يجب أن تعيد تعيين التقدم في قاعدة البيانات.
    // في الوقت الحالي، سنتجنب تنفيذها لمنع فقدان البيانات العرضي.
    // ستحتاج إلى مربع حوار للتأكيد.
    return Future.value();
  }

  Future<void> setActiveTasbih(int id) async {
    if (mounted) {
      state = state.copyWith(activeTasbihId: id);
      _updateCountForActiveId(id);
    }

    try {
      final useCase = await _ref.read(setActiveTasbihUseCaseProvider.future);
      await useCase.execute(id);
    } catch (e) {
      // Handle error
    }
  }
}
