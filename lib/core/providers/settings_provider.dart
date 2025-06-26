// lib/core/providers/settings_provider.dart
import 'dart:async'; // ✨ استيراد جديد
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  // ✨ تطبيق نمط Completer (القسم 2.1 من الدليل)
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationComplete => _initCompleter.future;

  SettingsNotifier() : super(SettingsModel()) {
    _loadSettings();
  }

  static const String _themeKey = 'theme_mode';
  static const String _fontScaleKey = 'font_scale';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];
      final fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;

      state = state.copyWith(
        themeMode: themeMode,
        fontScale: fontScale,
      );
      _initCompleter.complete(); // ✅ إعلام باكتمال التهيئة بنجاح
    } catch (e) {
      _initCompleter.completeError(e); // ❌ إعلام بفشل التهيئة
    }
  }

  Future<void> updateTheme(ThemeMode newTheme) async {
    await _initCompleter.future; // ✨ انتظار اكتمال التهيئة
    if (state.themeMode == newTheme) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, newTheme.index);
    state = state.copyWith(themeMode: newTheme);
  }

  Future<void> updateFontScale(double newScale) async {
    await _initCompleter.future; // ✨ انتظار اكتمال التهيئة
    if (state.fontScale == newScale) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, newScale);
    state = state.copyWith(fontScale: newScale);
  }
}
