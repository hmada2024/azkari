import 'package:azkari/core/utils/size_config.dart'; // سيعمل الآن كـ extension
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
    final count = ref.watch(tasbihStateProvider.select((s) => s.count));
    final tasbihNotifier = ref.read(tasbihStateProvider.notifier);

    return GestureDetector(
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
        // [تحسين] ✨: استخدام الـ extension الجديد
        width: context.screenWidth * 0.6,
        height: context.screenWidth * 0.6,
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
            count.toString(),
            style: TextStyle(
              fontSize: context.responsiveSize(75), // [تحسين] ✨
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
