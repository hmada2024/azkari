// lib/features/progress/widgets/initial_progress_view.dart

import 'package:azkari/core/utils/size_config.dart';
import 'package:flutter/material.dart';

/// ويدجت لعرض الحالة الأولية في شاشة التقدم
/// عندما تكون هناك أهداف محددة ولكن لم يبدأ المستخدم التسبيح بعد.
class InitialProgressView extends StatelessWidget {
  const InitialProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: context.responsiveSize(80),
              color: theme.primaryColor.withOpacity(0.6),
            ),
            SizedBox(height: context.responsiveSize(24)),
            Text(
              'ابدأ رحلتك اليومية',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(12)),
            Text(
              'سيظهر تقدمك في أهدافك اليومية هنا بمجرد البدء في التسبيح من شاشة السبحة.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
