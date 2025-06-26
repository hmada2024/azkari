// lib/features/favorites/favorites_provider.dart
import 'dart:async';
import 'package:azkari/core/constants/app_constants.dart';
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesIdProvider =
    StateNotifierProvider<FavoritesIdNotifier, List<int>>((ref) {
  return FavoritesIdNotifier();
});

class FavoritesIdNotifier extends StateNotifier<List<int>> {
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationComplete => _initCompleter.future;

  FavoritesIdNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(AppConstants.favoritesKey) ?? [];
      if (mounted) {
        state = favoriteIds.map(int.parse).toList();
      }
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
    }
  }

  Future<void> toggleFavorite(int adhkarId) async {
    await _initCompleter.future;

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
