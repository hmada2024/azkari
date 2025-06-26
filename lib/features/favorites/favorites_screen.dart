// lib/features/favorites/favorites_screen.dart
import 'package:azkari/features/adhkar_list/widgets/adhkar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'favorites_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  // ✨ تحويل إلى StatefulWidget
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // ✨ جلب البيانات مرة واحدة عند فتح الشاشة
    Future.microtask(
        () => ref.read(favoriteAdhkarProvider.notifier).fetchFavoriteAdhkar());
  }

  @override
  Widget build(BuildContext context) {
    final favoriteAdhkarAsync = ref.watch(favoriteAdhkarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: favoriteAdhkarAsync.when(
        // ... باقي الكود يبقى كما هو بدون تغيير
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
        data: (adhkarList) {
          if (adhkarList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لم تقم بإضافة أي ذكر إلى المفضلة بعد',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: adhkarList.length,
            itemBuilder: (context, index) {
              final adhkar = adhkarList[index];
              return AdhkarCard(adhkar: adhkar);
            },
          );
        },
      ),
    );
  }
}
