// test/widget_test.dart
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/features/home/home_screen.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_header.dart';
import 'package:azkari/presentation/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

// ✨ استيراد وهمي تم إنشاؤه مسبقاً
import 'features/tasbih/daily_goals_provider_test.mocks.dart';

void main() {
  // ✨ تزييف الاعتماديات على مستوى أعلى
  late MockAdhkarRepository mockRepository;

  setUp(() {
    mockRepository = MockAdhkarRepository();
    // برمجة السلوك الافتراضي لكل الدوال التي سيتم استدعاؤها
    when(mockRepository.getCategories())
        .thenAnswer((_) async => ['أذكار الصباح']);
    when(mockRepository.getCustomTasbihList()).thenAnswer((_) async => [
          TasbihModel(
              id: 1, text: 'تسبيح وهمي', sortOrder: 1, isDeletable: false)
        ]);
    when(mockRepository.getAdhkarByIds(any)).thenAnswer((_) async => []);
    when(mockRepository.getGoalsWithTodayProgress())
        .thenAnswer((_) async => []);
  });

  Future<void> pumpAppShell(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // ✨ استبدال المستودع الحقيقي بالوهمي
          adhkarRepositoryProvider.overrideWithValue(mockRepository),
          // يمكنك أيضاً تزييف الـ providers الأخرى مباشرة إذا أردت
          // لكن تزييف المستودع هو الحل الأنظف
        ],
        child: const MaterialApp(
          home: AppShell(),
        ),
      ),
    );
    // الانتظار حتى تستقر الواجهة بعد حل جميع الـ Futures
    await tester.pumpAndSettle();
  }

  group('AppShell Widget Tests', () {
    testWidgets('Home screen is displayed by default',
        (WidgetTester tester) async {
      await pumpAppShell(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('أذكار الصباح'), findsOneWidget);
    });

    testWidgets('Tapping Tasbih tab navigates to TasbihScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpAppShell(tester);
      await tester.tap(find.byIcon(Icons.fingerprint));
      await tester.pumpAndSettle();

      expect(find.byType(TasbihHeader), findsOneWidget);
      expect(find.text('تسبيح وهمي'), findsOneWidget);
    });

    testWidgets('Tapping Favorites tab navigates to FavoritesScreen',
        (WidgetTester tester) async {
      await pumpAppShell(tester);

      await tester.tap(find.byIcon(Icons.star_border_outlined));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(Icons.star_border, skipOffstage: false), findsOneWidget);
      expect(find.text('لم تقم بإضافة أي ذكر إلى المفضلة بعد'), findsOneWidget);
    });
  });
}
