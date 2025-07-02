// lib/features/tasbih/widgets/tasbih_selection_sheet.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class TasbihSelectionSheet extends ConsumerWidget {
  const TasbihSelectionSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(tasbihListProvider);
    final goalsState = ref.watch(dailyGoalsStateProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('قائمة الذكر',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const Divider(height: 1),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('خطأ: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('لم يتم إضافة أي ذكر بعد.'));
                }
                final List<DailyGoalModel> goals =
                    goalsState.goals.valueOrNull ?? [];
                final countsMap = {
                  for (var g in goals) g.tasbihId: g.currentProgress
                };
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final count = countsMap[item.id] ?? 0;
                    return ListTile(
                      title: Text(item.text),
                      trailing: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () {
                        ref
                            .read(tasbihStateProvider.notifier)
                            .setActiveTasbih(item.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}