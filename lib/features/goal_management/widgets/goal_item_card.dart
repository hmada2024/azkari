// lib/features/goal_management/widgets/goal_item_card.dart

import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:flutter/material.dart';

/// ويدجت يمثل بطاقة عرض عنصر واحد في شاشة إدارة الأهداف.
/// يدعم السحب للحذف والسحب لإعادة الترتيب.
class GoalItemCard extends StatelessWidget {
  final GoalManagementItem item;
  final int index;
  final GoalManagementNotifier notifier;
  final VoidCallback onTap;

  const GoalItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.notifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardContent = Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.drag_handle),
                ),
              ),
              Expanded(
                child: Text(
                  item.tasbih.displayName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: context.responsiveSize(16)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                item.targetCount > 0 ? '${item.targetCount} مرة' : 'غير محدد',
                style: TextStyle(
                  color: item.targetCount > 0
                      ? theme.primaryColor
                      : theme.disabledColor,
                  fontWeight: FontWeight.bold,
                  fontSize: context.responsiveSize(14),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );

    if (item.tasbih.isDeletable) {
      return Dismissible(
        key: ValueKey('dismissible_${item.tasbih.id}'),
        background: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => notifier.deleteTasbih(item.tasbih.id),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
