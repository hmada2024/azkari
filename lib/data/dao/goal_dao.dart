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
        IFNULL(p.count, 0) as currentProgress
      FROM custom_tasbih t
      JOIN daily_goals g ON t.id = g.tasbih_id
      LEFT JOIN tasbih_daily_progress p ON t.id = p.tasbih_id AND p.date = ?
      ORDER BY t.sort_order ASC, t.id ASC
    ''', [date]);

    return List.generate(maps.length, (i) => DailyGoalModel.fromMap(maps[i]));
  }

  /// ✨ [جديد] دالة محسّنة لجلب ملخص التقدم الشهري باستعلام واحد فقط.
  /// تعالج هذه الدالة مشكلة "N+1 Query" بشكل كامل.
  Future<Map<String, double>> getMonthlyProgressSummary(
      String startDate, String endDate) async {
    final List<Map<String, dynamic>> result = await _db.rawQuery('''
      SELECT 
        p.date,
        SUM(p.count) as totalProgress,
        (SELECT SUM(target_count) FROM daily_goals WHERE tasbih_id IN (SELECT tasbih_id FROM tasbih_daily_progress WHERE date = p.date)) as totalTarget
      FROM tasbih_daily_progress p
      WHERE p.date BETWEEN ? AND ?
      GROUP BY p.date
    ''', [startDate, endDate]);

    final Map<String, double> progressMap = {};
    for (var row in result) {
      final date = row['date'] as String;
      final totalProgress = (row['totalProgress'] as int?) ?? 0;
      final totalTarget = (row['totalTarget'] as int?) ?? 0;

      if (totalTarget > 0) {
        progressMap[date] = (totalProgress / totalTarget).clamp(0.0, 1.0);
      } else {
        // إذا لم يكن هناك هدف محدد لذلك اليوم، نعتبره مكتملاً
        progressMap[date] = 1.0;
      }
    }
    return progressMap;
  }
}
