// test/features/tasbih/widgets/daily_goals_view_test.dart
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/tasbih/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDailyGoalsView(
    WidgetTester tester, {
    required Future<List<DailyGoalModel>> Function(Ref) goalsProviderOverride,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyGoalsProvider.overrideWith(goalsProviderOverride),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DailyGoalsView(),
          ),
        ),
      ),
    );
  }

  group('DailyGoalsView Widget Tests', () {
    // ... الاختبارات الأخرى تبقى كما هي ...
    testWidgets('displays goals correctly when data is available',
        (WidgetTester tester) async {
      final mockGoals = [
        DailyGoalModel(
            goalId: 1,
            tasbihId: 10,
            tasbihText: 'سبحان الله',
            targetCount: 100,
            currentProgress: 50),
        DailyGoalModel(
            goalId: 2,
            tasbihId: 11,
            tasbihText: 'الحمد لله',
            targetCount: 100,
            currentProgress: 100),
      ];
      await pumpDailyGoalsView(tester,
          goalsProviderOverride: (ref) => Future.value(mockGoals));
      await tester.pumpAndSettle();

      expect(find.text('أهدافي اليومية'), findsOneWidget);

      // ✨ [الإصلاح النهائي]
      // 1. ابحث عن صف الهدف غير المكتمل
      final incompleteGoalRow = find.ancestor(
          of: find.text('سبحان الله'), matching: find.byType(Row));
      // 2. ابحث عن صف الهدف المكتمل
      final completedGoalRow =
          find.ancestor(of: find.text('الحمد لله'), matching: find.byType(Row));

      // 3. تحقق من عدم وجود أيقونة الصح في الصف الأول
      expect(
          find.descendant(
              of: incompleteGoalRow, matching: find.byIcon(Icons.check_circle)),
          findsNothing);
      // 4. تحقق من وجود أيقونة الصح في الصف الثاني
      expect(
          find.descendant(
              of: completedGoalRow, matching: find.byIcon(Icons.check_circle)),
          findsOneWidget);
    });
  });
}
