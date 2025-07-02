// lib/features/adhkar_list/providers/adhkar_card_provider.dart
import 'package:azkari/data/models/azkar_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class AzkarCardState {
  final AzkarModel adhkar;
  final int currentCount;
  final int initialCount;
  const AzkarCardState({
    required this.adhkar,
    required this.currentCount,
    required this.initialCount,
  });
  bool get isFinished => currentCount == 0;
  double get progress => (initialCount - currentCount) / initialCount;
  AzkarCardState copyWith({
    AzkarModel? adhkar,
    int? currentCount,
    int? initialCount,
  }) {
    return AzkarCardState(
      adhkar: adhkar ?? this.adhkar,
      currentCount: currentCount ?? this.currentCount,
      initialCount: initialCount ?? this.initialCount,
    );
  }
}

class AzkarCardNotifier extends StateNotifier<AzkarCardState> {
  AzkarCardNotifier(AzkarModel initialAzkar)
      : super(AzkarCardState(
          adhkar: initialAzkar,
          currentCount: initialAzkar.count,
          initialCount: initialAzkar.count > 0 ? initialAzkar.count : 1,
        ));
  void decrementCount() {
    if (state.currentCount > 0) {
      state = state.copyWith(currentCount: state.currentCount - 1);
      HapticFeedback.lightImpact();
    }
  }

  void resetCount() {
    state = state.copyWith(currentCount: state.initialCount);
    HapticFeedback.mediumImpact();
  }
}

final azkarCardProvider = StateNotifierProvider.family
    .autoDispose<AzkarCardNotifier, AzkarCardState, AzkarModel>(
  (ref, adhkar) => AzkarCardNotifier(adhkar),
);
