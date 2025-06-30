// lib/features/tasbih/widgets/tasbih_selection_sheet.dart
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihSelectionSheet extends ConsumerWidget {
  const TasbihSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihListAsync = ref.watch(tasbihListProvider);
    // [جديد] مراقبة العدادات اليومية
    final countsAsync = ref.watch(dailyTasbihCountsProvider);

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
            child: tasbihListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('خطأ: $e')),
              data: (tasbihList) {
                return countsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) =>
                        const Center(child: Text('خطأ في تحميل العدادات')),
                    data: (counts) {
                      return ListView.builder(
                        itemCount: tasbihList.length,
                        itemBuilder: (context, index) {
                          final tasbih = tasbihList[index];
                          final count = counts[tasbih.id] ?? 0;
                          return ListTile(
                            title: Text(tasbih.text),
                            // [مهم] عرض العداد اليومي
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
                                  .setActiveTasbih(tasbih.id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
