// lib/core/providers/settings_provider.dart

import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/models/settings_model.dart';
import 'package:azkari/core/providers/app_providers.dart';
import 'package:azkari/features/settings/use_cases/update_evening_notification_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_font_scale_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_morning_notification_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_theme_use_case.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart'; // For sharedPreferencesProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// -- Use Case Providers --
// [جديد] Providers لحالات استخدام الإعدادات.
final updateThemeUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return UpdateThemeUseCase(prefs);
});

final updateFontScaleUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return UpdateFontScaleUseCase(prefs);
});

final updateMorningNotificationUseCaseProvider =
    FutureProvider.autoDispose((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final notifService = ref.read(notificationServiceProvider);
  return UpdateMorningNotificationUseCase(prefs, notifService);
});

final updateEveningNotificationUseCaseProvider =
    FutureProvider.autoDispose((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final notifService = ref.read(notificationServiceProvider);
  return UpdateEveningNotificationUseCase(prefs, notifService);
});

// -- State Notifier Provider --
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final Ref _ref;
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationComplete => _initCompleter.future;

  SettingsNotifier(this._ref) : super(SettingsModel()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final themeIndex =
          prefs.getInt(AppConstants.themeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];
      final fontScale = prefs.getDouble(AppConstants.fontScaleKey) ?? 1.0;
      final morningEnabled =
          prefs.getBool(AppConstants.morningNotifKey) ?? false;
      final eveningEnabled =
          prefs.getBool(AppConstants.eveningNotifKey) ?? false;

      state = state.copyWith(
        themeMode: themeMode,
        fontScale: fontScale,
        morningNotificationEnabled: morningEnabled,
        eveningNotificationEnabled: eveningEnabled,
      );
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    } catch (e) {
      if (!_initCompleter.isCompleted) _initCompleter.completeError(e);
    }
  }

  // [مُعدَّل] أصبحت الدوال الآن تستدعي الـ Use Cases
  Future<void> updateTheme(ThemeMode newTheme) async {
    if (state.themeMode == newTheme) return;
    await _initCompleter.future;

    final useCase = await _ref.read(updateThemeUseCaseProvider.future);
    await useCase.execute(newTheme);
    state = state.copyWith(themeMode: newTheme);
  }

  Future<void> updateFontScale(double newScale) async {
    if (state.fontScale == newScale) return;
    await _initCompleter.future;

    final useCase = await _ref.read(updateFontScaleUseCaseProvider.future);
    await useCase.execute(newScale);
    state = state.copyWith(fontScale: newScale);
  }

  Future<void> updateMorningNotification(bool isEnabled) async {
    if (state.morningNotificationEnabled == isEnabled) return;
    await _initCompleter.future;

    final useCase =
        await _ref.read(updateMorningNotificationUseCaseProvider.future);
    await useCase.execute(isEnabled);
    state = state.copyWith(morningNotificationEnabled: isEnabled);
  }

  Future<void> updateEveningNotification(bool isEnabled) async {
    if (state.eveningNotificationEnabled == isEnabled) return;
    await _initCompleter.future;

    final useCase =
        await _ref.read(updateEveningNotificationUseCaseProvider.future);
    await useCase.execute(isEnabled);
    state = state.copyWith(eveningNotificationEnabled: isEnabled);
  }
}
