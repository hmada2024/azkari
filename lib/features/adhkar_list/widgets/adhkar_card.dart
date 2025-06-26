import 'package:azkari/core/providers/settings_provider.dart';
import 'package:azkari/core/utils/size_config.dart';
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

  void _decrementCount() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
      HapticFeedback.lightImpact();
    }
  }

  // ✨ دالة جديدة لإعادة العداد
  void _resetCount() {
    setState(() {
      _currentCount = _initialCount;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final bool isFinished = _currentCount == 0;
    final theme = Theme.of(context);
    final double progress = (_initialCount - _currentCount) / _initialCount;
    final double fontScale =
        ref.watch(settingsProvider.select((s) => s.fontScale));

    final favoriteIds = ref.watch(favoritesIdProvider);
    final isFavorite = favoriteIds.contains(widget.adhkar.id);

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.getResponsiveSize(12),
          vertical: SizeConfig.getResponsiveSize(8)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                // استخدام قيم متجاوبة
                padding: EdgeInsets.fromLTRB(
                    SizeConfig.getResponsiveSize(16),
                    SizeConfig.getResponsiveSize(16),
                    SizeConfig.getResponsiveSize(48), // مساحة لزر المفضلة
                    SizeConfig.getResponsiveSize(8)),
                child: Text(
                  widget.adhkar.text,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    // استخدام قيم متجاوبة مع مضاعف حجم الخط من الإعدادات
                    fontSize: SizeConfig.getResponsiveSize(20) * fontScale,
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
                        horizontal: SizeConfig.getResponsiveSize(16.0)),
                    title: Text(
                      "الفضل والملاحظات",
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: SizeConfig.getResponsiveSize(14)),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            SizeConfig.getResponsiveSize(16.0),
                            0,
                            SizeConfig.getResponsiveSize(16.0),
                            SizeConfig.getResponsiveSize(8.0)),
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
                                    top: SizeConfig.getResponsiveSize(8.0)),
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
              SizedBox(height: SizeConfig.getResponsiveSize(8)),
              Padding(
                padding: EdgeInsets.all(SizeConfig.getResponsiveSize(16.0)),
                child: GestureDetector(
                  // ✨ تغيير الوظيفة بناءً على حالة العداد
                  onTap: isFinished ? _resetCount : _decrementCount,
                  child: Container(
                    height: SizeConfig.getResponsiveSize(55),
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
                            widthFactor: isFinished
                                ? 1.0
                                : progress, // ✨ تعبئة كاملة عند الانتهاء
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
                        // ✨ عرض أيقونة إعادة أو النص
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
                                  size: SizeConfig.getResponsiveSize(30),
                                )
                              : Text(
                                  _currentCount.toString(),
                                  key: ValueKey('count_text_$_currentCount'),
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontSize: SizeConfig.getResponsiveSize(22),
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
          // زر المفضلة
          Positioned(
            top: 4,
            left: 4,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber[600] : Colors.grey,
              ),
              onPressed: () {
                // استدعاء الـ Notifier الصحيح لإدارة IDs المفضلة
                ref
                    .read(favoritesIdProvider.notifier)
                    .toggleFavorite(widget.adhkar.id);

                // إذا قام المستخدم بإلغاء التفضيل من شاشة المفضلة،
                // سيتم تحديث القائمة تلقائيًا بفضل الـ Notifier الجديد.
                // لم نعد بحاجة إلى منطق التحقق من الشاشة هنا.
              },
            ),
          ),
        ],
      ),
    );
  }
}
