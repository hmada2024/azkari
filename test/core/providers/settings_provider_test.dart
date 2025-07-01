// test/core/providers/settings_provider_test.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/core/providers/app_providers.dart';
import 'package:azkari/core/providers/settings_provider.dart';
import 'package:azkari/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the generated mock file
import 'settings_provider_test.mocks.dart';

// Annotation to generate a mock class for NotificationService.
// This allows us to verify if its methods are called, without actually scheduling notifications.
@GenerateMocks([NotificationService])
void main() {
  // `TestWidgetsFlutterBinding.ensureInitialized()` is required for SharedPreferences mock.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationService mockNotificationService;

  // A helper function to create a ProviderContainer for testing.
  // It allows overriding dependencies, like our mocked services.
  ProviderContainer createContainer({
    required Map<String, Object> preferences,
  }) {
    // Set up the mock for SharedPreferences.
    SharedPreferences.setMockInitialValues(preferences);

    mockNotificationService = MockNotificationService();

    final container = ProviderContainer(
      overrides: [
        // We override the real NotificationService with our mock instance.
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
    // Add a tearDown to dispose the container after each test.
    addTearDown(container.dispose);
    return container;
  }

  group('SettingsNotifier Tests', () {
    test('Initial state loads correctly from SharedPreferences', () async {
      // Arrange: Prepare mock preferences with pre-defined values.
      final container = createContainer(
        preferences: {
          AppConstants.themeKey: ThemeMode.dark.index,
          AppConstants.fontScaleKey: 1.2,
          AppConstants.morningNotifKey: true,
          AppConstants.eveningNotifKey: false,
        },
      );

      // Act: Read the provider. Riverpod will automatically create the Notifier,
      // which in turn will call _loadSettings.
      final notifier = container.read(settingsProvider.notifier);
      // Wait for the async _loadSettings method to complete.
      await notifier.initializationComplete;

      final state = container.read(settingsProvider);

      // Assert: Check if the state matches the mock preferences.
      expect(state.themeMode, ThemeMode.dark);
      expect(state.fontScale, 1.2);
      expect(state.morningNotificationEnabled, isTrue);
      expect(state.eveningNotificationEnabled, isFalse);
    });

    test('Initial state uses default values when SharedPreferences is empty',
        () async {
      // Arrange: Create a container with empty preferences.
      final container = createContainer(preferences: {});

      // Act
      final notifier = container.read(settingsProvider.notifier);
      await notifier.initializationComplete;
      final state = container.read(settingsProvider);

      // Assert: Check if the state matches the default SettingsModel values.
      expect(state.themeMode, ThemeMode.system);
      expect(state.fontScale, 1.0);
      expect(state.morningNotificationEnabled, isFalse);
      expect(state.eveningNotificationEnabled, isFalse);
    });

    test('updateTheme updates state and saves to SharedPreferences', () async {
      // Arrange
      final container = createContainer(preferences: {});
      final notifier = container.read(settingsProvider.notifier);
      await notifier.initializationComplete;

      // Act
      await notifier.updateTheme(ThemeMode.light);

      // Assert: State is updated.
      expect(container.read(settingsProvider).themeMode, ThemeMode.light);

      // Assert: Value is saved to preferences.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(AppConstants.themeKey), ThemeMode.light.index);
    });

    test('updateFontScale updates state and saves to SharedPreferences',
        () async {
      // Arrange
      final container = createContainer(preferences: {});
      final notifier = container.read(settingsProvider.notifier);
      await notifier.initializationComplete;

      // Act
      await notifier.updateFontScale(1.5);

      // Assert: State is updated.
      expect(container.read(settingsProvider).fontScale, 1.5);

      // Assert: Value is saved to preferences.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble(AppConstants.fontScaleKey), 1.5);
    });

    test('updateMorningNotification(true) calls scheduleMorningReminder',
        () async {
      // Arrange
      final container =
          createContainer(preferences: {AppConstants.morningNotifKey: false});
      final notifier = container.read(settingsProvider.notifier);
      await notifier.initializationComplete;

      // Set up mock to expect a call and return a completed Future.
      when(mockNotificationService.scheduleMorningReminder())
          .thenAnswer((_) async {});

      // Act
      await notifier.updateMorningNotification(true);

      // Assert: Verify that the method on the mock service was called exactly once.
      verify(mockNotificationService.scheduleMorningReminder()).called(1);
      // Verify that no other methods were called.
      verifyNoMoreInteractions(mockNotificationService);
    });

    test('updateMorningNotification(false) calls cancelMorningReminder',
        () async {
      // Arrange
      final container =
          createContainer(preferences: {AppConstants.morningNotifKey: true});
      final notifier = container.read(settingsProvider.notifier);
      await notifier.initializationComplete;

      when(mockNotificationService.cancelMorningReminder())
          .thenAnswer((_) async {});

      // Act
      await notifier.updateMorningNotification(false);

      // Assert
      verify(mockNotificationService.cancelMorningReminder()).called(1);
      verifyNoMoreInteractions(mockNotificationService);
    });
  });
}
