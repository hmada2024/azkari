import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'adhkar_providers.dart';
import 'widgets/adhkar_card.dart';

// تم تحديث الويدجت ليصبح stateful widget لتتمكن من استخدام الـ Provider
class AdhkarScreen extends ConsumerWidget {
  // متغير لتمرير التصنيف المطلوب
  final String category;

  const AdhkarScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام المتغير category لجلب البيانات الصحيحة
    final adhkarAsyncValue = ref.watch(adhkarByCategoryProvider(category));

    return Scaffold(
      appBar: AppBar(
        // عرض اسم التصنيف في شريط العنوان
        title: Text(category),
      ),
      body: adhkarAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.teal)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'حدث خطأ أثناء تحميل الأذكار:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (adhkarList) {
          if (adhkarList.isEmpty) {
            return const Center(child: Text("لا توجد أذكار في هذا التصنيف حالياً"));
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