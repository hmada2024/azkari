// lib/features/tasbih/providers/tasbih_provider.dart

import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/tasbih/use_cases/increment_daily_count_use_case.dart';
import 'package:azkari/features/tasbih/use_cases/set_active_tasbih_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -- SharedPreferences Provider --
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

// -- Data Presentation Providers --
class TasbihListItem {
  final TasbihModel tasbih;
  final int count;
  TasbihListItem({required this.tasbih, required this.count});
}

final tasbihListWithCountsProvider =
    FutureProvider.autoDispose<List<TasbihListItem>>((ref) async {
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
  // [مُعدَّل] الاعتماد على goalsRepositoryProvider الجديد
  final repo = await ref.watch(goalsRepositoryProvider.future);
  return repo.getTodayTasbihCounts();
});

final tasbihListProvider = FutureProvider<List<TasbihModel>>((ref) async {
  // [مُعدَّل] الاعتماد على tasbihRepositoryProvider الجديد
  final repository = await ref.watch(tasbihRepositoryProvider.future);
  return repository.getCustomTasbihList();
});

final activeTasbihProvider = FutureProvider<TasbihModel>((ref) async {
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
// [مُعدَّل] الاعتماد على goalsRepositoryProvider الجديد
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
// ... (The rest of the file remains unchanged)
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
    StateNotifierProvider<TasbihStateNotifier, TasbihState>((ref) {
  return TasbihStateNotifier(ref);
});

class TasbihStateNotifier extends StateNotifier<TasbihState> {
  final Ref _ref;
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationComplete => _initCompleter.future;

  TasbihStateNotifier(this._ref) : super(TasbihState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      await _resetIfNewDay(prefs);
      final activeId = prefs.getInt(AppConstants.activeTasbihIdKey);
      final countsValue = await _ref.read(dailyTasbihCountsProvider.future);

      state = state.copyWith(
        activeTasbihId: activeId,
        count: activeId != null ? (countsValue[activeId] ?? 0) : 0,
      );
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }

  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final lastOpenDate = prefs.getString(AppConstants.lastResetDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastOpenDate != today) {
      await prefs.setString(AppConstants.lastResetDateKey, today);
    }
  }

  Future<void> increment() async {
    if (state.activeTasbihId == null) {
      final tasbihList = await _ref.read(tasbihListProvider.future);
      if (tasbihList.isNotEmpty) {
        await setActiveTasbih(tasbihList.first.id);
      } else {
        return;
      }
    }

    state = state.copyWith(count: state.count + 1);

    try {
      final useCase =
          await _ref.read(incrementDailyCountUseCaseProvider.future);
      await useCase.execute(state.activeTasbihId!);
      _ref.invalidate(dailyTasbihCountsProvider);
    } catch (e) {
      // Handle error
    }
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
    try {
      final useCase = await _ref.read(setActiveTasbihUseCaseProvider.future);
      await useCase.execute(id);
    } catch (e) {
      // Handle error
    }
  }
}
