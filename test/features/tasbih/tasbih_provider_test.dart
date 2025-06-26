// test/features/tasbih/tasbih_provider_test.dart
// ✨ [إصلاح]: تم إزالة الشرطة السفلية `_` من اسم الدالة المحلية `waitForStateLoading`
// لتتوافق مع قواعد الـ Linter في Flutter.
import 'package:flutter_test/flutter_test.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TasbihStateNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ✨ [إصلاح]: تمت إزالة الشرطة السفلية من اسم الدالة.
    Future<void> waitForStateLoading(ProviderContainer container) async {
      // هذه الدالة الصغيرة تساعدنا على انتظار اكتمال العمليات الأولية (async) في الـ notifier.
      container.read(tasbihStateProvider.notifier);
      await Future.delayed(Duration.zero);
    }

    test('Initial state count should be 0 after loading', () async {
      final container = ProviderContainer();
      // ✨ تم تحديث اسم الدالة هنا أيضاً.
      await waitForStateLoading(container);

      final state = container.read(tasbihStateProvider);
      expect(state.count, 0);

      container.dispose();
    });

    test('increment() should increase count by 1', () async {
      final container = ProviderContainer();
      await waitForStateLoading(container);

      container.read(tasbihStateProvider.notifier).increment();

      final state = container.read(tasbihStateProvider);
      expect(state.count, 1);

      container.dispose();
    });

    test('resetCount() should reset count to 0', () async {
      final container = ProviderContainer();
      await waitForStateLoading(container);

      final notifier = container.read(tasbihStateProvider.notifier);
      notifier.increment();
      notifier.increment();
      expect(container.read(tasbihStateProvider).count, 2);

      notifier.resetCount();

      expect(container.read(tasbihStateProvider).count, 0);

      container.dispose();
    });

    test('setActiveTasbih() should set new active ID and reset count',
        () async {
      final container = ProviderContainer();
      await waitForStateLoading(container);

      final notifier = container.read(tasbihStateProvider.notifier);
      notifier.increment();

      notifier.setActiveTasbih(123);

      final state = container.read(tasbihStateProvider);
      expect(state.activeTasbihId, 123);
      expect(state.count, 0);

      container.dispose();
    });
  });
}
