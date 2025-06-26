import 'package:flutter/material.dart';

class SettingsModel {
  final ThemeMode themeMode;
  final double fontScale;

  // ✨✨✨ تم حذف كل ما يتعلق بالإشعارات ✨✨✨

  SettingsModel({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
  });

  SettingsModel copyWith({
    ThemeMode? themeMode,
    double? fontScale,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}