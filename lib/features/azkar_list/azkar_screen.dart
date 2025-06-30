// lib/features/adhkar_list/adhkar_screen.dart
import 'package:azkari/features/azkar_list/widgets/completion_counter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'azkar_providers.dart';
import 'widgets/azkar_card.dart';

class AzkarScreen extends ConsumerWidget {
  final String category;

  const AzkarScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhkarAsyncValue = ref.watch(azkarByCategoryProvider(category));

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        // ✨ [جديد] إضافة عداد الإكمال في شريط العنوان
        actions: [
          // نعرض العداد فقط عند اكتمال تحميل البيانات
          adhkarAsyncValue.maybeWhen(
            data: (adhkarList) {
              if (adhkarList.isEmpty) return const SizedBox.shrink();

              // حساب عدد الأذكار المكتملة
              int completedCount = 0;
              for (var adhkar in adhkarList) {
                // نراقب حالة كل بطاقة ذكر
                final cardState = ref.watch(adhkarCardProvider(adhkar));
                if (cardState.isFinished) {
                  completedCount++;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                child: Center(
                  child: CompletionCounterChip(
                    completed: completedCount,
                    total: adhkarList.length,
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: adhkarAsyncValue.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
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
            return const Center(
                child: Text("لا توجد أذكار في هذا التصنيف حالياً"));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: adhkarList.length,
            itemBuilder: (context, index) {
              final adhkar = adhkarList[index];
              return AzkarCard(adhkar: adhkar);
            },
          );
        },
      ),
    );
  }
}
