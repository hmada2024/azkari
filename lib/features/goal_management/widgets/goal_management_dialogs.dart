// lib/features/goal_management/widgets/goal_management_dialogs.dart

import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:flutter/material.dart';

/// يعرض نافذة منبثقة لتعديل الهدف اليومي لذكر معين.
Future<void> showEditGoalDialog(BuildContext context,
    GoalManagementNotifier notifier, GoalManagementItem item) async {
  final controller = TextEditingController(
      text: item.targetCount > 0 ? item.targetCount.toString() : '');

  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('تحديد الهدف لـ "${item.tasbih.displayName}"'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
            labelText: 'العدد اليومي', hintText: 'أدخل 0 لإلغاء الهدف'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () async {
            final count = int.tryParse(controller.text) ?? 0;
            await notifier.setGoal(item.tasbih.id, count);
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
}

/// يعرض نافذة منبثقة لإضافة ذكر (تسبيح) جديد.
Future<void> showAddTasbihDialog(
    BuildContext context, GoalManagementNotifier notifier) async {
  final controller = TextEditingController();

  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('إضافة ذكر جديد'),
      content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'اكتب الذكر هنا...')),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () async {
            if (controller.text.trim().isNotEmpty) {
              await notifier.addTasbih(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
          child: const Text('إضافة'),
        ),
      ],
    ),
  );
}
