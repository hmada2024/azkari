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

  Widget _buildWeeklyView(
      BuildContext context, Map<DateTime, DailyStat> data, ThemeData theme,
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

  // ✨ [إعادة بناء كاملة] تم إعادة بناء هذه الدالة بالكامل لتلبية المتطلبات الجديدة
  Widget _buildMonthlyView(
      BuildContext context, Map<DateTime, DailyStat> data, ThemeData theme,
      {required Key key}) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return LayoutBuilder(builder: (context, constraints) {
      // يمكنك التحكم بعدد الأعمدة هنا بتغيير الرقم 7
      const int crossAxisCount = 7;
      const double spacing = 8.0;
      final double itemWidth =
          (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
              crossAxisCount;

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
          const SizedBox(height: 8),

          // ✨ [تغيير] استخدام Wrap لإنشاء شبكة بسيطة تبدأ من الأعلى
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(daysInMonth, (index) {
              final dayNumber = index + 1;
              final date = DateTime(now.year, now.month, dayNumber);
              final stat = data[date];

              return SizedBox(
                width: itemWidth,
                child: _buildDayNumberCell(stat, dayNumber, theme),
              );
            }),
          ),
        ],
      );
    });
  }

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

  // ✨ [جديد] دالة جديدة لعرض رقم اليوم مع التلوين المناسب
  Widget _buildDayNumberCell(DailyStat? stat, int dayNumber, ThemeData theme) {
    if (stat == null) {
      // حالة غير متوقعة، نعرض الرقم بلون محايد
      return Text(
        dayNumber.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(color: theme.disabledColor),
      );
    }

    Color textColor;
    FontWeight fontWeight = FontWeight.normal;

    // تحديد اللون بناءً على حالة اليوم
    if (stat.type == StatDayType.future) {
      textColor = theme.disabledColor;
    } else if (stat.type == StatDayType.today) {
      // اليوم الحالي يُميَّز بلون الثيم الأساسي وخط عريض
      textColor = stat.isCompleted ? AppColors.success : theme.primaryColor;
      fontWeight = FontWeight.bold;
    } else {
      // يوم ماضي
      textColor = stat.isCompleted ? AppColors.success : AppColors.error;
    }

    return Text(
      dayNumber.toString(),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor,
        fontWeight: fontWeight,
        fontSize: 16,
      ),
    );
  }
}
