// lib/features/prayer_times/data/models/prayer_settings_model.dart
import 'package:adhan/adhan.dart';

class PrayerSettingsModel {
  final double latitude;
  final double longitude;
  final CalculationMethod calculationMethod;

  PrayerSettingsModel({
    required this.latitude,
    required this.longitude,
    required this.calculationMethod,
  });
}
