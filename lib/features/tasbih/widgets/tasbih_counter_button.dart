// lib/features/tasbih/widgets/tasbih_counter_button.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/progress_ring_painter.dart';
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
    final activeId =
        ref.watch(tasbihStateProvider.select((s) => s.activeTasbihId));
    final tasbihNotifier = ref.read(tasbihStateProvider.notifier);

    final goals = ref.watch(dailyGoalsStateProvider).goals.valueOrNull ?? [];
    final activeGoal = goals.firstWhere(
      (g) => g.tasbihId == activeId,
      orElse: () => DailyGoalModel(
          tasbihId: -1, tasbihText: '', targetCount: 0, currentProgress: 0),
    );

    final double progress = (activeGoal.targetCount > 0)
        ? (count / activeGoal.targetCount).clamp(0.0, 1.0)
        : 0.0;
    final bool isCompleted = progress >= 1.0;
    final double buttonSize = context.screenWidth * 0.5;
    const double strokeWidth = 8.0;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ProgressRingPainter(
                progress: progress,
                trackColor: theme.dividerColor.withOpacity(0.5),
                progressColor: isCompleted
                    ? AppColors.success
                    : theme.colorScheme.secondary.withOpacity(0.9),
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (activeId == null && tasbihList.isNotEmpty) {
                tasbihNotifier.setActiveTasbih(tasbihList.first.id);
              }
              tasbihNotifier.increment();
              HapticFeedback.lightImpact();
            },
            child: Container(
              width: buttonSize - (strokeWidth * 2),
              height: buttonSize - (strokeWidth * 2),
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
        ],
      ),
    );
  }
}
