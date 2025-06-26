// lib/features/tasbih/widgets/tasbih_selection_sheet.dart
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihSelectionSheet extends ConsumerWidget {
  const TasbihSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // جلب البيانات اللازمة مباشرة هنا
    final tasbihList = ref.watch(tasbihListProvider).asData?.value ?? [];
    final usedTodayIds =
        ref.watch(tasbihStateProvider.select((s) => s.usedTodayIds));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // رأس القائمة
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('اختر من قائمة التسابيح',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'إضافة ذكر جديد',
                    onPressed: () {
                      Navigator.pop(context); // أغلق الـ bottom sheet أولاً
                      _showAddTasbihDialog(context, ref);
                    },
                  ),
                ],
              ),
            ),
            // قائمة التسابيح
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
                              Navigator.pop(context);
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
        );
      },
    );
  }

  // --- الدوال المساعدة الخاصة بهذه الويدجت ---

  void _showAddTasbihDialog(BuildContext context, WidgetRef ref) {
    // ... (الكود نفسه بدون تغيير)
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
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
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text('إضافة'),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref
                      .read(tasbihStateProvider.notifier)
                      .addTasbih(controller.text.trim());
                  Navigator.pop(context);
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
    // ... (الكود نفسه بدون تغيير)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content:
              Text('هل أنت متأكد من رغبتك في حذف "${tasbih.text}" بشكل نهائي؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('حذف'),
              onPressed: () {
                ref.read(tasbihStateProvider.notifier).deleteTasbih(tasbih.id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
