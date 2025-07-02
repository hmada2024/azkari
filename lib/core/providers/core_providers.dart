// lib/core/providers/core_providers.dart
import 'package:azkari/core/services/messenger_service.dart';
import 'package:azkari/core/services/notification_service.dart';
import 'package:azkari/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());
final messengerServiceProvider = Provider<MessengerService>(
  (ref) => MessengerService(messengerKey),
);
