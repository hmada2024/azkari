// lib/features/prayer_times/widgets/prayer_times_list_view.dart
import 'package:adhan/adhan.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimesListView extends StatelessWidget {
  final PrayerTimes prayerTimes;

  const PrayerTimesListView({super.key, required this.prayerTimes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextPrayer = prayerTimes.nextPrayer();

    final prayers = {
      'الفجر': prayerTimes.fajr,
      'الشروق': prayerTimes.sunrise,
      'الظهر': prayerTimes.dhuhr,
      'العصر': prayerTimes.asr,
      'المغرب': prayerTimes.maghrib,
      'العشاء': prayerTimes.isha,
    };

    Prayer prayerEnumFromString(String name) {
      switch (name) {
        case 'الفجر':
          return Prayer.fajr;
        case 'الشروق':
          return Prayer.sunrise;
        case 'الظهر':
          return Prayer.dhuhr;
        case 'العصر':
          return Prayer.asr;
        case 'المغرب':
          return Prayer.maghrib;
        case 'العشاء':
          return Prayer.isha;
        default:
          return Prayer.none;
      }
    }

    return Expanded(
      child: ListView.separated(
        itemCount: prayers.length,
        separatorBuilder: (context, index) => Divider(
          height: context.responsiveSize(1),
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final name = prayers.keys.elementAt(index);
          final time = prayers.values.elementAt(index);
          final isNextPrayer = prayerEnumFromString(name) == nextPrayer;

          return ListTile(
            title: Text(
              name,
              style: TextStyle(
                fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
                color: isNextPrayer
                    ? theme.colorScheme.secondary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
            trailing: Text(
              DateFormat.jm('ar').format(time),
              style: TextStyle(
                fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
                fontSize: context.responsiveSize(16),
                color: isNextPrayer
                    ? theme.colorScheme.secondary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
          );
        },
      ),
    );
  }
}
