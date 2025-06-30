// lib/data/dao/goal_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/daily_goal_model.dart';

class GoalDao {
  final Database _db;
  GoalDao(this._db);

  Future<void> setGoal(int tasbihId, int targetCount) async {
    if (targetCount <= 0) {
      await removeGoal(tasbihId);
    } else {
      await _db.insert(
        'daily_goals',
        {'tasbih_id': tasbihId, 'target_count': targetCount},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> removeGoal(int tasbihId) async {
    await _db
        .delete('daily_goals', where: 'tasbih_id = ?', whereArgs: [tasbihId]);
  }

  Future<List<DailyGoalModel>> getGoalsWithProgressForDate(String date) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT 
        t.id as tasbihId,
        t.text as tasbihText,
        g.target_count as targetCount,
        -- [تصحيح] استخدام IFNULL لضمان إرجاع 0 بدلاً من NULL
        IFNULL(p.count, 0) as currentProgress
      FROM custom_tasbih t
      JOIN daily_goals g ON t.id = g.tasbih_id
      LEFT JOIN tasbih_daily_progress p ON t.id = p.tasbih_id AND p.date = ?
      ORDER BY t.sort_order ASC, t.id ASC
    ''', [date]);

    return List.generate(maps.length, (i) => DailyGoalModel.fromMap(maps[i]));
  }
}
