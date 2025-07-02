// lib/features/goal_management/widgets/goal_management_dialogs.dart

import 'package:azkari/core/providers/core_providers.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        // ✨ [الإصلاح] استخدام Consumer للوصول إلى ref
        Consumer(
          builder: (context, ref, child) {
            return FilledButton(
              onPressed: () async {
                final text = controller.text;
                final count = int.tryParse(text);

                // ✨ [جديد] التحقق من صحة الرقم المدخل
                // إذا كان النص غير فارغ ولكنه ليس رقمًا صحيحًا أو أنه رقم سالب.
                if (text.isNotEmpty && (count == null || count < 0)) {
                  ref
                      .read(messengerServiceProvider)
                      .showErrorSnackBar("الرجاء إدخال رقم صحيح.");
                  return; // إيقاف التنفيذ وعدم إغلاق النافذة
                }

                // إذا كان النص فارغًا أو 0، سيعتبر الهدف 0
                final finalCount = count ?? 0;
                final notifier = ref.read(goalManagementStateProvider.notifier);

                // استدعاء الدالة وانتظار النتيجة
                final success =
                    await notifier.setGoal(item.tasbih.id, finalCount);

                // إغلاق النافذة فقط في حالة النجاح
                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            );
          },
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
        Consumer(
          builder: (context, ref, child) {
            return FilledButton(
              onPressed: () async {
                final text = controller.text.trim();
                final notifier = ref.read(goalManagementStateProvider.notifier);

                // ✨ [الإصلاح] استدعاء الدالة وانتظار النتيجة (true أو false)
                final success = await notifier.addTasbih(text);

                // إغلاق النافذة فقط في حالة النج-اح
                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إضافة'),
            );
          },
        ),
      ],
    ),
  );
}
