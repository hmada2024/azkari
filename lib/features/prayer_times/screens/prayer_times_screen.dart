// lib/features/prayer_times/screens/prayer_times_screen.dart
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:azkari/features/prayer_times/widgets/initial_setup_view.dart';
import 'package:azkari/features/prayer_times/widgets/next_prayer_card.dart';
import 'package:azkari/features/prayer_times/widgets/prayer_times_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return CustomErrorWidget(
              errorMessage: state.error!,
              onRetry: () =>
                  ref.read(prayerTimesProvider.notifier).setupAutomatic(),
            );
          }
          if (state.needsSetup) {
            return const InitialSetupView();
          }
          if (state.prayerTimes != null) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  NextPrayerCard(prayerTimes: state.prayerTimes!),
                  const SizedBox(height: 24),
                  PrayerTimesListView(prayerTimes: state.prayerTimes!),
                ],
              ),
            );
          }
          return const Center(child: Text('حالة غير معروفة.'));
        },
      ),
    );
  }
}
