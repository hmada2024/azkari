import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(SettingsModel()) {
    _loadSettings();
  }

  // مفاتيح الحفظ
  static const String _themeKey = 'theme_mode';
  static const String _fontScaleKey = 'font_scale';
  // ✨✨✨ تم حذف مفاتيح الإشعارات ✨✨✨

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeIndex];
    final fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    
    state = state.copyWith(
      themeMode: themeMode,
      fontScale: fontScale,
    );
  }

  Future<void> updateTheme(ThemeMode newTheme) async {
    if (state.themeMode == newTheme) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, newTheme.index);
    state = state.copyWith(themeMode: newTheme);
  }

  Future<void> updateFontScale(double newScale) async {
    if (state.fontScale == newScale) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, newScale);
    state = state.copyWith(fontScale: newScale);
  }

}