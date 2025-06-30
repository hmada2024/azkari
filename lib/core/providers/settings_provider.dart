// lib/core/providers/settings_provider.dart
import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

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
      final prefs = await SharedPreferences.getInstance();
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
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
    }
  }

  Future<void> updateTheme(ThemeMode newTheme) async {
    await _initCompleter.future;
    if (state.themeMode == newTheme) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.themeKey, newTheme.index);
    state = state.copyWith(themeMode: newTheme);
  }

  Future<void> updateFontScale(double newScale) async {
    await _initCompleter.future;
    if (state.fontScale == newScale) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.fontScaleKey, newScale);
    state = state.copyWith(fontScale: newScale);
  }

  Future<void> updateMorningNotification(bool isEnabled) async {
    await _initCompleter.future;
    if (state.morningNotificationEnabled == isEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.morningNotifKey, isEnabled);
    state = state.copyWith(morningNotificationEnabled: isEnabled);

    final notifService = _ref.read(notificationServiceProvider);
    if (isEnabled) {
      await notifService.scheduleMorningReminder();
    } else {
      await notifService.cancelMorningReminder();
    }
  }

  Future<void> updateEveningNotification(bool isEnabled) async {
    await _initCompleter.future;
    if (state.eveningNotificationEnabled == isEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.eveningNotifKey, isEnabled);
    state = state.copyWith(eveningNotificationEnabled: isEnabled);

    final notifService = _ref.read(notificationServiceProvider);
    if (isEnabled) {
      await notifService.scheduleEveningReminder();
    } else {
      await notifService.cancelEveningReminder();
    }
  }
}
