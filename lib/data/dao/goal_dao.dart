// lib/data/dao/goal_dao.dart
import 'package:azkari/core/constants/database_constants.dart';
import 'package:azkari/data/models/managed_goal_model.dart';
import 'package:sqflite/sqflite.dart';
import '../models/daily_goal_model.dart';

class GoalDao {
  final Database _db;
  GoalDao(this._db);

  Future<void> setGoal(int tasbihId, int targetCount) async {
    await _db.insert(
      DbConstants.dailyGoals.name,
      {
        DbConstants.dailyGoals.colTasbihId: tasbihId,
        DbConstants.dailyGoals.colTargetCount: targetCount
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeGoal(int tasbihId) async {
    await _db.delete(DbConstants.dailyGoals.name,
        where: '${DbConstants.dailyGoals.colTasbihId} = ?',
        whereArgs: [tasbihId]);
  }

  Future<List<ManagedGoal>> getManagedGoals() async {
    final query = '''
      SELECT
        t.${DbConstants.customTasbih.colId},
        t.${DbConstants.customTasbih.colText},
        t.${DbConstants.customTasbih.colSortOrder},
        t.${DbConstants.customTasbih.colIsDefault},
        g.${DbConstants.dailyGoals.colTargetCount}
      FROM ${DbConstants.customTasbih.name} t
      LEFT JOIN ${DbConstants.dailyGoals.name} g ON t.${DbConstants.customTasbih.colId} = g.${DbConstants.dailyGoals.colTasbihId}
      ORDER BY t.${DbConstants.customTasbih.colSortOrder} ASC
    ''';
    final List<Map<String, dynamic>> maps = await _db.rawQuery(query);
    return List.generate(maps.length, (i) => ManagedGoal.fromMap(maps[i]));
  }

  Future<List<DailyGoalModel>> getGoalsWithProgressForDate(String date) async {
    final query = '''
      SELECT 
        t.${DbConstants.customTasbih.colId} as tasbihId,
        t.${DbConstants.customTasbih.colText} as tasbihText,
        g.${DbConstants.dailyGoals.colTargetCount} as targetCount,
        IFNULL(p.${DbConstants.tasbihDailyProgress.colCount}, 0) as currentProgress
      FROM ${DbConstants.dailyGoals.name} g
      JOIN ${DbConstants.customTasbih.name} t ON g.${DbConstants.dailyGoals.colTasbihId} = t.${DbConstants.customTasbih.colId}
      LEFT JOIN ${DbConstants.tasbihDailyProgress.name} p ON g.${DbConstants.dailyGoals.colTasbihId} = p.${DbConstants.tasbihDailyProgress.colTasbihId} AND p.${DbConstants.tasbihDailyProgress.colDate} = ?
      ORDER BY t.${DbConstants.customTasbih.colSortOrder} ASC, t.${DbConstants.customTasbih.colId} ASC
    ''';
    final List<Map<String, dynamic>> maps = await _db.rawQuery(query, [date]);
    return List.generate(maps.length, (i) => DailyGoalModel.fromMap(maps[i]));
  }

  Future<Map<String, double>> getMonthlyProgressSummary(
      String startDate, String endDate) async {
    final progressQuery = '''
      SELECT 
        p.${DbConstants.tasbihDailyProgress.colDate},
        SUM(p.${DbConstants.tasbihDailyProgress.colCount}) as totalProgress
      FROM ${DbConstants.tasbihDailyProgress.name} p
      WHERE p.${DbConstants.tasbihDailyProgress.colDate} BETWEEN ? AND ?
      GROUP BY p.${DbConstants.tasbihDailyProgress.colDate}
    ''';
    final List<Map<String, dynamic>> progressResult =
        await _db.rawQuery(progressQuery, [startDate, endDate]);
    final totalTargetQuery =
        'SELECT SUM(${DbConstants.dailyGoals.colTargetCount}) as totalTarget FROM ${DbConstants.dailyGoals.name}';
    final totalTargetResult = await _db.rawQuery(totalTargetQuery);
    final int totalTarget =
        (totalTargetResult.first['totalTarget'] as int?) ?? 0;
    final Map<String, double> progressMap = {};
    if (totalTarget == 0) return progressMap;
    for (var row in progressResult) {
      final date = row[DbConstants.tasbihDailyProgress.colDate] as String;
      final totalProgress = (row['totalProgress'] as int?) ?? 0;
      progressMap[date] = (totalProgress / totalTarget).clamp(0.0, 1.0);
    }
    return progressMap;
  }
}
