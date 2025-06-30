// lib/features/goal_management/screens/goal_management_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                .copyWith(bottom: 90), // مساحة للـ FAB
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _GoalItemCard(
                key: ValueKey('goal_item_${item.tasbih.id}'),
                item: item,
                index: index,
                notifier: notifier,
                onTap: () => _showEditGoalDialog(context, notifier, item),
              );
            },
            onReorder: (oldI, newI) => notifier.reorderTasbih(oldI, newI),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTasbihDialog(context, notifier),
        icon: const Icon(Icons.add),
        label: const Text('إضافة ذكر جديد'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showEditGoalDialog(BuildContext context,
      GoalManagementNotifier notifier, GoalManagementItem item) {
    final controller = TextEditingController(
        text: item.targetCount > 0 ? item.targetCount.toString() : '');
    showDialog(
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

  // هذه هي الدالة التي كانت ناقصة
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

// ويدجت البطاقة الكامل
class _GoalItemCard extends StatelessWidget {
  final GoalManagementItem item;
  final int index;
  final GoalManagementNotifier notifier;
  final VoidCallback onTap;

  const _GoalItemCard({
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: context.responsiveSize(16),
                  ),
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

    // هذا هو منطق الحذف الكامل الذي كان ناقصًا
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
