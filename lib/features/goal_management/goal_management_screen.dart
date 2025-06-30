// lib/features/goal_management/goal_management_screen.dart
import 'package:azkari/features/goal_management/goal_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalManagementScreen extends ConsumerWidget {
  const GoalManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(goalManagementProvider);
    final notifier = ref.read(goalManagementStateProvider.notifier);

    ref.listen<AsyncValue<void>>(goalManagementStateProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشلت العملية: ${state.error}'),
          backgroundColor: theme.colorScheme.error,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة أهدافي')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('خطأ: $err')),
        data: (items) {
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final tile = ListTile(
                key: ValueKey('goal_item_${item.tasbih.id}'),
                leading: ReorderableDragStartListener(
                    index: index, child: const Icon(Icons.drag_handle)),
                title: Text(item.tasbih.text),
                trailing: Text(
                  item.targetCount > 0 ? '${item.targetCount} مرة' : 'غير محدد',
                  style: TextStyle(
                      color: item.targetCount > 0
                          ? theme.primaryColor
                          : theme.disabledColor,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () => _showEditGoalDialog(context, notifier, item),
              );

              if (item.tasbih.isDeletable) {
                return Dismissible(
                  key: ValueKey('dismissible_${item.tasbih.id}'),
                  background: Container(
                    color: theme.colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (_) => notifier.deleteTasbih(item.tasbih.id),
                  child: tile,
                );
              }
              return tile;
            },
            onReorder: (oldI, newI) => notifier.reorderTasbih(oldI, newI),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTasbihDialog(context, notifier),
        icon: const Icon(Icons.add),
        label: const Text('إضافة ذكر'),
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context,
      GoalManagementNotifier notifier, GoalManagementItem item) {
    final controller = TextEditingController(
        text: item.targetCount > 0 ? item.targetCount.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحديد الهدف لـ "${item.tasbih.text}"'),
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
            onPressed: () {
              final count = int.tryParse(controller.text) ?? 0;
              notifier.setGoal(item.tasbih.id, count);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showAddTasbihDialog(
      BuildContext context, GoalManagementNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ذكر جديد'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'اكتب الذكر هنا...')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                notifier.addTasbih(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
