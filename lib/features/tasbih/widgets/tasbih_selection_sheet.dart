// lib/features/tasbih/widgets/tasbih_selection_sheet.dart
import 'package:azkari/features/tasbih/management/tasbih_management_screen.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihSelectionSheet extends ConsumerWidget {
  const TasbihSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // نستخدم tasbihListProvider القديم لأنه يعكس القائمة المتاحة للاختيار
    final tasbihListAsync = ref.watch(tasbihListProvider);

    return Container(
      key: const Key('tasbih_selection_sheet_container'),
      // ارتفاع أقل لأنها أصبحت أبسط
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // مقبض السحب
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // الرأس الجديد
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'قائمة الذكر',
                    style: Theme.of(context).textTheme.titleLarge,
                    // إضافة هذه الخصائص تضمن عدم تجاوز النص لسطر واحد
                    // وقصّه بشكل أنيق إذا كانت المساحة ضيقة جداً
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // زر الإدارة الجديد
                TextButton.icon(
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('تعديل القائمة'),
                  onPressed: () {
                    // إغلاق الـ sheet أولاً ثم الانتقال للشاشة الجديدة
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TasbihManagementScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // القائمة المبسطة
          Expanded(
            child: tasbihListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('خطأ: $e')),
              data: (tasbihList) => ListView.builder(
                key: const Key('tasbih_list_scrollable'),
                itemCount: tasbihList.length,
                itemBuilder: (context, index) {
                  final tasbih = tasbihList[index];
                  return ListTile(
                    key: Key('tasbih_tile_${tasbih.id}'),
                    title: Text(tasbih.text,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      // عند الضغط، اختر الذكر وأغلق الشاشة
                      ref
                          .read(tasbihStateProvider.notifier)
                          .setActiveTasbih(tasbih.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
