// test/features/tasbih/widgets/daily_goals_view_widget_test.dart

import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createTestableWidget(Override override) {
  return ProviderScope(
    overrides: [override],
    child: const MaterialApp(
      home: Scaffold(
        body: DailyGoalsView(),
      ),
    ),
  );
}

void main() {
  final mockGoals = [
    DailyGoalModel(
      tasbihId: 1,
      tasbihText: 'سبحان الله',
      targetCount: 100,
      currentProgress: 50,
    ),
    DailyGoalModel(
      tasbihId: 2,
      tasbihText: 'الحمد لله',
      targetCount: 33,
      currentProgress: 33,
    ),
  ];

  group('DailyGoalsView Widget Tests', () {
    testWidgets('shows loading indicator when provider is loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        dailyGoalsProvider
            .overrideWith((ref) => Future.delayed(const Duration(seconds: 5))),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error widget when provider has an error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        dailyGoalsProvider
            .overrideWith((ref) => Future.error('Failed to load')),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CustomErrorWidget), findsOneWidget);
    });

    testWidgets('shows nothing when data is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        dailyGoalsProvider.overrideWith((ref) => Future.value([])),
      ));
      await tester.pumpAndSettle();
      expect(find.text('أهدافي اليومية'), findsNothing);
    });

    testWidgets('displays goals correctly when data is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        dailyGoalsProvider.overrideWith((ref) => Future.value(mockGoals)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('أهدافي اليومية'), findsOneWidget);
      expect(find.text('سبحان الله'), findsOneWidget);
      expect(find.text('50 / 100'), findsOneWidget);
      final progressIndicator1 = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).first);
      expect(progressIndicator1.value, 0.5);

      expect(find.text('الحمد لله'), findsOneWidget);
      expect(find.text('33 / 33'), findsOneWidget);
      final progressIndicator2 = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).last);
      expect(progressIndicator2.value, 1.0);
      expect((progressIndicator2.valueColor as AlwaysStoppedAnimation).value,
          AppColors.success);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
