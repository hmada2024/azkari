// lib/features/tasbih/widgets/tasbih_header.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_control_button.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class TasbihHeader extends ConsumerWidget {
  const TasbihHeader({super.key});
  Future<void> _showResetConfirmationDialog(
      BuildContext context, WidgetRef ref) async {
    final activeTasbih = await ref.read(activeTasbihProvider.future);
    if (activeTasbih.id == -1 || !context.mounted) {
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد التصفير'),
        content: Text(
            'هل أنت متأكد من رغبتك في تصفير عداد "${activeTasbih.text}"؟\nسيتم حذف تقدمك لهذا اليوم.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref
                  .read(tasbihStateProvider.notifier)
                  .resetActiveTasbihProgress();
              Navigator.of(ctx).pop();
            },
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TasbihControlButton(
          icon: Icons.list_alt_rounded,
          tooltip: 'اختيار الذكر',
          onPressed: () async {
            await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const TasbihSelectionSheet(),
            );
          },
        ),
        Text(
          'السبحة',
          style: TextStyle(
            fontSize: context.responsiveSize(22),
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        TasbihControlButton(
          icon: Icons.refresh,
          tooltip: 'تصفير العداد',
          onPressed: () => _showResetConfirmationDialog(context, ref),
        ),
      ],
    );
  }
}