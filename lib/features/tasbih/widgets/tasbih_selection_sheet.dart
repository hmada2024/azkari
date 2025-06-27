// lib/features/tasbih/widgets/tasbih_selection_sheet.dart
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihSelectionSheet extends ConsumerWidget {
  const TasbihSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihList = ref.watch(tasbihListProvider).asData?.value ?? [];
    final usedTodayIds =
        ref.watch(tasbihStateProvider.select((s) => s.usedTodayIds));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('اختر من قائمة التسابيح',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'إضافة ذكر جديد',
                      onPressed: () {
                        _showAddTasbihDialog(context, ref);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tasbihList.length,
                  itemBuilder: (context, index) {
                    final tasbih = tasbihList[index];
                    final wasUsedToday = usedTodayIds.contains(tasbih.id);
                    return ListTile(
                      title: Text(tasbih.text,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (wasUsedToday)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                          if (wasUsedToday && tasbih.isDeletable)
                            const SizedBox(width: 8),
                          if (tasbih.isDeletable)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red.shade400),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, ref, tasbih);
                              },
                            ),
                        ],
                      ),
                      onTap: () {
                        ref
                            .read(tasbihStateProvider.notifier)
                            .setActiveTasbih(tasbih.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTasbihDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final tasbihNotifier = ref.read(tasbihStateProvider.notifier);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة ذكر جديد'),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: 'الصق أو اكتب الذكر هنا...'),
            maxLines: 5,
            minLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FilledButton(
              child: const Text('إضافة'),
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  // ✨ [الإصلاح]: التقط الـ Navigator و Messenger قبل الـ await
                  final navigator = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);
                  final textToAdd = controller.text.trim();

                  await tasbihNotifier.addTasbih(textToAdd);

                  // استخدم النسخ الملتقطة بعد الـ await
                  if (!context.mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('تمت الإضافة بنجاح'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  navigator.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, TasbihModel tasbih) {
    final tasbihNotifier = ref.read(tasbihStateProvider.notifier);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content:
              Text('هل أنت متأكد من رغبتك في حذف "${tasbih.text}" بشكل نهائي؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('حذف'),
              onPressed: () async {
                // ✨ [الإصلاح]: التقط الـ Navigator و Messenger قبل الـ await
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final idToDelete = tasbih.id;

                await tasbihNotifier.deleteTasbih(idToDelete);

                // استخدم النسخ الملتقطة بعد الـ await
                if (!context.mounted) return;

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم الحذف بنجاح'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );

                navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
