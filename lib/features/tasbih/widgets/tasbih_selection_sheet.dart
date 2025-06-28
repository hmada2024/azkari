// lib/features/tasbih/widgets/tasbih_selection_sheet.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihSelectionSheet extends ConsumerWidget {
  const TasbihSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihListAsync = ref.watch(tasbihListProvider);
    final dailyGoalsAsync = ref.watch(dailyGoalsProvider);

    // ✅✅✅ الحل الجذري: استخدام Container بسيط وموثوق ✅✅✅
    // هذا يضمن أن المحتوى سيكون دائماً قابلاً للتنبؤ به في الاختبارات.
    return Container(
      // تحديد ارتفاع معقول لتجنب مشاكل التمرير المعقدة
      height: context.screenHeight * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // شريط السحب العلوي لإعطاء شكل الـ BottomSheet
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          const Divider(height: 1),
          Expanded(
            child: tasbihListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('خطأ: $e')),
              data: (tasbihList) => ListView.builder(
                itemCount: tasbihList.length,
                itemBuilder: (context, index) {
                  final tasbih = tasbihList[index];

                  final List<DailyGoalModel> goals =
                      dailyGoalsAsync.asData?.value ?? [];
                  final goalIndex =
                      goals.indexWhere((g) => g.tasbihId == tasbih.id);
                  final DailyGoalModel? goal =
                      goalIndex != -1 ? goals[goalIndex] : null;

                  final hasGoal = goal != null;

                  return ListTile(
                    key: Key('tasbih_tile_${tasbih.id}'),
                    title: Text(tasbih.text,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip:
                              hasGoal ? 'تعديل الهدف اليومي' : 'إضافة هدف يومي',
                          icon: Icon(
                            hasGoal ? Icons.flag_rounded : Icons.flag_outlined,
                            color: hasGoal
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                          onPressed: () => _showSetGoalDialog(context, ref,
                              tasbih.id, tasbih.text, goal?.targetCount),
                        ),
                        if (tasbih.isDeletable)
                          SizedBox(width: context.responsiveSize(8)),
                        if (tasbih.isDeletable)
                          IconButton(
                            key: Key('delete_tasbih_${tasbih.id}'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade400),
                            onPressed: () => _showDeleteConfirmationDialog(
                                context, ref, tasbih),
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
          ),
        ],
      ),
    );
  }

  void _showAddTasbihDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    showDialog<bool>(
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
            autofocus: true,
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
                  await ref
                      .read(tasbihStateProvider.notifier)
                      .addTasbih(controller.text.trim());

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
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
                await ref
                    .read(tasbihStateProvider.notifier)
                    .deleteTasbih(tasbih.id);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم الحذف بنجاح'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSetGoalDialog(BuildContext context, WidgetRef ref, int tasbihId,
      String tasbihText, int? currentTarget) {
    final TextEditingController controller =
        TextEditingController(text: currentTarget?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('الهدف اليومي'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"$tasbihText"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'العدد المطلوب يومياً',
                    hintText: 'مثال: 100',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال عدد';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'الرجاء إدخال عدد صحيح أكبر من صفر';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            if (currentTarget != null)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('إزالة الهدف'),
                onPressed: () async {
                  await ref
                      .read(dailyGoalsNotifierProvider.notifier)
                      .removeGoal(tasbihId);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
            const Spacer(),
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FilledButton(
              child: const Text('حفظ'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final target = int.parse(controller.text.trim());
                  await ref
                      .read(dailyGoalsNotifierProvider.notifier)
                      .setOrUpdateGoal(tasbihId, target);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
