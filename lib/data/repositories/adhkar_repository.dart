// lib/data/repositories/adhkar_repository.dart
import '../dao/adhkar_dao.dart';
import '../dao/goal_dao.dart';
import '../dao/tasbih_dao.dart';
import '../models/adhkar_model.dart';
import '../models/daily_goal_model.dart';
import '../models/tasbih_model.dart';

/// طبقة المستودع التي تعمل كوسيط بين منطق التطبيق (Features) و طبقة الوصول للبيانات (DAOs).
/// هذا الفصل يسمح بتغيير مصدر البيانات دون التأثير على منطق التطبيق.
class AdhkarRepository {
  final AdhkarDao _adhkarDao;
  final TasbihDao _tasbihDao;
  final GoalDao _goalDao;

  AdhkarRepository(this._adhkarDao, this._tasbihDao, this._goalDao);

  // --- Adhkar Methods ---
  Future<List<String>> getCategories() => _adhkarDao.getCategories();
  Future<List<AdhkarModel>> getAdhkarByCategory(String category) =>
      _adhkarDao.getAdhkarByCategory(category);
  Future<List<AdhkarModel>> getAdhkarByIds(List<int> ids) =>
      _adhkarDao.getAdhkarByIds(ids);

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
}
