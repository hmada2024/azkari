// lib/data/repositories/adhkar_repository.dart
import '../dao/azkar_dao.dart';
import '../dao/goal_dao.dart';
import '../dao/tasbih_dao.dart';
import '../dao/tasbih_progress_dao.dart'; // [جديد]
import '../models/azkar_model.dart';
import '../models/daily_goal_model.dart';
import '../models/tasbih_model.dart';

class AzkarRepository {
  final AzkarDao _azkarDao;
  final TasbihDao _tasbihDao;
  final GoalDao _goalDao;
  final TasbihProgressDao _tasbihProgressDao; // [جديد]

  AzkarRepository(
      this._azkarDao, this._tasbihDao, this._goalDao, this._tasbihProgressDao);

  // --- Azkar Methods ---
  Future<List<String>> getCategories() => _azkarDao.getCategories();
  Future<List<AzkarModel>> getAzkarByCategory(String category) =>
      _azkarDao.getAzkarByCategory(category);
  Future<List<AzkarModel>> getAzkarByIds(List<int> ids) =>
      _azkarDao.getAzkarByIds(ids);

  // --- Tasbih Methods ---
  Future<List<TasbihModel>> getCustomTasbihList() =>
      _tasbihDao.getCustomTasbihList();
  Future<TasbihModel> addTasbih(String text) => _tasbihDao.addTasbih(text);
  Future<void> deleteTasbih(int id) => _tasbihDao.deleteTasbih(id);
  Future<void> updateTasbihText(int id, String newText) =>
      _tasbihDao.updateTasbihText(id, newText);
  Future<void> updateSortOrders(Map<int, int> newOrders) =>
      _tasbihDao.updateSortOrders(newOrders);

  // --- Goal Methods (مُعدّلة) ---
  Future<void> setGoal(int tasbihId, int targetCount) =>
      _goalDao.setGoal(tasbihId, targetCount);
  Future<List<DailyGoalModel>> getGoalsWithProgressForDate(String date) =>
      _goalDao.getGoalsWithProgressForDate(date);
  Future<List<DailyGoalModel>> getTodayGoalsWithProgress() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return getGoalsWithProgressForDate(today);
  }

  // --- Tasbih Daily Progress Methods (جديدة) ---
  Future<void> incrementTasbihDailyCount(int tasbihId) =>
      _tasbihProgressDao.incrementCount(tasbihId);
  Future<Map<int, int>> getTodayTasbihCounts() =>
      _tasbihProgressDao.getTodayCounts();
  Future<Map<String, List<Map<String, dynamic>>>> getProgressForDateRange(
          String startDate, String endDate) =>
      _tasbihProgressDao.getProgressForDateRange(startDate, endDate);
}
