// lib/features/tasbih/providers/tasbih_provider.dart
import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/providers/core_providers.dart';
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/use_cases/increment_daily_count_use_case.dart';
import 'package:azkari/features/tasbih/use_cases/reset_daily_progress_use_case.dart';
import 'package:azkari/features/tasbih/use_cases/set_active_tasbih_use_case.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tasbihListProvider =
    FutureProvider.autoDispose<List<TasbihModel>>((ref) async {
  // Now gets only ACTIVATED tasbih
  final repository = await ref.watch(tasbihRepositoryProvider.future);
  return repository.getActiveTasbihList();
});

final activeTasbihProvider =
    FutureProvider.autoDispose<TasbihModel>((ref) async {
  final tasbihList = await ref.watch(tasbihListProvider.future);
  final activeId =
      ref.watch(tasbihStateProvider.select((s) => s.activeTasbihId));

  if (tasbihList.isEmpty) {
    // تم إصلاح الخطأ هنا
    return TasbihModel(
        id: -1,
        text: 'قم بتفعيل أهدافك للبدء',
        sortOrder: 0,
        isDefault: false); // استخدام isDefault بدلاً من isDeletable
  }
  return tasbihList.firstWhere((t) => t.id == activeId,
      orElse: () => tasbihList.first);
});

final incrementDailyCountUseCaseProvider =
    FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(goalsRepositoryProvider.future);
  return IncrementDailyCountUseCase(repo);
});

final resetDailyProgressUseCaseProvider =
    FutureProvider.autoDispose((ref) async {
  final repo = await ref.watch(goalsRepositoryProvider.future);
  return ResetDailyProgressUseCase(repo);
});

final setActiveTasbihUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SetActiveTasbihUseCase(prefs);
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

final tasbihStateProvider =
    StateNotifierProvider.autoDispose<TasbihStateNotifier, TasbihState>((ref) {
  return TasbihStateNotifier(ref);
});

class TasbihStateNotifier extends StateNotifier<TasbihState> {
  final Ref _ref;
  ProviderSubscription? _subscription;
  Timer? _debounceTimer;

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
      debugPrint("Failed to initialize TasbihStateNotifier: $e");
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
      if (state.count != newCount) {
        state = state.copyWith(count: newCount);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.close();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final lastOpenDate = prefs.getString(AppConstants.lastResetDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastOpenDate != today) {
      await prefs.setString(AppConstants.lastResetDateKey, today);
    }
  }

  Future<void> increment() async {
    int? activeId = state.activeTasbihId;
    if (activeId == null) {
      final tasbihList = await _ref.read(tasbihListProvider.future);
      if (tasbihList.isNotEmpty) {
        activeId = tasbihList.first.id;
        await setActiveTasbih(activeId);
      } else {
        return;
      }
    }

    if (mounted) {
      state = state.copyWith(count: state.count + 1);
    }

    _ref.read(dailyGoalsStateProvider.notifier).incrementProgress(activeId);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final useCase =
            await _ref.read(incrementDailyCountUseCaseProvider.future);
        await useCase.execute(activeId!);
      } catch (e) {
        debugPrint("Failed to persist increment: $e");
      }
    });
  }

  Future<void> resetActiveTasbihProgress() async {
    final activeId = state.activeTasbihId;
    if (activeId == null) return;
    try {
      final useCase = await _ref.read(resetDailyProgressUseCaseProvider.future);
      final result = await useCase.execute(activeId);
      result.fold(
        (failure) => _ref
            .read(messengerServiceProvider)
            .showErrorSnackBar(failure.message),
        (success) {
          _ref.invalidate(dailyGoalsStateProvider);
          _ref
              .read(messengerServiceProvider)
              .showSuccessSnackBar('تم تصفير العداد');
        },
      );
    } catch (e) {
      _ref
          .read(messengerServiceProvider)
          .showErrorSnackBar('فشلت عملية تصفير العداد.');
    }
  }

  Future<void> setActiveTasbih(int id) async {
    if (mounted) {
      state = state.copyWith(activeTasbihId: id);
      _updateCountForActiveId(id);
    }
    try {
      final useCase = await _ref.read(setActiveTasbihUseCaseProvider.future);
      final result = await useCase.execute(id);
      result.fold(
        (failure) => _ref
            .read(messengerServiceProvider)
            .showErrorSnackBar(failure.message),
        (_) => null,
      );
    } catch (e) {
      _ref
          .read(messengerServiceProvider)
          .showErrorSnackBar('فشل حفظ الذكر النشط.');
    }
  }
}
