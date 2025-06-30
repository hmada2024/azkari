// lib/features/progress/widgets/statistics_view.dart
import 'package:azkari/core/constants/app_colors.dart';
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
    final statsNotifier = ref.read(statisticsProvider.notifier);

    return Column(
      children: [
        _buildHeader(context, theme, statsState, statsNotifier),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: statsState.isLoading
                ? Center(
                    key: UniqueKey(), child: const CircularProgressIndicator())
                : statsState.error != null
                    ? Center(
                        key: UniqueKey(),
                        child: Text('خطأ: ${statsState.error}'))
                    : _buildContent(context, statsState, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme,
      StatisticsState state, StatisticsNotifier notifier) {
    return Column(
      children: [
        Text('الإحصائيات',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor)),
        const SizedBox(height: 8),
        SegmentedButton<StatPeriod>(
          segments: const [
            ButtonSegment(value: StatPeriod.weekly, label: Text('أسبوعي')),
            ButtonSegment(value: StatPeriod.monthly, label: Text('شهري')),
          ],
          selected: {state.period},
          onSelectionChanged: (selection) =>
              notifier.fetchStatsForPeriod(selection.first),
        ),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, StatisticsState state, ThemeData theme) {
    final key = UniqueKey();
    if (state.period == StatPeriod.weekly) {
      return _buildWeeklyView(context, state.data, theme, key: key);
    } else {
      return _buildMonthlyView(context, state.data, theme, key: key);
    }
  }

  // ✨ [مُعدَّل] تغيير بسيط لـ DayStatus وتمرير الثيم
  Widget _buildWeeklyView(BuildContext context, Map<DateTime, DailyStat> data,
      ThemeData theme,
      {required Key key}) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];

    return Container(
      key: key,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final dateOnly = DateTime(date.year, date.month, date.day);
          final status = data[dateOnly];

          return ListTile(
            title: Text(weekDays[index]),
            trailing: _buildStatusIcon(status, theme),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
      ),
    );
  }

  // ✨ [إعادة بناء كاملة] تم إعادة بناء هذه الدالة بالكامل
  Widget _buildMonthlyView(BuildContext context, Map<DateTime, DailyStat> data,
      ThemeData theme,
      {required Key key}) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int emptyCells = firstDayOfMonth.weekday % 7;
    final weekDayHeaders = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

    return LayoutBuilder(builder: (context, constraints) {
      const double horizontalSpacing = 4.0;
      const double verticalSpacing = 8.0;

      return Column(
        key: key,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              "إنجاز شهر: ${intl.DateFormat.MMMM('ar').format(now)}",
              style: theme.textTheme.titleMedium,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDayHeaders
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodySmall?.color),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: horizontalSpacing,
            runSpacing: verticalSpacing,
            children: List.generate(daysInMonth + emptyCells, (index) {
              if (index < emptyCells) {
                return SizedBox(
                    width: (constraints.maxWidth - (horizontalSpacing * 6)) / 7);
              }
              final dayNumber = index - emptyCells + 1;
              final date = DateTime(now.year, now.month, dayNumber);
              final stat = data[date];

              return SizedBox(
                width: (constraints.maxWidth - (horizontalSpacing * 6)) / 7,
                child: _buildDayStatCell(stat, theme),
              );
            }),
          ),
        ],
      );
    });
  }
  
  // ✨ [مُعدَّل] تغيير بسيط لـ DayStatus وتمرير الثيم
  Widget _buildStatusIcon(DailyStat? status, ThemeData theme) {
    if (status == null || status.type == StatDayType.future) {
       return const Icon(Icons.radio_button_unchecked, color: AppColors.grey);
    }
    if (status.type == StatDayType.today && !status.isCompleted) {
        return const Icon(Icons.radio_button_unchecked, color: AppColors.grey);
    }

    return status.isCompleted
        ? const Icon(Icons.check_circle, color: AppColors.success)
        : const Icon(Icons.cancel, color: AppColors.error);
  }

  // ✨ [جديد] دالة جديدة لعرض خلية الإحصائيات بدلاً من الدائرة
  Widget _buildDayStatCell(DailyStat? stat, ThemeData theme) {
    if (stat == null) {
      // أيام من الشهر الماضي أو التالي تظهر كفراغ
      return const SizedBox.shrink();
    }
    
    // الأيام المستقبلية تظهر كـ نقطة
    if (stat.type == StatDayType.future) {
      return Text(
        '·',
        textAlign: TextAlign.center,
        style: TextStyle(color: theme.disabledColor, fontWeight: FontWeight.bold),
      );
    }

    Color textColor;
    if (stat.type == StatDayType.today && !stat.isCompleted) {
       textColor = theme.primaryColor;
    } else if (stat.isCompleted) {
      textColor = AppColors.success;
    } else {
      textColor = AppColors.error;
    }

    final percentText = '${(stat.percentage * 100).round()}%';

    return Text(
      percentText,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}