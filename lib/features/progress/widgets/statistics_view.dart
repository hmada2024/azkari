// lib/features/progress/widgets/statistics_view.dart
import 'package:azkari/features/progress/providers/statistics_provider.dart';
import 'package:azkari/features/progress/widgets/stat_day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

class StatisticsView extends ConsumerWidget {
  const StatisticsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsState = ref.watch(statisticsProvider);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: statsState.isLoading
            ? Center(key: UniqueKey(), child: const CircularProgressIndicator())
            : statsState.error != null
                ? Center(
                    key: UniqueKey(), child: Text('خطأ: ${statsState.error}'))
                : _buildMonthlyView(context, statsState.data, theme),
      ),
    );
  }

  Widget _buildMonthlyView(
      BuildContext context, Map<DateTime, DailyStat> data, ThemeData theme) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return Column(
      key: UniqueKey(),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            "إنجاز شهر: ${intl.DateFormat.MMMM('ar').format(now)}",
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 50.0,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 4.0,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final dayNumber = index + 1;
            final date = DateTime(now.year, now.month, dayNumber);
            final stat = data[date];
            return StatDayCell(stat: stat, dayNumber: dayNumber);
          },
        ),
      ],
    );
  }
}
