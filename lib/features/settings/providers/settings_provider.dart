// lib/features/settings/providers/settings_providers.dart
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/models/settings_model.dart';
import 'package:azkari/core/providers/core_providers.dart';
import 'package:azkari/features/settings/use_cases/update_evening_notification_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_font_scale_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_morning_notification_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_theme_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier(ref);
});
class SettingsNotifier extends StateNotifier<SettingsModel> {
  final Ref _ref;
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
      if (!mounted) return;
      state = state.copyWith(
        themeMode: themeMode,
        fontScale: fontScale,
        morningNotificationEnabled: morningEnabled,
        eveningNotificationEnabled: eveningEnabled,
      );
    } catch (e) {
    }
  }
  Future<void> updateTheme(ThemeMode newTheme) async {
    if (state.themeMode == newTheme) return;
    final useCase = await _ref.read(updateThemeUseCaseProvider.future);
    final result = await useCase.execute(newTheme);
    result.fold(
      (failure) {},
      (success) => state = state.copyWith(themeMode: newTheme),
    );
  }
  Future<void> updateFontScale(double newScale) async {
    if (state.fontScale == newScale) return;
    final useCase = await _ref.read(updateFontScaleUseCaseProvider.future);
    final result = await useCase.execute(newScale);
    result.fold(
      (failure) {},
      (success) => state = state.copyWith(fontScale: newScale),
    );
  }
  Future<void> updateMorningNotification(bool isEnabled) async {
    if (state.morningNotificationEnabled == isEnabled) return;
    final useCase =
        await _ref.read(updateMorningNotificationUseCaseProvider.future);
    final result = await useCase.execute(isEnabled);
    result.fold(
      (failure) {},
      (success) =>
          state = state.copyWith(morningNotificationEnabled: isEnabled),
    );
  }
  Future<void> updateEveningNotification(bool isEnabled) async {
    if (state.eveningNotificationEnabled == isEnabled) return;
    final useCase =
        await _ref.read(updateEveningNotificationUseCaseProvider.future);
    final result = await useCase.execute(isEnabled);
    result.fold(
      (failure) {},
      (success) =>
          state = state.copyWith(eveningNotificationEnabled: isEnabled),
    );
  }
}