// lib/features/adhkar_list/providers/adhkar_card_provider.dart
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class AdhkarCardState {
  final AdhkarModel adhkar;
  final int currentCount;
  final int initialCount;

  const AdhkarCardState({
    required this.adhkar,
    required this.currentCount,
    required this.initialCount,
  });

  // مشتقات محسوبة لتسهيل الاستخدام في الواجهة
  bool get isFinished => currentCount == 0;
  double get progress => (initialCount - currentCount) / initialCount;

  AdhkarCardState copyWith({
    AdhkarModel? adhkar,
    int? currentCount,
    int? initialCount,
  }) {
    return AdhkarCardState(
      adhkar: adhkar ?? this.adhkar,
      currentCount: currentCount ?? this.currentCount,
      initialCount: initialCount ?? this.initialCount,
    );
  }
}

/// 2. المتحكم/المنطق (Notifier): يدير الحالة وينفذ الأوامر.
class AdhkarCardNotifier extends StateNotifier<AdhkarCardState> {
  AdhkarCardNotifier(AdhkarModel initialAdhkar)
      : super(AdhkarCardState(
          adhkar: initialAdhkar,
          currentCount: initialAdhkar.count,
          initialCount: initialAdhkar.count > 0 ? initialAdhkar.count : 1,
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
    .autoDispose<AdhkarCardNotifier, AdhkarCardState, AdhkarModel>(
  (ref, adhkar) => AdhkarCardNotifier(adhkar),
);
