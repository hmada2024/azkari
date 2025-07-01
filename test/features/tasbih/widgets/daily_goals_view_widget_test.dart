// test/features/tasbih/widgets/daily_goals_view_widget_test.dart

import 'dart:async';
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/features/progress/providers/daily_goals_provider.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ✨ [إصلاح] تم حذف المتغير غير المستخدم.

  Widget createTestableWidget(Override override) {
    return ProviderScope(
      overrides: [override],
      child: const MaterialApp(home: Scaffold(body: DailyGoalsView())),
    );
  }

  group('DailyGoalsView Widget Tests', () {
    testWidgets('shows loading indicator when provider is loading',
        (WidgetTester tester) async {
      final completer = Completer<List<DailyGoalModel>>();
      await tester.pumpWidget(createTestableWidget(
        dailyGoalsProvider.overrideWith((ref) => completer.future),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error widget when provider has an error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        dailyGoalsProvider.overrideWith((ref) => Future.error('Failed')),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CustomErrorWidget), findsOneWidget);
    });
  });
}
