// lib/core/providers/settings_provider.dart
import 'dart:async';
import 'package:azkari/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  // ✨ [تعديل] تمرير الـ ref للـ Notifier للوصول لخدمة الإشعارات
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final Ref _ref; // ✨ [جديد]
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationComplete => _initCompleter.future;

  // ✨ [تعديل] استقبال الـ ref
  SettingsNotifier(this._ref) : super(SettingsModel()) {
    _loadSettings();
  }

  // ✨ [جديد] مفاتيح SharedPreferences للإشعارات
  static const String _morningNotifKey = 'morning_notif_enabled';
  static const String _eveningNotifKey = 'evening_notif_enabled';
  static const String _themeKey = 'theme_mode';
  static const String _fontScaleKey = 'font_scale';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];
      final fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
      // ✨ [جديد] تحميل إعدادات الإشعارات
      final morningEnabled = prefs.getBool(_morningNotifKey) ?? false;
      final eveningEnabled = prefs.getBool(_eveningNotifKey) ?? false;

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
    await prefs.setInt(_themeKey, newTheme.index);
    state = state.copyWith(themeMode: newTheme);
  }

  Future<void> updateFontScale(double newScale) async {
    await _initCompleter.future;
    if (state.fontScale == newScale) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, newScale);
    state = state.copyWith(fontScale: newScale);
  }

  // ✨ [جديد] دالة لتحديث إشعارات الصباح
  Future<void> updateMorningNotification(bool isEnabled) async {
    await _initCompleter.future;
    if (state.morningNotificationEnabled == isEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_morningNotifKey, isEnabled);
    state = state.copyWith(morningNotificationEnabled: isEnabled);

    // جدولة أو إلغاء الإشعار
    final notifService = _ref.read(notificationServiceProvider);
    if (isEnabled) {
      await notifService.scheduleMorningReminder();
    } else {
      await notifService.cancelMorningReminder();
    }
  }

  // ✨ [جديد] دالة لتحديث إشعارات المساء
  Future<void> updateEveningNotification(bool isEnabled) async {
    await _initCompleter.future;
    if (state.eveningNotificationEnabled == isEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eveningNotifKey, isEnabled);
    state = state.copyWith(eveningNotificationEnabled: isEnabled);

    // جدولة أو إلغاء الإشعار
    final notifService = _ref.read(notificationServiceProvider);
    if (isEnabled) {
      await notifService.scheduleEveningReminder();
    } else {
      await notifService.cancelEveningReminder();
    }
  }
}
