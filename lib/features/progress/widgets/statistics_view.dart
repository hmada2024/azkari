// lib/features/progress/widgets/statistics_view.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/progress/providers/statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

class StatisticsView extends ConsumerWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsState = ref.watch(statisticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. العنوان والأزرار في عمود منفصل لحل مشكلة الـ Overflow
        _buildHeader(context, ref),
        const SizedBox(height: 16),
        // 2. حاوية الشبكة الجديدة
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: statsState.isLoading
                ? const Center(
                    key: ValueKey('loading'),
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(),
                    ))
                : statsState.error != null
                    ? Center(
                        key: const ValueKey('error'),
                        child: Text('خطأ: ${statsState.error}'))
                    // 3. عرض الشبكة الجديدة بدلاً من الرسم البياني
                    : _buildContributionGrid(
                        context,
                        statsState.period,
                        statsState.data,
                      ),
          ),
        ),
      ],
    );
  }

  // ويدجت جديد لرأس القسم (العنوان والأزرار)
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsState = ref.watch(statisticsProvider);
    final statsNotifier = ref.read(statisticsProvider.notifier);

    return Column(
      children: [
        Text(
          'الإحصائيات',
          style: TextStyle(
            fontSize: context.responsiveSize(16),
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<StatPeriod>(
          segments: const [
            ButtonSegment(value: StatPeriod.weekly, label: Text('أسبوعي')),
            ButtonSegment(value: StatPeriod.monthly, label: Text('شهري')),
          ],
          selected: {statsState.period},
          onSelectionChanged: (newSelection) {
            statsNotifier.fetchStatsForPeriod(newSelection.first);
          },
          style: SegmentedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            selectedBackgroundColor: theme.primaryColor.withOpacity(0.2),
            selectedForegroundColor: theme.primaryColor,
            textStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      ],
    );
  }

  // ويدجت جديد لبناء شبكة الإنجاز
  Widget _buildContributionGrid(
    BuildContext context,
    StatPeriod period,
    Map<String, int> data,
  ) {
    if (period == StatPeriod.weekly) {
      return _buildWeeklyGrid(context, data);
    } else {
      return _buildMonthlyGrid(context, data);
    }
  }

  Widget _buildWeeklyGrid(BuildContext context, Map<String, int> data) {
    final now = DateTime.now();
    final weekDaysLabels = [
      'إثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعة',
      'سبت',
      'أحد'
    ];
    final formatter = intl.DateFormat('yyyy-MM-dd');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Text(
            "إنجاز الأسبوع الحالي",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final dayDate =
                now.subtract(Duration(days: now.weekday - 1 - index));
            final dateString = formatter.format(dayDate);
            final count = data[dateString] ?? 0;

            return Column(
              children: [
                _buildGridCell(context, count, dateString),
                const SizedBox(height: 4),
                Text(
                  weekDaysLabels[index],
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthlyGrid(BuildContext context, Map<String, int> data) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // يوم الإثنين هو 1، الأحد هو 7. نحتاج إلى إزاحة للبدء من يوم صحيح في الشبكة
    final weekdayOfFirstDay = firstDayOfMonth.weekday;
    final int emptyCells = weekdayOfFirstDay - 1;

    final formatter = intl.DateFormat('yyyy-MM-dd');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Text(
            "إنجاز الشهر الحالي (${intl.DateFormat.MMMM('ar').format(now)})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          alignment: WrapAlignment.center,
          children: List.generate(daysInMonth + emptyCells, (index) {
            if (index < emptyCells) {
              // خلايا فارغة لبداية الشهر
              return const SizedBox(width: 25, height: 25);
            }
            final dayNumber = index - emptyCells + 1;
            final dayDate = DateTime(now.year, now.month, dayNumber);
            final dateString = formatter.format(dayDate);
            final count = data[dateString] ?? 0;

            return _buildGridCell(context, count, dateString);
          }),
        ),
      ],
    );
  }

  // خلية واحدة في الشبكة
  Widget _buildGridCell(BuildContext context, int count, String dateString) {
    Color color = _getColorForCount(context, count);

    return Tooltip(
      message:
          '${intl.DateFormat.yMMMd('ar').format(DateTime.parse(dateString))}\n'
          'التسبيحات: $count',
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
    );
  }

  // دالة لتحديد اللون بناءً على عدد التسبيحات
  Color _getColorForCount(BuildContext context, int count) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (count == 0) {
      return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    }
    if (count <= 10) {
      return Colors.teal.shade100;
    }
    if (count <= 50) {
      return Colors.teal.shade300;
    }
    if (count <= 100) {
      return Colors.teal.shade500;
    }
    return Colors.teal.shade700;
  }
}
