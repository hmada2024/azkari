// lib/features/progress/widgets/statistics_view.dart
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
                    : _buildContent(context, statsState),
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

  Widget _buildContent(BuildContext context, StatisticsState state) {
    // [تصحيح جذري] استخدام UniqueKey() لضمان التفرد المطلق في كل عملية بناء.
    final key = UniqueKey();
    if (state.period == StatPeriod.weekly) {
      return _buildWeeklyView(context, state.data, key: key);
    } else {
      return _buildMonthlyView(context, state.data, key: key);
    }
  }

  Widget _buildWeeklyView(BuildContext context, Map<DateTime, DayStatus> data,
      {required Key key}) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];

    // [ملاحظة] تطبيق الـ Key على الويدجت الأب
    return Container(
      key: key,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final dateOnly = DateTime(date.year, date.month, date.day);
          final status = data[dateOnly] ?? DayStatus.future;

          return ListTile(
            title: Text(weekDays[index]),
            trailing: _buildStatusIcon(status),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
      ),
    );
  }

  Widget _buildMonthlyView(BuildContext context, Map<DateTime, DayStatus> data,
      {required Key key}) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int emptyCells = firstDayOfMonth.weekday - 1;

    // [ملاحظة] تطبيق الـ Key على الويدجت الأب
    return Column(
      key: key,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            "إنجاز شهر: ${intl.DateFormat.MMMM('ar').format(now)}",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: List.generate(daysInMonth + emptyCells, (index) {
            if (index < emptyCells) {
              return const SizedBox(width: 32, height: 32);
            }
            final dayNumber = index - emptyCells + 1;
            final date = DateTime(now.year, now.month, dayNumber);
            final status = data[date] ?? DayStatus.future;
            return _buildStatusCircle(context, status, dayNumber);
          }),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(DayStatus status) {
    switch (status) {
      case DayStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DayStatus.notCompleted:
        return const Icon(Icons.cancel, color: Colors.red);
      case DayStatus.isToday:
      case DayStatus.future:
        return const Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }
  }

  Widget _buildStatusCircle(
      BuildContext context, DayStatus status, int dayNumber) {
    Color bgColor;
    Widget child;
    switch (status) {
      case DayStatus.completed:
        bgColor = Colors.green;
        child = const Icon(Icons.check, color: Colors.white, size: 18);
        break;
      case DayStatus.notCompleted:
        bgColor = Colors.red;
        child = Text(dayNumber.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold));
        break;
      case DayStatus.isToday:
        bgColor = Theme.of(context).primaryColor;
        child = Text(dayNumber.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold));
        break;
      case DayStatus.future:
        bgColor = Theme.of(context).dividerColor;
        child = Text(dayNumber.toString(),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall?.color));
        break;
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Center(child: child),
    );
  }
}
