// lib/features/prayer_times/data/repositories/prayer_settings_repository.dart
import 'package:adhan/adhan.dart';
import 'package:azkari/core/providers/core_providers.dart';
import 'package:azkari/features/prayer_times/data/models/prayer_settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerSettingsRepository {
  final SharedPreferences _prefs;
  PrayerSettingsRepository(this._prefs);

  static const _latitudeKey = 'prayer_latitude';
  static const _longitudeKey = 'prayer_longitude';

  Future<void> saveSettings(double latitude, double longitude) async {
    await _prefs.setDouble(_latitudeKey, latitude);
    await _prefs.setDouble(_longitudeKey, longitude);
  }

  PrayerSettingsModel? getSettings() {
    final latitude = _prefs.getDouble(_latitudeKey);
    final longitude = _prefs.getDouble(_longitudeKey);

    if (latitude != null && longitude != null) {
      return PrayerSettingsModel(
        latitude: latitude,
        longitude: longitude,
        calculationMethod: CalculationMethod.egyptian,
      );
    }
    return null;
  }
}

final prayerSettingsRepositoryProvider =
    FutureProvider<PrayerSettingsRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return PrayerSettingsRepository(prefs);
});
