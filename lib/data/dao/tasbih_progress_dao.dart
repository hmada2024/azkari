// lib/data/dao/tasbih_progress_dao.dart
import 'package:azkari/core/constants/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class TasbihProgressDao {
  final Database _db;
  TasbihProgressDao(this._db);
  final String _today = DateTime.now().toIso8601String().substring(0, 10);

  Future<void> incrementCount(int tasbihId) async {
    await _db.transaction((txn) async {
      await txn.insert(
        DbConstants.tasbihDailyProgress.name,
        {
          DbConstants.tasbihDailyProgress.colTasbihId: tasbihId,
          DbConstants.tasbihDailyProgress.colDate: _today,
          DbConstants.tasbihDailyProgress.colCount: 0
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.rawUpdate('''
        UPDATE ${DbConstants.tasbihDailyProgress.name} 
        SET ${DbConstants.tasbihDailyProgress.colCount} = ${DbConstants.tasbihDailyProgress.colCount} + 1 
        WHERE ${DbConstants.tasbihDailyProgress.colTasbihId} = ? AND ${DbConstants.tasbihDailyProgress.colDate} = ?
      ''', [tasbihId, _today]);
    });
  }

  Future<void> resetCountForTasbih(int tasbihId) async {
    await _db.update(
      DbConstants.tasbihDailyProgress.name,
      {DbConstants.tasbihDailyProgress.colCount: 0},
      where:
          '${DbConstants.tasbihDailyProgress.colTasbihId} = ? AND ${DbConstants.tasbihDailyProgress.colDate} = ?',
      whereArgs: [tasbihId, _today],
    );
  }

  Future<Map<int, int>> getTodayCounts() async {
    final List<Map<String, dynamic>> result = await _db.query(
      DbConstants.tasbihDailyProgress.name,
      columns: [
        DbConstants.tasbihDailyProgress.colTasbihId,
        DbConstants.tasbihDailyProgress.colCount
      ],
      where: '${DbConstants.tasbihDailyProgress.colDate} = ?',
      whereArgs: [_today],
    );
    if (result.isEmpty) return {};
    return {
      for (var item in result)
        item[DbConstants.tasbihDailyProgress.colTasbihId]:
            item[DbConstants.tasbihDailyProgress.colCount]
    };
  }

  Future<Map<String, List<Map<String, dynamic>>>> getProgressForDateRange(
      String startDate, String endDate) async {
    final query = '''
      SELECT 
        p.${DbConstants.tasbihDailyProgress.colDate},
        g.${DbConstants.dailyGoals.colTargetCount} as target,
        p.${DbConstants.tasbihDailyProgress.colCount} as progress
      FROM ${DbConstants.tasbihDailyProgress.name} p
      JOIN ${DbConstants.dailyGoals.name} g ON p.${DbConstants.tasbihDailyProgress.colTasbihId} = g.${DbConstants.dailyGoals.colTasbihId}
      WHERE p.${DbConstants.tasbihDailyProgress.colDate} >= ? AND p.${DbConstants.tasbihDailyProgress.colDate} <= ?
    ''';
    final List<Map<String, dynamic>> result =
        await _db.rawQuery(query, [startDate, endDate]);
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var row in result) {
      String date = row[DbConstants.tasbihDailyProgress.colDate];
      if (!groupedByDate.containsKey(date)) {
        groupedByDate[date] = [];
      }
      groupedByDate[date]!
          .add({'target': row['target'], 'progress': row['progress']});
    }
    return groupedByDate;
  }
}
