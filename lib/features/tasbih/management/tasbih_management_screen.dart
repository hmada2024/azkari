// lib/features/tasbih/management/tasbih_management_screen.dart
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/management/widgets/set_goal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tasbih_management_provider.dart';

class TasbihManagementScreen extends ConsumerWidget {
  const TasbihManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihListAsync = ref.watch(tasbihForManagementProvider);
    final notifier = ref.read(tasbihManagementProvider.notifier);

    // استمع إلى حالة عمليات الـ Notifier لعرض الـ SnackBar
    ref.listen<AsyncValue<void>>(tasbihManagementProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${state.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التسابيح'),
      ),
      body: tasbihListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
        data: (tasbihList) {
          if (tasbihList.isEmpty) {
            return const Center(
              child: Text('القائمة فارغة، قم بإضافة ذكر جديد.'),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: tasbihList.length,
            itemBuilder: (context, index) {
              final tasbih = tasbihList[index];
              return _buildTasbihTile(context, ref, tasbih, index);
            },
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              notifier.reorderTasbihList(oldIndex, newIndex);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, ref),
        label: const Text('إضافة ذكر'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasbihTile(
      BuildContext context, WidgetRef ref, TasbihModel tasbih, int index) {
    return ListTile(
      key: ValueKey(tasbih.id),
      leading: ReorderableDragStartListener(
        index: index, // استخدم الـ index من الـ builder
        child: const Icon(Icons.drag_handle),
      ),
      title: Text(tasbih.text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'تحديد الهدف اليومي',
            onPressed: () => _showSetGoalSheet(context, tasbih),
          ),
          if (tasbih.isDeletable)
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              tooltip: 'تعديل الذكر',
              onPressed: () => _showEditDialog(context, ref, tasbih: tasbih),
            ),
          if (tasbih.isDeletable)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'حذف الذكر',
              onPressed: () => _showDeleteConfirmation(context, ref, tasbih),
            ),
          if (!tasbih.isDeletable)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(Icons.lock_outline, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // --- Dialogs & Sheets ---

  void _showSetGoalSheet(BuildContext context, TasbihModel tasbih) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // مهم للسماح للـ keyboard بالظهور بشكل صحيح
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SetGoalBottomSheet(tasbih: tasbih),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref,
      {TasbihModel? tasbih}) {
    final isEditing = tasbih != null;
    final controller = TextEditingController(text: tasbih?.text ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'تعديل الذكر' : 'إضافة ذكر جديد'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اكتب الذكر هنا...'),
          maxLines: 4,
          minLines: 2,
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FilledButton(
            child: Text(isEditing ? 'حفظ' : 'إضافة'),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final notifier = ref.read(tasbihManagementProvider.notifier);
                bool success;
                if (isEditing) {
                  success = await notifier.updateTasbihText(tasbih.id, text);
                } else {
                  success = await notifier.addTasbih(text);
                }
                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, TasbihModel tasbih) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${tasbih.text}"؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
            onPressed: () async {
              final notifier = ref.read(tasbihManagementProvider.notifier);
              final success = await notifier.deleteTasbih(tasbih.id);
              if (success && dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحذف بنجاح')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
