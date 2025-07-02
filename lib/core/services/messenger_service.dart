// lib/core/services/messenger_service.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
class MessengerService {
  final GlobalKey<ScaffoldMessengerState> _messengerKey;
  MessengerService(this._messengerKey);
  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    if (_messengerKey.currentState == null) {
      return;
    }
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
  void showSuccessSnackBar(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }
  void showErrorSnackBar(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
    );
  }
  void showInfoSnackBar(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      icon: Icons.info_outline,
    );
  }
}