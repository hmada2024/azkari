// lib/features/goal_management/widgets/management_dialogs.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_management_provider.dart';

/// يعرض نافذة منبثقة بسيطة لتأكيد الحذف.
Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required String tasbihName,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل أنت متأكد من رغبتك في حذف "$tasbihName"؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(ctx).pop();
          },
          child: const Text('حذف'),
        ),
      ],
    ),
  );
}

/// يعرض نافذة منبثقة لإضافة ذكر (تسبيح) جديد.
Future<void> showAddTasbihDialog(BuildContext context) async {
  final controller = TextEditingController();

  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('إضافة ذكر جديد'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'اكتب الذكر هنا...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('إلغاء'),
        ),
        Consumer(
          builder: (context, ref, child) {
            return FilledButton(
              onPressed: () async {
                final text = controller.text.trim();
                final notifier = ref.read(goalManagementStateProvider.notifier);
                final success = await notifier.addTasbih(text);
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
