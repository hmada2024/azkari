// lib/features/favorites/favorites_provider.dart
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
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

  static const _favoritesKey = 'favorite_adhkar_ids';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    // التأكد من أن الحالة لم يتم التخلص منها
    if (mounted) {
      state = favoriteIds.map(int.parse).toList();
    }
  }

  Future<void> toggleFavorite(int adhkarId) async {
    final prefs = await SharedPreferences.getInstance();

    final currentFavorites = List<int>.from(state);

    if (currentFavorites.contains(adhkarId)) {
      currentFavorites.remove(adhkarId);
    } else {
      currentFavorites.insert(0, adhkarId);
    }

    state = currentFavorites;
    await prefs.setStringList(
        _favoritesKey, state.map((id) => id.toString()).toList());
  }
}

// --- 2. ✨✨ Provider جديد وتصريحي لإدارة قائمة الأذكار المفضلة بفعالية ✨✨ ---
// هذا الـ FutureProvider يعيد بناء نفسه تلقائياً كلما تغيرت قائمة الـ IDs
final favoriteAdhkarProvider = FutureProvider<List<AdhkarModel>>((ref) async {
  // 1. مراقبة قائمة الـ IDs. أي تغيير هنا سيؤدي إلى إعادة تنفيذ هذا الكود
  final favoriteIds = ref.watch(favoritesIdProvider);

  // 2. إذا كانت القائمة فارغة، أرجع قائمة فارغة فوراً
  if (favoriteIds.isEmpty) {
    return [];
  }

  // 3. جلب مستودع البيانات
  final repository = ref.read(adhkarRepositoryProvider);

  // 4. جلب الأذكار الكاملة من قاعدة البيانات باستخدام الـ IDs
  final adhkar = await repository.getAdhkarByIds(favoriteIds);

  // 5. إرجاع القائمة النهائية
  // الترتيب محفوظ الآن بناءً على ترتيب الـ IDs
  return adhkar;
});
