// test/data/repositories/adhkar_repository_test.dart

import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/repositories/adhkar_repository.dart';
import 'package:azkari/data/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// تحديث الملف الوهمي لـ DatabaseHelper
import 'adhkar_repository_test.mocks.dart';

// تفعيل إنشاء الملف الوهمي
@GenerateMocks([DatabaseHelper])
void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late AdhkarRepository adhkarRepository;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    adhkarRepository = AdhkarRepository(mockDatabaseHelper);
  });

  group('AdhkarRepository Unit Tests', () {
    // ... الاختبارات القديمة تبقى كما هي ...

    test('getCategories returns list of strings from DatabaseHelper', () async {
      final mockCategories = ['أذكار الصباح', 'أذكار المساء'];
      when(mockDatabaseHelper.getCategories())
          .thenAnswer((_) async => mockCategories);

      final categories = await adhkarRepository.getCategories();

      expect(categories, equals(mockCategories));
      verify(mockDatabaseHelper.getCategories()).called(1);
    });

    // --- ✨ اختبارات جديدة للميزة الجديدة ---

    test('setOrUpdateGoal calls the corresponding method in DatabaseHelper',
        () async {
      // الإعداد (Arrange)
      when(mockDatabaseHelper.setOrUpdateGoal(1, 100)).thenAnswer((_) async {});

      // التنفيذ (Act)
      await adhkarRepository.setOrUpdateGoal(1, 100);

      // التحقق (Assert)
      verify(mockDatabaseHelper.setOrUpdateGoal(1, 100)).called(1);
    });

    test('removeGoal calls the corresponding method in DatabaseHelper',
        () async {
      // الإعداد (Arrange)
      when(mockDatabaseHelper.removeGoal(1)).thenAnswer((_) async {});

      // التنفيذ (Act)
      await adhkarRepository.removeGoal(1);

      // التحقق (Assert)
      verify(mockDatabaseHelper.removeGoal(1)).called(1);
    });

    test('getGoalsWithTodayProgress forwards the call to DatabaseHelper',
        () async {
      // الإعداد (Arrange)
      final mockGoals = [
        DailyGoalModel(
            goalId: 1,
            tasbihId: 1,
            tasbihText: 'Test',
            targetCount: 50,
            currentProgress: 10)
      ];
      when(mockDatabaseHelper.getGoalsWithTodayProgress())
          .thenAnswer((_) async => mockGoals);

      // التنفيذ (Act)
      final result = await adhkarRepository.getGoalsWithTodayProgress();

      // التحقق (Assert)
      expect(result, mockGoals);
      verify(mockDatabaseHelper.getGoalsWithTodayProgress()).called(1);
    });
  });
}
