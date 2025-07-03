// lib/features/prayer_times/widgets/next_prayer_card.dart
import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class NextPrayerCard extends StatefulWidget {
  final PrayerTimes prayerTimes;
  const NextPrayerCard({super.key, required this.prayerTimes});

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  late Prayer _nextPrayer;
  late Duration _timeUntilNextPrayer;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updatePrayerInfo();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updatePrayerInfo();
      }
    });
  }

  @override
  void didUpdateWidget(covariant NextPrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prayerTimes.fajr != oldWidget.prayerTimes.fajr) {
      _updatePrayerInfo();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updatePrayerInfo() {
    setState(() {
      _nextPrayer = widget.prayerTimes.nextPrayer();
      _timeUntilNextPrayer = widget.prayerTimes
          .timeForPrayer(_nextPrayer)!
          .difference(DateTime.now());
    });
  }

  String _prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.none:
        return 'صلاة العشاء القادمة';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsiveSize(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  theme.colorScheme.secondary,
                  theme.colorScheme.primary.withOpacity(0.7)
                ]
              : [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'الصلاة القادمة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: context.responsiveSize(16),
            ),
          ),
          SizedBox(height: context.responsiveSize(8)),
          Text(
            _prayerName(_nextPrayer),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.responsiveSize(28),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.responsiveSize(12)),
          Text(
            _formatDuration(_timeUntilNextPrayer),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.responsiveSize(36),
              fontWeight: FontWeight.w300,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
