// lib/data/repositories/adhkar_repository.dart
import '../dao/adhkar_dao.dart';
import '../dao/goal_dao.dart';
import '../dao/tasbih_dao.dart';
import '../models/adhkar_model.dart';
import '../models/daily_goal_model.dart';
import '../models/tasbih_model.dart';

class AzkarRepository {
  final AzkarDao _adhkarDao;
  final TasbihDao _tasbihDao;
  final GoalDao _goalDao;

  AzkarRepository(this._adhkarDao, this._tasbihDao, this._goalDao);

  // --- Azkar Methods ---
  Future<List<String>> getCategories() => _adhkarDao.getCategories();
  Future<List<AzkarModel>> getAzkarByCategory(String category) =>
      _adhkarDao.getAzkarByCategory(category);
  Future<List<AzkarModel>> getAzkarByIds(List<int> ids) =>
      _adhkarDao.getAzkarByIds(ids);

  // --- Tasbih Methods ---
  Future<List<TasbihModel>> getCustomTasbihList() =>
      _tasbihDao.getCustomTasbihList();
  Future<TasbihModel> addTasbih(String text) => _tasbihDao.addTasbih(text);
  Future<void> deleteTasbih(int id) => _tasbihDao.deleteTasbih(id);
  Future<void> updateTasbihText(int id, String newText) =>
      _tasbihDao.updateTasbihText(id, newText);
  Future<void> updateSortOrders(Map<int, int> newOrders) =>
      _tasbihDao.updateSortOrders(newOrders);

  // --- Goal Methods ---
  Future<void> setOrUpdateGoal(int tasbihId, int targetCount) =>
      _goalDao.setOrUpdateGoal(tasbihId, targetCount);
  Future<void> removeGoal(int tasbihId) => _goalDao.removeGoal(tasbihId);
  Future<void> incrementGoalProgress(int goalId) =>
      _goalDao.incrementGoalProgress(goalId);
  Future<List<DailyGoalModel>> getGoalsWithTodayProgress() =>
      _goalDao.getGoalsWithTodayProgress();
  Future<Map<String, dynamic>?> getGoalForTasbih(int tasbihId) =>
      _goalDao.getGoalForTasbih(tasbihId);

  Future<Map<String, int>> getProgressForDateRange(
          String startDate, String endDate) =>
      _goalDao.getProgressForDateRange(startDate, endDate);
}
