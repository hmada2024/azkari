// lib/features/prayer_times/providers/prayer_times_provider.dart
import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:azkari/features/prayer_times/data/repositories/prayer_settings_repository.dart';
import 'package:azkari/features/prayer_times/data/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class PrayerTimesState {
  final bool needsSetup;
  final bool isLoading;
  final String? error;
  final PrayerTimes? prayerTimes;

  const PrayerTimesState({
    this.needsSetup = false,
    this.isLoading = true,
    this.error,
    this.prayerTimes,
  });

  PrayerTimesState copyWith({
    bool? needsSetup,
    bool? isLoading,
    String? error,
    PrayerTimes? prayerTimes,
  }) {
    return PrayerTimesState(
      needsSetup: needsSetup ?? this.needsSetup,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      prayerTimes: prayerTimes ?? this.prayerTimes,
    );
  }
}

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  final Ref _ref;
  Timer? _timer;

  PrayerTimesNotifier(this._ref) : super(const PrayerTimesState()) {
    _init();
  }

  Future<void> _init() async {
    final repo = await _ref.read(prayerSettingsRepositoryProvider.future);
    final settings = repo.getSettings();

    if (settings == null) {
      state = state.copyWith(needsSetup: true, isLoading: false);
    } else {
      _calculateAndSetPrayerTimes();
    }
  }

  void _calculateAndSetPrayerTimes() async {
    final repo = await _ref.read(prayerSettingsRepositoryProvider.future);
    final settings = repo.getSettings();
    if (settings == null) return;

    final prayerTimes = PrayerTimes(
      Coordinates(settings.latitude, settings.longitude),
      DateComponents.from(DateTime.now()),
      settings.calculationMethod.getParameters(),
    );

    state = state.copyWith(
        prayerTimes: prayerTimes, needsSetup: false, isLoading: false);
    _startTimer();
  }

  Future<void> setupAutomatic() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locationService = _ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();

      if (position != null) {
        final repo = await _ref.read(prayerSettingsRepositoryProvider.future);
        await repo.saveSettings(position.latitude, position.longitude);
        _calculateAndSetPrayerTimes();
      } else {
        throw Exception("Could not determine location.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        state = state.copyWith(prayerTimes: state.prayerTimes);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  return PrayerTimesNotifier(ref);
});
