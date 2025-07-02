// lib/features/goal_management/screens/goal_management_screen.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/core/widgets/app_background.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:azkari/features/goal_management/widgets/goal_item_card.dart';
import 'package:azkari/features/goal_management/widgets/management_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalManagementScreen extends ConsumerWidget {
  const GoalManagementScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalManagementStateProvider);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('إدارة أهدافي'),
          actions: [
            if (state.isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        body: state.items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) {
            final message =
                (err is Failure) ? err.message : 'حدث خطأ غير متوقع.';
            return Center(child: Text('خطأ: $message'));
          },
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text("لم تقم بإضافة أي أذكار بعد."));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  .copyWith(bottom: 90),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GoalItemCard(
                  key: ValueKey('goal_item_${item.tasbih.id}'),
                  item: item,
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: state.isSaving ? null : () => showAddTasbihDialog(context),
          tooltip: 'إضافة ذكر جديد',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
