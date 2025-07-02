// lib/features/goal_management/widgets/goal_item_card.dart

import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:flutter/material.dart';

/// ✨ [مُعاد تصميمه بالكامل]
/// ويدجت يمثل بطاقة عرض عنصر واحد في شاشة إدارة الأهداف.
/// يدعم السحب للحذف (للأذكار المخصصة) والسحب لإعادة الترتيب.
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

    // محتوى البطاقة الداخلي الذي سيكون مشتركاً
    final cardContent = Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Row(
            children: [
              // مقبض السحب لإعادة الترتيب
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.drag_handle_rounded),
                ),
              ),
              // نص الذكر
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
              // عدد الهدف
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

    // ✨ [جديد] تطبيق ويدجت الحذف فقط إذا كان الذكر قابلاً للحذف
    if (item.tasbih.isDeletable) {
      return Dismissible(
        key: ValueKey('dismissible_${item.tasbih.id}'),
        // الخلفية التي تظهر عند السحب
        background: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
        ),
        // اتجاه السحب (من البداية للنهاية، أي من اليسار لليمين في العربية)
        direction: DismissDirection.startToEnd,
        // الإجراء الذي يتم عند اكتمال السحب
        onDismissed: (_) => notifier.deleteTasbih(item.tasbih.id),
        child: cardContent,
      );
    }

    // إذا لم يكن قابلاً للحذف، يتم عرض البطاقة العادية فقط
    return cardContent;
  }
}
