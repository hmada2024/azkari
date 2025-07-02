// lib/data/dao/azkar_dao.dart
import 'package:azkari/core/constants/database_constants.dart';
import 'package:sqflite/sqflite.dart';
import '../models/azkar_model.dart';

class AzkarDao {
  final Database _db;
  AzkarDao(this._db);
  Future<List<AzkarModel>> getAzkarByCategory(String category) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.adhkar.name,
      where: '${DbConstants.adhkar.colCategory} = ?',
      whereArgs: [category],
      orderBy:
          '${DbConstants.adhkar.colSortOrder} ASC, ${DbConstants.adhkar.colId} ASC',
    );
    return List.generate(maps.length, (i) => AzkarModel.fromMap(maps[i]));
  }

  Future<List<String>> getCategories() async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery(
        'SELECT DISTINCT ${DbConstants.adhkar.colCategory} FROM ${DbConstants.adhkar.name} ORDER BY ${DbConstants.adhkar.colCategory}');
    if (maps.isEmpty) return [];
    return List.generate(
        maps.length, (i) => maps[i][DbConstants.adhkar.colCategory] as String);
  }

  Future<List<AzkarModel>> getAzkarByIds(List<int> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.adhkar.name,
      where:
          '${DbConstants.adhkar.colId} IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
    final adhkarList =
        List.generate(maps.length, (i) => AzkarModel.fromMap(maps[i]));
    adhkarList.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    return adhkarList;
  }
}
