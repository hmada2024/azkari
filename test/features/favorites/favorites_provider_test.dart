// test/features/favorites/favorites_provider_test.dart

import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/features/favorites/favorites_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesIdNotifier Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state is an empty list when SharedPreferences is empty',
        () async {
      final container = ProviderContainer();
      // ✨ التصحيح: انتظار التهيئة باستخدام future الذي أضفناه
      await container.read(favoritesIdProvider.notifier).initializationComplete;

      expect(container.read(favoritesIdProvider), isEmpty);
      addTearDown(container.dispose);
    });

    test('Loads favorite IDs from SharedPreferences on initialization',
        () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.favoritesKey: ['3', '1']
      });

      final container = ProviderContainer();
      // ✨ التصحيح
      await container.read(favoritesIdProvider.notifier).initializationComplete;

      expect(container.read(favoritesIdProvider), [3, 1]);
      addTearDown(container.dispose);
    });

    test('toggleFavorite adds ID to the beginning of the list', () async {
      final container = ProviderContainer();
      // ✨ التصحيح
      await container.read(favoritesIdProvider.notifier).initializationComplete;

      await container.read(favoritesIdProvider.notifier).toggleFavorite(10);
      await container.read(favoritesIdProvider.notifier).toggleFavorite(20);

      expect(container.read(favoritesIdProvider), [20, 10]);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(AppConstants.favoritesKey), ['20', '10']);
      addTearDown(container.dispose);
    });

    test('toggleFavorite removes an existing ID from the list', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.favoritesKey: ['20', '10']
      });
      final container = ProviderContainer();
      // ✨ التصحيح
      await container.read(favoritesIdProvider.notifier).initializationComplete;

      await container.read(favoritesIdProvider.notifier).toggleFavorite(10);

      expect(container.read(favoritesIdProvider), [20]);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(AppConstants.favoritesKey), ['20']);
      addTearDown(container.dispose);
    });
  });
}
