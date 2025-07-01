// lib/data/repositories/goals_repository.dart

import '../dao/goal_dao.dart';
import '../dao/tasbih_progress_dao.dart';
import '../models/daily_goal_model.dart';

/// مستودع متخصص مسؤول عن إدارة الأهداف والتقدم اليومي المرتبط بها.
class GoalsRepository {
  final GoalDao _goalDao;
  final TasbihProgressDao _tasbihProgressDao;

  GoalsRepository(this._goalDao, this._tasbihProgressDao);

  // --- Goal Methods ---
  Future<void> setGoal(int tasbihId, int targetCount) =>
      _goalDao.setGoal(tasbihId, targetCount);

  Future<List<DailyGoalModel>> getGoalsWithProgressForDate(String date) =>
      _goalDao.getGoalsWithProgressForDate(date);

  Future<List<DailyGoalModel>> getTodayGoalsWithProgress() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return getGoalsWithProgressForDate(today);
  }

  Future<Map<String, double>> getMonthlyProgressSummary(
          String startDate, String endDate) =>
      _goalDao.getMonthlyProgressSummary(startDate, endDate);

  // --- Tasbih Daily Progress Methods ---
  Future<void> incrementTasbihDailyCount(int tasbihId) =>
      _tasbihProgressDao.incrementCount(tasbihId);

  Future<Map<int, int>> getTodayTasbihCounts() =>
      _tasbihProgressDao.getTodayCounts();
}
