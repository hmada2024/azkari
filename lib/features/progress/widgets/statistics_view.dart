// lib/features/progress/widgets/statistics_view.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/progress/providers/statistics_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

class StatisticsView extends ConsumerWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsState = ref.watch(statisticsProvider);
    final statsNotifier = ref.read(statisticsProvider.notifier);

    final titles = _getTitles(statsState.period);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإحصائيات',
              style: TextStyle(
                fontSize: context.responsiveSize(16),
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
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
                selectedBackgroundColor: theme.primaryColor.withOpacity(0.2),
                selectedForegroundColor: theme.primaryColor,
                textStyle: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          height: 250,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: statsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : statsState.error != null
                  ? Center(child: Text('خطأ: ${statsState.error}'))
                  : BarChart(
                      _buildChartData(theme, statsState.data, titles),
                    ),
        ),
      ],
    );
  }

  List<String> _getTitles(StatPeriod period) {
    final now = DateTime.now();
    if (period == StatPeriod.weekly) {
      final List<String> weekDays = [
        'إثنين',
        'ثلاثاء',
        'أربعاء',
        'خميس',
        'جمعة',
        'سبت',
        'أحد'
      ];
      return List.generate(7, (index) => weekDays[index]);
    } else {
      final int weeksInMonth = (now.day / 7).ceil();
      if (weeksInMonth == 0) return ['الأسبوع 1'];
      return List.generate(weeksInMonth, (index) => 'الأسبوع ${index + 1}');
    }
  }

  BarChartData _buildChartData(
      ThemeData theme, Map<String, int> data, List<String> titles) {
    final formatter = intl.DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    final List<BarChartGroupData> barGroups =
        List.generate(titles.length, (index) {
      double totalY = 0;
      if (titles.length == 7) {
        final dayDate =
            now.subtract(Duration(days: (now.weekday - 1 - index).abs()));
        final dateString = formatter.format(dayDate);
        totalY = (data[dateString] ?? 0).toDouble();
      } else {
        final weekStartDate = DateTime(now.year, now.month, (index * 7) + 1);
        for (int i = 0; i < 7; i++) {
          final dayDate = weekStartDate.add(Duration(days: i));
          if (dayDate.month != now.month) break;
          final dateString = formatter.format(dayDate);
          totalY += (data[dateString] ?? 0).toDouble();
        }
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalY,
            color: theme.primaryColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });

    return BarChartData(
      barGroups: barGroups,
      alignment: BarChartAlignment.spaceAround,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value.toInt() >= titles.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(titles[value.toInt()],
                    style: TextStyle(
                        fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              );
            },
            reservedSize: 28,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 8,
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if (group.x.toInt() >= titles.length) return null;
            return BarTooltipItem(
              '${titles[group.x.toInt()]}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: rod.toY.toInt().toString(),
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors
                            .black
                        : Colors
                            .white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
