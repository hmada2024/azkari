// lib/features/tasbih/widgets/tasbih_counter_button.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihCounterButton extends ConsumerWidget {
  final List<TasbihModel> tasbihList;
  const TasbihCounterButton({super.key, required this.tasbihList});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final count = ref.watch(tasbihStateProvider.select((s) => s.count));
    final tasbihNotifier = ref.read(tasbihStateProvider.notifier);
    return Center(
      child: GestureDetector(
        onTap: () {
          final currentTasbihState = ref.read(tasbihStateProvider);
          if (currentTasbihState.activeTasbihId == null &&
              tasbihList.isNotEmpty) {
            tasbihNotifier.setActiveTasbih(tasbihList.first.id);
          }
          tasbihNotifier.increment();
          HapticFeedback.lightImpact();
        },
        child: Container(
          width: context.screenWidth * 0.5,
          height: context.screenWidth * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDarkMode
                  ? [AppColors.accent.withOpacity(0.8), AppColors.primary]
                  : [AppColors.accent, AppColors.primary.withOpacity(0.8)],
              center: Alignment.center,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.4),
                spreadRadius: 8,
                blurRadius: 25,
              ),
              BoxShadow(
                color: isDarkMode
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                spreadRadius: 6,
                blurRadius: 15,
              ),
            ],
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: context.responsiveSize(70),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
