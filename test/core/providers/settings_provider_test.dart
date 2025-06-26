// test/core/providers/settings_provider_test.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsNotifier Unit Tests', () {
    ProviderContainer createContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container;
    }

    test('Initializes with default settings when SharedPreferences is empty',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();

      // ✨ التصحيح: انتظار التهيئة باستخدام future الذي أضفناه
      await container.read(settingsProvider.notifier).initializationComplete;

      final settings = container.read(settingsProvider);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.fontScale, 1.0);
    });

    test('Loads settings from SharedPreferences on initialization', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.themeKey: ThemeMode.dark.index,
        AppConstants.fontScaleKey: 1.2,
      });
      final container = createContainer();

      // ✨ التصحيح
      await container.read(settingsProvider.notifier).initializationComplete;

      final settings = container.read(settingsProvider);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.fontScale, 1.2);
    });

    test('updateTheme updates state and saves to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();
      final notifier = container.read(settingsProvider.notifier);
      // ✨ التصحيح
      await notifier.initializationComplete;

      await notifier.updateTheme(ThemeMode.light);

      expect(container.read(settingsProvider).themeMode, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(AppConstants.themeKey), ThemeMode.light.index);
    });

    test('updateFontScale updates state and saves to SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();
      final notifier = container.read(settingsProvider.notifier);
      // ✨ التصحيح
      await notifier.initializationComplete;

      await notifier.updateFontScale(1.5);

      expect(container.read(settingsProvider).fontScale, 1.5);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble(AppConstants.fontScaleKey), 1.5);
    });
  });
}
