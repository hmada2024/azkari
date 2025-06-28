// lib/features/tasbih/widgets/tasbih_header.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihHeader extends ConsumerWidget {
  const TasbihHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildControlButton(
          context: context,
          icon: Icons.list_alt_rounded,
          tooltip: 'اختيار الذكر',
          onPressed: () async {
            // ✨ [الإصلاح الحقيقي]
            final result = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const TasbihSelectionSheet(),
            );

            if (result == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت الإضافة بنجاح'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
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
        _buildControlButton(
          context: context,
          icon: Icons.refresh,
          tooltip: 'تصفير العداد',
          onPressed: () => ref.read(tasbihStateProvider.notifier).resetCount(),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSize(10)),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.cardColor,
              border: Border.all(color: theme.dividerColor.withOpacity(0.5))),
          child: Icon(
            icon,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            size: context.responsiveSize(24),
          ),
        ),
      ),
    );
  }
}
