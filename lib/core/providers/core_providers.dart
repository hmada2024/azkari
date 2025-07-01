// lib/core/providers/core_providers.dart

import 'package:azkari/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider لخدمة الإشعارات، سيكون Singleton في التطبيق كله.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider لـ SharedPreferences، لتوفير نسخة واحدة على مستوى التطبيق.
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());
