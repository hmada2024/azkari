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

  // مشتقات محسوبة لتسهيل الاستخدام في الواجهة
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

/// 2. المتحكم/المنطق (Notifier): يدير الحالة وينفذ الأوامر.
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

/// 3. الرابط (Provider): يقوم بإنشاء Notifier لكل بطاقة على حدة.
/// نستخدم `.family` لأن كل بطاقة تحتاج إلى نسخة خاصة بها من الـ Notifier.
/// نستخدم `.autoDispose` لحذف الـ Notifier من الذاكرة عندما تختفي البطاقة من الشاشة.
final adhkarCardProvider = StateNotifierProvider.family
    .autoDispose<AzkarCardNotifier, AzkarCardState, AzkarModel>(
  (ref, adhkar) => AzkarCardNotifier(adhkar),
);
