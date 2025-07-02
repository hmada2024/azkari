// lib/features/azkar_list/azkar_screen.dart
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/azkar_list/widgets/completion_counter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/azkar_list_providers.dart';
import '../widgets/azkar_card.dart';

class AzkarScreen extends ConsumerWidget {
  final String category;
  const AzkarScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhkarAsyncValue = ref.watch(azkarByCategoryProvider(category));
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: [
          adhkarAsyncValue.maybeWhen(
            data: (adhkarList) {
              if (adhkarList.isEmpty) return const SizedBox.shrink();
              int completedCount = 0;
              for (var adhkar in adhkarList) {
                final cardState = ref.watch(azkarCardProvider(adhkar));
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
        loading: () => Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor)),
        error: (error, stack) => CustomErrorWidget(
          errorMessage: error.toString(),
          onRetry: () => ref.invalidate(azkarByCategoryProvider(category)),
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
