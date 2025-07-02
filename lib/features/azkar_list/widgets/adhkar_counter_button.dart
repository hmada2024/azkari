// lib/features/azkar_list/widgets/adhkar_counter_button.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/azkar_model.dart';
import 'package:azkari/features/azkar_list/providers/azkar_card_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdhkarCounterButton extends ConsumerWidget {
  final AzkarModel adhkar;
  const AdhkarCounterButton({
    super.key,
    required this.adhkar,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(azkarCardProvider(adhkar));
    final cardNotifier = ref.read(azkarCardProvider(adhkar).notifier);
    final bool isFinished = cardState.isFinished;
    final double progress = cardState.progress;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(context.responsiveSize(16.0)),
      child: GestureDetector(
        onTap:
            isFinished ? cardNotifier.resetCount : cardNotifier.decrementCount,
        child: Container(
          height: context.responsiveSize(55),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: theme.scaffoldBackgroundColor,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: isFinished ? 1.0 : progress,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: isFinished
                          ? AppColors.success.withOpacity(0.7)
                          : theme.primaryColor.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isFinished
                    ? Icon(
                        Icons.replay,
                        key: const ValueKey('replay_icon'),
                        color: Colors.white,
                        size: context.responsiveSize(30),
                      )
                    : Text(
                        cardState.currentCount.toString(),
                        key: ValueKey('count_text_${cardState.currentCount}'),
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: context.responsiveSize(22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
