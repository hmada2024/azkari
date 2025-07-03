// lib/features/azkar_list/widgets/azkar_card.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/constants/app_text_styles.dart';
import 'package:azkari/features/settings/providers/settings_provider.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/azkar_model.dart';
import 'package:azkari/features/azkar_list/widgets/azkar_counter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AzkarCard extends ConsumerWidget {
  final AzkarModel adhkar;
  final VoidCallback onFinished;

  const AzkarCard({
    super.key,
    required this.adhkar,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final double fontScale =
        ref.watch(settingsProvider.select((s) => s.fontScale));
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(12),
          vertical: context.responsiveSize(8)),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? AppColors.cardGradientDark
            : AppColors.cardGradientLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                context.responsiveSize(16),
                context.responsiveSize(16),
                context.responsiveSize(16),
                context.responsiveSize(8)),
            child: Text(
              adhkar.text,
              textAlign: TextAlign.right,
              style: AppTextStyles.amiri.copyWith(
                fontSize: context.responsiveSize(20) * fontScale,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          if ((adhkar.virtue != null && adhkar.virtue!.isNotEmpty) ||
              (adhkar.note != null && adhkar.note!.isNotEmpty))
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(16.0)),
                title: Text(
                  "فضل الذكر",
                  style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: context.responsiveSize(14)),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        context.responsiveSize(16.0),
                        0,
                        context.responsiveSize(16.0),
                        context.responsiveSize(8.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (adhkar.virtue != null && adhkar.virtue!.isNotEmpty)
                          Text(adhkar.virtue!,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                  fontStyle: FontStyle.italic)),
                        if (adhkar.note != null && adhkar.note!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                                top: context.responsiveSize(8.0)),
                            child: Text(adhkar.note!,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: context.responsiveSize(8)),
          AdhkarCounterButton(adhkar: adhkar, onFinished: onFinished),
        ],
      ),
    );
  }
}
