// lib/core/models/settings_model.dart
import 'package:flutter/material.dart';

class SettingsModel {
  final ThemeMode themeMode;
  final double fontScale;
  final bool morningNotificationEnabled;
  final bool eveningNotificationEnabled;
  SettingsModel({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.morningNotificationEnabled = false,
    this.eveningNotificationEnabled = false,
  });
  SettingsModel copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    bool? morningNotificationEnabled,
    bool? eveningNotificationEnabled,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      morningNotificationEnabled:
          morningNotificationEnabled ?? this.morningNotificationEnabled,
      eveningNotificationEnabled:
          eveningNotificationEnabled ?? this.eveningNotificationEnabled,
    );
  }
}
