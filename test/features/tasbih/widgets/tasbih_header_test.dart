// test/features/tasbih/widgets/tasbih_header_test.dart

import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_header.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// استيراد وهمي لـ StateNotifier. لا يمكن استخدام mockito مباشرة مع StateNotifier
// لذا ننشئ نسخة وهمية بسيطة تفي بالغرض.
class MockTasbihStateNotifier extends StateNotifier<TasbihState>
    implements TasbihStateNotifier {
  MockTasbihStateNotifier() : super(TasbihState());

  int resetCountCalls = 0;

  @override
  Future<void> resetCount() async {
    resetCountCalls++;
  }

  // الدوال الأخرى غير ضرورية للاختبار الحالي
  @override
  Future<void> addTasbih(String text) async {}
  @override
  Future<void> deleteTasbih(int id) async {}
  @override
  Future<void> increment() async {}
  @override
  Future<void> setActiveTasbih(int id) async {}
  @override
  Future<void> noSuchMethod(Invocation invocation) async {
    // لمنع الأخطاء عند استدعاء دوال غير معرفة
  }
}

void main() {
  late MockTasbihStateNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockTasbihStateNotifier();
  });

  Future<void> pumpTasbihHeader(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasbihStateProvider.overrideWith((ref) => mockNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TasbihHeader(),
          ),
        ),
      ),
    );
  }

  group('TasbihHeader Interaction Tests', () {
    testWidgets('Tapping refresh icon calls resetCount() on the notifier',
        (WidgetTester tester) async {
      await pumpTasbihHeader(tester);

      // التحقق من أن الدالة لم تُستدعى بعد
      expect(mockNotifier.resetCountCalls, 0);

      // الضغط على أيقونة التصفير
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // التحقق من أن الدالة استُدعيت مرة واحدة
      expect(mockNotifier.resetCountCalls, 1);
    });

    testWidgets('Tapping list icon shows TasbihSelectionSheet',
        (WidgetTester tester) async {
      await pumpTasbihHeader(tester);

      // واجهة الاختيار غير موجودة في البداية
      expect(find.byType(TasbihSelectionSheet), findsNothing);

      // الضغط على أيقونة القائمة
      await tester.tap(find.byIcon(Icons.list_alt_rounded));
      // انتظار استقرار الواجهة بعد ظهور الـ BottomSheet
      await tester.pumpAndSettle();

      // التحقق من ظهور واجهة الاختيار
      expect(find.byType(TasbihSelectionSheet), findsOneWidget);
    });
  });
}
