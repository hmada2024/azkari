// lib/features/azkar_list/widgets/azkar_card.dart
import 'package:azkari/core/constants/app_text_styles.dart';
import 'package:azkari/features/settings/providers/settings_provider.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/azkar_model.dart';
import 'package:azkari/features/azkar_list/widgets/adhkar_counter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AzkarCard extends ConsumerWidget {
  final AzkarModel adhkar;
  const AzkarCard({super.key, required this.adhkar});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final double fontScale =
        ref.watch(settingsProvider.select((s) => s.fontScale));
    return Card(
      key: Key('adhkar_card_${adhkar.id}'),
      margin: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(12),
          vertical: context.responsiveSize(8)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                      color: theme.primaryColor,
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
          AdhkarCounterButton(adhkar: adhkar),
        ],
      ),
    );
  }
}