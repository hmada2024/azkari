// lib/features/azkar_list/screens/azkar_screen.dart
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/azkar_list/widgets/completion_counter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/azkar_list_providers.dart';
import '../widgets/azkar_card.dart';

class AzkarScreen extends ConsumerStatefulWidget {
  final String category;
  const AzkarScreen({super.key, required this.category});

  @override
  ConsumerState<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends ConsumerState<AzkarScreen> {
  late List<GlobalKey> _cardKeys;

  @override
  void initState() {
    super.initState();
    _cardKeys = [];
  }

  void _initializeKeys(int count) {
    if (_cardKeys.length != count) {
      _cardKeys = List.generate(count, (_) => GlobalKey(), growable: false);
    }
  }

  void _scrollToNext(int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex < _cardKeys.length) {
      final key = _cardKeys[nextIndex];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adhkarAsyncValue =
        ref.watch(azkarByCategoryProvider(widget.category));

    adhkarAsyncValue.whenData((adhkarList) {
      for (var i = 0; i < adhkarList.length; i++) {
        final adhkar = adhkarList[i];
        ref.listen<AzkarCardState>(azkarCardProvider(adhkar), (previous, next) {
          if (previous != null && !previous.isFinished && next.isFinished) {
            _scrollToNext(i);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
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
          onRetry: () =>
              ref.invalidate(azkarByCategoryProvider(widget.category)),
        ),
        data: (adhkarList) {
          if (adhkarList.isEmpty) {
            return const Center(
                child: Text("لا توجد أذكار في هذا التصنيف حالياً"));
          }

          _initializeKeys(adhkarList.length);

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: adhkarList.length,
            itemBuilder: (context, index) {
              final adhkar = adhkarList[index];
              return AzkarCard(
                key: _cardKeys[index],
                adhkar: adhkar,
                onFinished: () => _scrollToNext(index),
              );
            },
          );
        },
      ),
    );
  }
}
