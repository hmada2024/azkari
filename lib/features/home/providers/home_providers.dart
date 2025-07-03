// lib/features/home/providers/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeOfDayPeriod { morning, evening, none }

final timeOfDayProvider = Provider<TimeOfDayPeriod>((ref) {
  final hour = DateTime.now().hour;
  // From 4:00 AM to 11:59 AM
  if (hour >= 4 && hour < 12) {
    return TimeOfDayPeriod.morning;
  }
  // From 3:00 PM (15:00) to 8:59 PM (20:59)
  if (hour >= 15 && hour < 21) {
    return TimeOfDayPeriod.evening;
  }
  return TimeOfDayPeriod.none;
});
