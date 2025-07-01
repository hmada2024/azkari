// test/data/dao/goal_dao_test.dart

import 'package:azkari/data/dao/goal_dao.dart';
import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/dao/tasbih_progress_dao.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import '../../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database db;
  late GoalDao goalDao;
  late TasbihDao tasbihDao;
  late TasbihProgressDao progressDao;

  setUp(() async {
    db = await setupTestDatabase();
    goalDao = GoalDao(db);
    tasbihDao = TasbihDao(db);
    progressDao = TasbihProgressDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('GoalDao Tests', () {
    test('setGoal should insert a new goal', () async {
      // Arrange
      final newTasbih = await tasbihDao.addTasbih('Test Tasbih');
      const target = 100;

      // Act
      await goalDao.setGoal(newTasbih.id, target);

      // Assert
      final result = await db.query('daily_goals',
          where: 'tasbih_id = ?', whereArgs: [newTasbih.id]);
      expect(result, isNotEmpty);
      expect(result.first['target_count'], target);
    });

    test('setGoal with count <= 0 should remove the goal', () async {
      // Arrange
      final newTasbih = await tasbihDao.addTasbih('Test Tasbih');
      await goalDao.setGoal(newTasbih.id, 100);

      // Act
      await goalDao.setGoal(newTasbih.id, 0);

      // Assert
      final result = await db.query('daily_goals',
          where: 'tasbih_id = ?', whereArgs: [newTasbih.id]);
      expect(result, isEmpty);
    });

    test('removeGoal should delete the specified goal', () async {
      // Arrange
      final newTasbih = await tasbihDao.addTasbih('Test Tasbih');
      await goalDao.setGoal(newTasbih.id, 50);

      // Act
      await goalDao.removeGoal(newTasbih.id);

      // Assert
      final result = await db.query('daily_goals',
          where: 'tasbih_id = ?', whereArgs: [newTasbih.id]);
      expect(result, isEmpty);
    });

    // ✨ [إصلاح] الاختبار الآن يتوقع فقط الأهداف التي تم إنشاؤها في هذا الاختبار
    test('getGoalsWithProgressForDate should return ONLY goals with progress',
        () async {
      // Arrange
      // مسح الأهداف الافتراضية لضمان بيئة اختبار نظيفة ومعزولة
      await db.delete('daily_goals');

      final tasbih1 = await tasbihDao.addTasbih('Tasbih 1');
      final tasbih2 = await tasbihDao.addTasbih('Tasbih 2');
      final tasbih3 =
          await tasbihDao.addTasbih('Tasbih 3 No Goal'); // ذكر بدون هدف

      await goalDao.setGoal(tasbih1.id, 100); // هدف 1
      await goalDao.setGoal(tasbih2.id, 50); // هدف 2

      for (int i = 0; i < 10; i++) {
        await progressDao.incrementCount(tasbih1.id);
      }

      final today = DateTime.now().toIso8601String().substring(0, 10);

      // Act
      final goalsWithProgress =
          await goalDao.getGoalsWithProgressForDate(today);

      // Assert
      expect(goalsWithProgress, isA<List<DailyGoalModel>>());
      // يجب أن يعيد فقط الأذكار التي لها أهداف محددة
      expect(goalsWithProgress.length, 2);
      expect(goalsWithProgress.any((g) => g.tasbihId == tasbih3.id), isFalse);

      final goal1 =
          goalsWithProgress.firstWhere((g) => g.tasbihId == tasbih1.id);
      expect(goal1.targetCount, 100);
      expect(goal1.currentProgress, 10);

      final goal2 =
          goalsWithProgress.firstWhere((g) => g.tasbihId == tasbih2.id);
      expect(goal2.targetCount, 50);
      expect(goal2.currentProgress, 0);
    });

    // ✨ [إصلاح] تم تعديل الاختبار ليعكس المنطق الجديد والأكثر صحة
    test(
        'getMonthlyProgressSummary should calculate daily completion percentage correctly',
        () async {
      // Arrange
      // مسح الأهداف الافتراضية
      await db.delete('daily_goals');

      final tasbih1 = await tasbihDao.addTasbih('Tasbih 1');
      final tasbih2 = await tasbihDao.addTasbih('Tasbih 2');
      await goalDao.setGoal(tasbih1.id, 100);
      await goalDao.setGoal(tasbih2.id, 100);
      // الهدف الإجمالي الآن هو 200

      // إضافة تقدم لليوم الحالي (تقدم 50 من أصل إجمالي 200)
      for (int i = 0; i < 50; i++) {
        await progressDao.incrementCount(tasbih1.id);
      }

      final today = DateTime.now();
      final todayStr = today.toIso8601String().substring(0, 10);
      final startDateStr = DateTime(today.year, today.month, 1)
          .toIso8601String()
          .substring(0, 10);
      final endDateStr = DateTime(today.year, today.month + 1, 0)
          .toIso8601String()
          .substring(0, 10);

      // Act
      final summary =
          await goalDao.getMonthlyProgressSummary(startDateStr, endDateStr);

      // Assert
      expect(summary, isNotNull);
      expect(summary.containsKey(todayStr), isTrue);
      // النسبة المتوقعة هي 50 (التقدم) / 200 (الهدف الإجمالي) = 0.25
      expect(summary[todayStr], moreOrLessEquals(0.25));
    });
  });
}
