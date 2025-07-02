// lib/core/services/messenger_service.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// خدمة مركزية لإدارة وعرض جميع رسائل المستخدم (SnackBars).
/// تضمن هذه الخدمة تجربة مستخدم متسقة وتزيل تكرار الكود.
class MessengerService {
  final GlobalKey<ScaffoldMessengerState> _messengerKey;

  MessengerService(this._messengerKey);

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // التأكد من أن المفتاح لديه حالة حالية قبل محاولة عرض أي شيء
    if (_messengerKey.currentState == null) {
      return;
    }

    // إخفاء أي SnackBar حالي لتجنب التراكم
    _messengerKey.currentState!.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );

    _messengerKey.currentState!.showSnackBar(snackBar);
  }

  /// يعرض SnackBar للإشارة إلى نجاح عملية ما.
  void showSuccessSnackBar(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  /// يعرض SnackBar للإشارة إلى حدوث خطأ.
  void showErrorSnackBar(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  /// يعرض SnackBar لعرض معلومات عامة.
  void showInfoSnackBar(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      icon: Icons.info_outline,
    );
  }
}
