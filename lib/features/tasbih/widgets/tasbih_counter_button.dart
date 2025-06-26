// lib/features/tasbih/widgets/tasbih_counter_button.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
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
    final tasbihState = ref.watch(tasbihStateProvider);
    final tasbihNotifier = ref.read(tasbihStateProvider.notifier);

    return GestureDetector(
      onTap: () {
        if (tasbihState.activeTasbihId == null && tasbihList.isNotEmpty) {
          tasbihNotifier.setActiveTasbih(tasbihList.first.id);
        }
        tasbihNotifier.increment();
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: SizeConfig.screenWidth * 0.6,
        height: SizeConfig.screenWidth * 0.6,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          shape: BoxShape.circle,
          border:
              Border.all(color: theme.primaryColor.withOpacity(0.5), width: 4),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 15,
            ),
          ],
        ),
        child: Center(
          child: Text(
            tasbihState.count.toString(),
            style: TextStyle(
              fontSize: SizeConfig.getResponsiveSize(75),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
