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

  // ✨ [إصلاح] تم تعديل الاستعلام ليعيد فقط الأذكار التي لها هدف محدد (JOIN)
  // بدلاً من كل الأذكار (LEFT JOIN).
  Future<List<DailyGoalModel>> getGoalsWithProgressForDate(String date) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT 
        t.id as tasbihId,
        t.text as tasbihText,
        g.target_count as targetCount,
        IFNULL(p.count, 0) as currentProgress
      FROM daily_goals g
      JOIN custom_tasbih t ON g.tasbih_id = t.id
      LEFT JOIN tasbih_daily_progress p ON g.tasbih_id = p.tasbih_id AND p.date = ?
      ORDER BY t.sort_order ASC, t.id ASC
    ''', [date]);

    return List.generate(maps.length, (i) => DailyGoalModel.fromMap(maps[i]));
  }

  /// ✨ [إصلاح] تم تعديل الاستعلام بالكامل ليحسب الهدف الإجمالي بشكل صحيح.
  Future<Map<String, double>> getMonthlyProgressSummary(
      String startDate, String endDate) async {
    // الخطوة 1: جلب مجموع التقدم اليومي
    final List<Map<String, dynamic>> progressResult = await _db.rawQuery('''
      SELECT 
        p.date,
        SUM(p.count) as totalProgress
      FROM tasbih_daily_progress p
      WHERE p.date BETWEEN ? AND ?
      GROUP BY p.date
    ''', [startDate, endDate]);

    // الخطوة 2: جلب مجموع الأهداف الكلي (لكل الأهداف المحددة في التطبيق)
    final totalTargetResult = await _db
        .rawQuery('SELECT SUM(target_count) as totalTarget FROM daily_goals');
    final int totalTarget =
        (totalTargetResult.first['totalTarget'] as int?) ?? 0;

    final Map<String, double> progressMap = {};
    if (totalTarget == 0) return progressMap; // لا يوجد أهداف، أعد خريطة فارغة

    for (var row in progressResult) {
      final date = row['date'] as String;
      final totalProgress = (row['totalProgress'] as int?) ?? 0;

      progressMap[date] = (totalProgress / totalTarget).clamp(0.0, 1.0);
    }
    return progressMap;
  }
}
