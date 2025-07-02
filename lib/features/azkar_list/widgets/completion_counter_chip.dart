// lib/features/azkar_list/widgets/completion_counter_chip.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CompletionCounterChip extends StatelessWidget {
  final int completed;
  final int total;
  const CompletionCounterChip({
    super.key,
    required this.completed,
    required this.total,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAllCompleted = completed == total;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAllCompleted
            ? AppColors.success.withOpacity(0.8)
            : theme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAllCompleted
              ? AppColors.success
              : theme.primaryColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAllCompleted)
            const Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: Icon(Icons.check_circle, color: Colors.white, size: 18),
            ),
          Text(
            '$completed / $total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
