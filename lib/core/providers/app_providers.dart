// lib/core/providers/app_providers.dart

import 'package:azkari/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [جديد] Provider لخدمة الإشعارات، سيكون Singleton في التطبيق كله.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});