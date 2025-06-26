// lib/features/favorites/favorites_provider.dart
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- 1. Provider لإدارة IDs المفضلة (يبقى كما هو) ---
final favoritesIdProvider =
    StateNotifierProvider<FavoritesIdNotifier, List<int>>((ref) {
  return FavoritesIdNotifier();
});

class FavoritesIdNotifier extends StateNotifier<List<int>> {
  FavoritesIdNotifier() : super([]) {
    _loadFavorites();
  }

  static const _favoritesKey = 'favorite_adhkar_ids';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    state = favoriteIds.map(int.parse).toList();
  }

  Future<void> toggleFavorite(int adhkarId) async {
    final prefs = await SharedPreferences.getInstance();
    // نستخدم Set للتحقق من الوجود بشكل أسرع
    final currentFavoritesSet = Set<int>.from(state);

    if (currentFavoritesSet.contains(adhkarId)) {
      currentFavoritesSet.remove(adhkarId);
    } else {
      currentFavoritesSet.add(adhkarId);
    }

    // الترتيب غير مهم في الـ Set، لذا نحول إلى List
    state = currentFavoritesSet.toList();
    await prefs.setStringList(
        _favoritesKey, state.map((id) => id.toString()).toList());
  }
}

// --- 2. Provider جديد لإدارة قائمة بيانات الأذكار المفضلة بفعالية (الأهم) ---
final favoriteAdhkarProvider = StateNotifierProvider<FavoriteAdhkarNotifier,
    AsyncValue<List<AdhkarModel>>>((ref) {
  return FavoriteAdhkarNotifier(ref);
});

class FavoriteAdhkarNotifier
    extends StateNotifier<AsyncValue<List<AdhkarModel>>> {
  FavoriteAdhkarNotifier(this._ref) : super(const AsyncValue.loading()) {
    // الاستماع لأي تغيير في قائمة الـ IDs لإعادة المزامنة إذا لزم الأمر
    _ref.listen<List<int>>(favoritesIdProvider, (previous, next) {
      // إذا تغيرت القائمة من الخارج، أعد تحميلها
      // هذا يضمن المزامنة إذا تم التغيير من شاشة أخرى
      fetchFavoriteAdhkar();
    });
  }

  final Ref _ref;

  Future<void> fetchFavoriteAdhkar() async {
    state = const AsyncValue.loading();
    try {
      final favoriteIds = _ref.read(favoritesIdProvider);
      if (favoriteIds.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }
      final repository = _ref.read(adhkarRepositoryProvider);
      final adhkar = await repository.getAdhkarByIds(favoriteIds);
      state = AsyncValue.data(adhkar);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // دالة لإزالة ذكر من المفضلة (تحديث فوري للواجهة)
  Future<void> removeFavorite(int adhkarId) async {
    // 1. تحديث قائمة الـ IDs في SharedPreferences
    await _ref.read(favoritesIdProvider.notifier).toggleFavorite(adhkarId);

    // 2. تحديث الواجهة فوراً بدون إعادة جلب من قاعدة البيانات
    state.whenData((adhkarList) {
      final newList =
          adhkarList.where((adhkar) => adhkar.id != adhkarId).toList();
      state = AsyncValue.data(newList);
    });
  }
}
