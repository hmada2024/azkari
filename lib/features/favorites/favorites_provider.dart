// lib/features/favorites/favorites_provider.dart
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesIdProvider =
    StateNotifierProvider<FavoritesIdNotifier, List<int>>((ref) {
  return FavoritesIdNotifier();
});

class FavoritesIdNotifier extends StateNotifier<List<int>> {
  FavoritesIdNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(AppConstants.favoritesKey) ?? [];
    if (mounted) {
      state = favoriteIds.map(int.parse).toList();
    }
  }

  // ✨ [تحسين]: جعل عملية التبديل أكثر قوة (Robust) باستخدام try-catch.
  // يتم الآن تحديث الواجهة بشكل متفائل (Optimistic Update) أولاً، ثم محاولة الحفظ.
  // في حالة فشل الحفظ، نعود إلى الحالة السابقة لضمان تزامن البيانات ومنع الأخطاء.
  Future<void> toggleFavorite(int adhkarId) async {
    final previousState = state;

    final currentFavorites = List<int>.from(state);

    if (currentFavorites.contains(adhkarId)) {
      currentFavorites.remove(adhkarId);
    } else {
      currentFavorites.insert(0, adhkarId);
    }
    state = currentFavorites;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        AppConstants.favoritesKey,
        state.map((id) => id.toString()).toList(),
      );
      // ✨ [تحسين]: إضافة اهتزاز خفيف (Haptic Feedback) لتأكيد نجاح العملية.
      HapticFeedback.lightImpact();
    } catch (e) {
      // في حالة الفشل، أرجع الحالة إلى ما كانت عليه.
      state = previousState;
      // يمكنك هنا إظهار رسالة خطأ للمستخدم إذا أردت.
      debugPrint("Failed to save favorites: $e");
    }
  }
}

final favoriteAdhkarProvider = FutureProvider<List<AdhkarModel>>((ref) async {
  final favoriteIds = ref.watch(favoritesIdProvider);

  if (favoriteIds.isEmpty) {
    return [];
  }

  final repository = ref.read(adhkarRepositoryProvider);
  final adhkar = await repository.getAdhkarByIds(favoriteIds);

  return adhkar;
});
