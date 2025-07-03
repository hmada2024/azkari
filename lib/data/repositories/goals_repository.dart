// lib/data/repositories/goals_repository.dart
import 'package:azkari/data/models/managed_goal_model.dart';
import '../dao/goal_dao.dart';
import '../dao/tasbih_progress_dao.dart';
import '../models/daily_goal_model.dart';

class GoalsRepository {
  final GoalDao _goalDao;
  final TasbihProgressDao _tasbihProgressDao;
  GoalsRepository(this._goalDao, this._tasbihProgressDao);

  Future<void> setGoal(int tasbihId, int targetCount) =>
      _goalDao.setGoal(tasbihId, targetCount);

  Future<void> activateGoal(int tasbihId, int targetCount) =>
      _goalDao.setGoal(tasbihId, targetCount);

  Future<void> deactivateGoal(int tasbihId) => _goalDao.removeGoal(tasbihId);

  Future<List<ManagedGoal>> getManagedGoals() => _goalDao.getManagedGoals();

  Future<List<DailyGoalModel>> getGoalsWithProgressForDate(String date) =>
      _goalDao.getGoalsWithProgressForDate(date);

  Future<List<DailyGoalModel>> getTodayGoalsWithProgress() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return getGoalsWithProgressForDate(today);
  }

  Future<Map<String, double>> getMonthlyProgressSummary(
          String startDate, String endDate) =>
      _goalDao.getMonthlyProgressSummary(startDate, endDate);

  Future<void> incrementTasbihDailyCount(int tasbihId) =>
      _tasbihProgressDao.incrementCount(tasbihId);

  Future<void> resetDailyCountForTasbih(int tasbihId) =>
      _tasbihProgressDao.resetCountForTasbih(tasbihId);

  Future<Map<int, int>> getTodayTasbihCounts() =>
      _tasbihProgressDao.getTodayCounts();
}
