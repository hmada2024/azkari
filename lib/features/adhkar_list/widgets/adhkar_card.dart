// lib/features/adhkar_list/widgets/adhkar_card.dart
import 'package:azkari/core/providers/settings_provider.dart';
import 'package:azkari/core/utils/size_config.dart'; // سيعمل الآن كـ extension
import 'package:azkari/features/favorites/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdhkarCard extends ConsumerStatefulWidget {
  final AdhkarModel adhkar;

  const AdhkarCard({super.key, required this.adhkar});

  @override
  ConsumerState<AdhkarCard> createState() => _AdhkarCardState();
}

class _AdhkarCardState extends ConsumerState<AdhkarCard> {
  late int _currentCount;
  late int _initialCount;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.adhkar.count;
    _initialCount = widget.adhkar.count > 0 ? widget.adhkar.count : 1;
  }

  // [تحسين] ✨: عند تغيير الذكر في الواجهة، يجب تحديث الحالة
  @override
  void didUpdateWidget(covariant AdhkarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.adhkar.id != oldWidget.adhkar.id) {
      _currentCount = widget.adhkar.count;
      _initialCount = widget.adhkar.count > 0 ? widget.adhkar.count : 1;
    }
  }

  void _decrementCount() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _resetCount() {
    setState(() {
      _currentCount = _initialCount;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinished = _currentCount == 0;
    final theme = Theme.of(context);
    final double progress = (_initialCount - _currentCount) / _initialCount;
    final double fontScale =
        ref.watch(settingsProvider.select((s) => s.fontScale));

    final favoriteIds = ref.watch(favoritesIdProvider);
    final isFavorite = favoriteIds.contains(widget.adhkar.id);

    return Card(
      // ✅✅✅ هذا هو التعديل المطلوب: إضافة Key فريد ✅✅✅
      key: Key('adhkar_card_${widget.adhkar.id}'),
      margin: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(12),
          vertical: context.responsiveSize(8)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.responsiveSize(16),
                    context.responsiveSize(16),
                    context.responsiveSize(48),
                    context.responsiveSize(8)),
                child: Text(
                  widget.adhkar.text,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: context.responsiveSize(20) * fontScale,
                    height: 1.8,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if ((widget.adhkar.virtue != null &&
                      widget.adhkar.virtue!.isNotEmpty) ||
                  (widget.adhkar.note != null &&
                      widget.adhkar.note!.isNotEmpty))
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
                            if (widget.adhkar.virtue != null &&
                                widget.adhkar.virtue!.isNotEmpty)
                              Text(widget.adhkar.virtue!,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic)),
                            if (widget.adhkar.note != null &&
                                widget.adhkar.note!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    top: context.responsiveSize(8.0)),
                                child: Text(widget.adhkar.note!,
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
                  onTap: isFinished ? _resetCount : _decrementCount,
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
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: isFinished
                              ? Icon(
                                  Icons.replay,
                                  key: const ValueKey('replay_icon'),
                                  color: Colors.white,
                                  size: context.responsiveSize(30),
                                )
                              : Text(
                                  _currentCount.toString(),
                                  key: ValueKey('count_text_$_currentCount'),
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
          Positioned(
            top: 4,
            left: 4,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber[600] : Colors.grey,
              ),
              onPressed: () {
                ref
                    .read(favoritesIdProvider.notifier)
                    .toggleFavorite(widget.adhkar.id);
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }
}
