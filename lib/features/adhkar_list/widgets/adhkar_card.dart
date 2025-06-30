// lib/features/adhkar_list/widgets/adhkar_card.dart
import 'package:azkari/core/providers/settings_provider.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/features/adhkar_list/providers/adhkar_card_provider.dart'; // <-- استيراد جديد
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdhkarCard extends ConsumerWidget {
  final AdhkarModel adhkar;

  const AdhkarCard({super.key, required this.adhkar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✨ مشاهدة الحالة من الـ Notifier الخاص بهذه البطاقة
    final cardState = ref.watch(adhkarCardProvider(adhkar));
    // ✨ الوصول للـ Notifier لتنفيذ الأوامر
    final cardNotifier = ref.read(adhkarCardProvider(adhkar).notifier);

    final bool isFinished = cardState.isFinished;
    final theme = Theme.of(context);
    final double progress = cardState.progress;
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
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: context.responsiveSize(20) * fontScale,
                height: 1.8,
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
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic)),
                        if (adhkar.note != null && adhkar.note!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                                top: context.responsiveSize(8.0)),
                            child: Text(adhkar.note!,
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.grey[700])),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: context.responsiveSize(8)),
          Padding(
            padding: EdgeInsets.all(context.responsiveSize(16.0)),
            child: GestureDetector(
              // ✨ تم تبسيط المنطق هنا بشكل كبير
              onTap: isFinished
                  ? cardNotifier.resetCount
                  : cardNotifier.decrementCount,
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
                                ? Colors.green.withOpacity(0.7)
                                : Colors.teal.withOpacity(0.4),
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
                              // ✨ أصبح يقرأ من الحالة الجديدة
                              cardState.currentCount.toString(),
                              key: ValueKey(
                                  'count_text_${cardState.currentCount}'),
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
          ),
        ],
      ),
    );
  }
}
