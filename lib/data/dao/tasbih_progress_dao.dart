// lib/data/dao/tasbih_progress_dao.dart
import 'package:sqflite/sqflite.dart';

class TasbihProgressDao {
  final Database _db;
  TasbihProgressDao(this._db);

  final String _today = DateTime.now().toIso8601String().substring(0, 10);

  // [مهم] دالة تزيد العداد لذكر معين في اليوم الحالي
  Future<void> incrementCount(int tasbihId) async {
    // تأكد من وجود سجل لليوم الحالي، إذا لم يكن موجوداً قم بإنشائه
    await _db.insert(
      'tasbih_daily_progress',
      {'tasbih_id': tasbihId, 'date': _today, 'count': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // قم بزيادة العداد
    await _db.rawUpdate('''
      UPDATE tasbih_daily_progress 
      SET count = count + 1 
      WHERE tasbih_id = ? AND date = ?
    ''', [tasbihId, _today]);
  }

  // [مهم] دالة لجلب جميع عدادات اليوم الحالي
  Future<Map<int, int>> getTodayCounts() async {
    final List<Map<String, dynamic>> result = await _db.query(
      'tasbih_daily_progress',
      columns: ['tasbih_id', 'count'],
      where: 'date = ?',
      whereArgs: [_today],
    );

    if (result.isEmpty) return {};
    return {for (var item in result) item['tasbih_id']: item['count']};
  }

  // دالة لجلب التقدم في نطاق زمني (مفيدة للإحصائيات)
  Future<Map<String, List<Map<String, dynamic>>>> getProgressForDateRange(
      String startDate, String endDate) async {
    final List<Map<String, dynamic>> result = await _db.rawQuery('''
      SELECT 
        p.date,
        g.target_count as target,
        p.count as progress
      FROM tasbih_daily_progress p
      JOIN daily_goals g ON p.tasbih_id = g.tasbih_id
      WHERE p.date >= ? AND p.date <= ?
    ''', [startDate, endDate]);

    Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var row in result) {
      String date = row['date'];
      if (!groupedByDate.containsKey(date)) {
        groupedByDate[date] = [];
      }
      groupedByDate[date]!
          .add({'target': row['target'], 'progress': row['progress']});
    }
    return groupedByDate;
  }
}
