// lib/features/progress/widgets/no_goals_set_view.dart

import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/primary_button.dart';
import 'package:azkari/features/goal_management/screens/goal_management_screen.dart';
import 'package:flutter/material.dart';

/// ويدجت لعرض رسالة للمستخدم عندما لا يكون قد حدد أي أهداف بعد.
/// يوفر زرًا للانتقال إلى شاشة إدارة الأهداف.
class NoGoalsSetView extends StatelessWidget {
  const NoGoalsSetView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: context.responsiveSize(70),
              color: theme.disabledColor,
            ),
            SizedBox(height: context.responsiveSize(20)),
            Text(
              'لم تقم بتحديد أي أهداف بعد',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(10)),
            Text(
              'حدد أهدافك اليومية للبدء في تتبع تقدمك.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(20)),
            PrimaryButton(
              icon: Icons.add_task_outlined,
              text: 'تحديد الأهداف الآن',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GoalManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
