// test/data/repositories/adhkar_repository_test.dart

import 'package:azkari/data/dao/adhkar_dao.dart';
import 'package:azkari/data/dao/goal_dao.dart';
import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/repositories/adhkar_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// سيتم استيراد الملف الذي سيتم إنشاؤه تلقائيًا
import 'adhkar_repository_test.mocks.dart';

// تفعيل إنشاء الملفات الوهمية للـ DAOs الجديدة
@GenerateMocks([AdhkarDao, TasbihDao, GoalDao])
void main() {
  late MockAdhkarDao mockAdhkarDao;
  late MockTasbihDao mockTasbihDao;
  late MockGoalDao mockGoalDao;
  late AdhkarRepository adhkarRepository;

  setUp(() {
    mockAdhkarDao = MockAdhkarDao();
    mockTasbihDao = MockTasbihDao();
    mockGoalDao = MockGoalDao();
    adhkarRepository =
        AdhkarRepository(mockAdhkarDao, mockTasbihDao, mockGoalDao);
  });

  group('AdhkarRepository Unit Tests', () {
    test('getCategories returns list of strings from AdhkarDao', () async {
      final mockCategories = ['أذكار الصباح', 'أذكار المساء'];
      when(mockAdhkarDao.getCategories())
          .thenAnswer((_) async => mockCategories);

      final categories = await adhkarRepository.getCategories();

      expect(categories, equals(mockCategories));
      verify(mockAdhkarDao.getCategories()).called(1);
    });

    test('setOrUpdateGoal calls the corresponding method in GoalDao', () async {
      // استخدام thenReturn مع Future.value() للدوال التي ترجع Future<void>
      when(mockGoalDao.setOrUpdateGoal(1, 100))
          .thenAnswer((_) async => Future.value());

      await adhkarRepository.setOrUpdateGoal(1, 100);

      verify(mockGoalDao.setOrUpdateGoal(1, 100)).called(1);
    });

    test('removeGoal calls the corresponding method in GoalDao', () async {
      when(mockGoalDao.removeGoal(1)).thenAnswer((_) async => Future.value());

      await adhkarRepository.removeGoal(1);

      verify(mockGoalDao.removeGoal(1)).called(1);
    });

    test('getGoalsWithTodayProgress forwards the call to GoalDao', () async {
      final mockGoals = [
        DailyGoalModel(
            goalId: 1,
            tasbihId: 1,
            tasbihText: 'Test',
            targetCount: 50,
            currentProgress: 10)
      ];
      when(mockGoalDao.getGoalsWithTodayProgress())
          .thenAnswer((_) async => mockGoals);

      final result = await adhkarRepository.getGoalsWithTodayProgress();

      expect(result, mockGoals);
      verify(mockGoalDao.getGoalsWithTodayProgress()).called(1);
    });
  });
}
