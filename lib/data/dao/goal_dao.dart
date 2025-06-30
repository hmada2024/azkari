// lib/data/dao/goal_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/daily_goal_model.dart';

class GoalDao {
  final Database _db;

  GoalDao(this._db);

  Future<void> setOrUpdateGoal(int tasbihId, int targetCount) async {
    await _db.insert(
      'daily_goals',
      {'tasbih_id': tasbihId, 'target_count': targetCount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeGoal(int tasbihId) async {
    await _db
        .delete('daily_goals', where: 'tasbih_id = ?', whereArgs: [tasbihId]);
  }

  Future<void> incrementGoalProgress(int goalId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _ensureTodayProgressRecordsForGoalId(_db, today, goalId);

    await _db.rawUpdate('''
      UPDATE goal_progress 
      SET current_count = current_count + 1 
      WHERE goal_id = ? AND date = ?
    ''', [goalId, today]);
  }

  Future<List<DailyGoalModel>> getGoalsWithTodayProgress() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _ensureAllTodayProgressRecords(_db, today);

    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT 
        g.id as goalId, 
        g.tasbih_id as tasbihId, 
        t.text as tasbihText, 
        g.target_count as targetCount, 
        p.current_count as currentProgress
      FROM daily_goals g
      JOIN custom_tasbih t ON g.tasbih_id = t.id
      LEFT JOIN goal_progress p ON g.id = p.goal_id AND p.date = ?
      ORDER BY t.sort_order ASC, t.id ASC
    ''', [today]);
    return List.generate(maps.length, (i) => DailyGoalModel.fromMap(maps[i]));
  }

  Future<void> _ensureAllTodayProgressRecords(Database db, String today) async {
    final List<Map<String, dynamic>> goals =
        await db.query('daily_goals', columns: ['id']);
    if (goals.isEmpty) return;
    final batch = db.batch();
    for (var goal in goals) {
      batch.insert(
        'goal_progress',
        {'goal_id': goal['id'], 'date': today, 'current_count': 0},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _ensureTodayProgressRecordsForGoalId(
      Database db, String today, int goalId) async {
    await db.insert(
      'goal_progress',
      {'goal_id': goalId, 'date': today, 'current_count': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Map<String, dynamic>?> getGoalForTasbih(int tasbihId) async {
    final result = await _db
        .query('daily_goals', where: 'tasbih_id = ?', whereArgs: [tasbihId]);
    return result.isNotEmpty ? result.first : null;
  }

  // ✨ [جديد] دالة لجلب إجمالي التقدم في نطاق زمني محدد
  Future<Map<String, int>> getProgressForDateRange(
      String startDate, String endDate) async {
    final List<Map<String, dynamic>> result = await _db.rawQuery('''
      SELECT date, SUM(current_count) as total_count
      FROM goal_progress
      WHERE date >= ? AND date <= ?
      GROUP BY date
      ORDER BY date ASC
    ''', [startDate, endDate]);

    return {for (var item in result) item['date']: item['total_count']};
  }
}
