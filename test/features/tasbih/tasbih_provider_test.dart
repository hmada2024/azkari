// test/features/tasbih/tasbih_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TasbihStateNotifier Tests', () {
    ProviderContainer createContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container;
    }

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state count should be 0 after loading', () async {
      final container = createContainer();
      container.read(tasbihStateProvider.notifier);
      await Future.value();

      final state = container.read(tasbihStateProvider);
      expect(state.count, 0);
    });

    test('increment() should increase count by 1', () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);

      await notifier.increment();

      final state = container.read(tasbihStateProvider);
      expect(state.count, 1);
    });

    test('resetCount() should reset count to 0', () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);

      await notifier.increment();
      await notifier.increment();

      await notifier.resetCount();

      expect(container.read(tasbihStateProvider).count, 0);
    });

    test('setActiveTasbih() should set new active ID and reset count',
        () async {
      final container = createContainer();
      final notifier = container.read(tasbihStateProvider.notifier);

      await notifier.increment();

      await notifier.setActiveTasbih(123);

      final state = container.read(tasbihStateProvider);
      expect(state.activeTasbihId, 123);
      expect(state.count, 0);
    });
  });
}
