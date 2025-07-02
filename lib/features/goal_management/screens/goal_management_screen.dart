// lib/features/goal_management/screens/goal_management_screen.dart

import 'package:azkari/core/error/failures.dart'; // [جديد]
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:azkari/features/goal_management/widgets/goal_item_card.dart';
import 'package:azkari/features/goal_management/widgets/goal_management_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalManagementScreen extends ConsumerWidget {
  const GoalManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stateAsync = ref.watch(goalManagementProvider);
    final notifier = ref.read(goalManagementStateProvider.notifier);

    // [مُعدَّل] الـ listener الآن يفهم كائن Failure
    ref.listen<AsyncValue<void>>(goalManagementStateProvider, (_, state) {
      if (state.hasError && state.error is Failure) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشلت العملية: ${(state.error as Failure).message}'),
          backgroundColor: theme.colorScheme.error,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة أهدافي')),
      // [مُعدَّل] عرض الخطأ يفهم الآن كائن Failure
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) =>
            Center(child: Text('خطأ: ${(err as Failure).message}')),
        data: (items) {
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                .copyWith(bottom: 90),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GoalItemCard(
                key: ValueKey('goal_item_${item.tasbih.id}'),
                item: item,
                index: index,
                notifier: notifier,
                onTap: () => showEditGoalDialog(context, notifier, item),
              );
            },
            onReorder: (oldI, newI) => notifier.reorderTasbih(oldI, newI),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTasbihDialog(context, notifier),
        icon: const Icon(Icons.add),
        label: const Text('إضافة ذكر جديد'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
