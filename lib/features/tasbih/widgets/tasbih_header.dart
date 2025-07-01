// lib/features/tasbih/widgets/tasbih_header.dart

import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_control_button.dart'; // [جديد]
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
        // [تعديل] استخدام الويدجت الجديد
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
        // [تعديل] استخدام الويدجت الجديد
        TasbihControlButton(
          icon: Icons.refresh,
          tooltip: 'تصفير العداد',
          onPressed: () => ref.read(tasbihStateProvider.notifier).resetCount(),
        ),
      ],
    );
  }
}
