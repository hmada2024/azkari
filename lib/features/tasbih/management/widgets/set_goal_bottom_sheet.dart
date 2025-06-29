// lib/features/tasbih/management/widgets/set_goal_bottom_sheet.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetGoalBottomSheet extends ConsumerWidget {
  final TasbihModel tasbih;

  const SetGoalBottomSheet({
    super.key,
    required this.tasbih,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة قائمة الأهداف للعثور على الهدف الحالي لهذا الذكر
    final dailyGoalsAsync = ref.watch(dailyGoalsProvider);

    return dailyGoalsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: Text('خطأ في تحميل الهدف: $e')),
      ),
      data: (goals) {
        // البحث عن الهدف الحالي
        final currentGoal = goals.firstWhere(
          (g) => g.tasbihId == tasbih.id,
          orElse: () => DailyGoalModel(
            goalId: -1,
            tasbihId: tasbih.id,
            tasbihText: tasbih.text,
            targetCount: 0,
            currentProgress: 0,
          ),
        );

        return _buildForm(context, ref, currentGoal);
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    DailyGoalModel currentGoal,
  ) {
    final hasExistingGoal = currentGoal.targetCount > 0;
    final controller = TextEditingController(
      text: hasExistingGoal ? currentGoal.targetCount.toString() : '',
    );
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الهدف اليومي لـِ',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '"${tasbih.text}"',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
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
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'الرجاء إدخال عدد صحيح أكبر من صفر';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasExistingGoal)
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final notifier =
                          ref.read(dailyGoalsNotifierProvider.notifier);
                      await notifier.removeGoal(tasbih.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('إزالة الهدف'),
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final target = int.parse(controller.text.trim());
                      final notifier =
                          ref.read(dailyGoalsNotifierProvider.notifier);
                      await notifier.setOrUpdateGoal(tasbih.id, target);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
