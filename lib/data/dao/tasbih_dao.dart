// lib/data/dao/tasbih_dao.dart
import 'package:azkari/core/constants/database_constants.dart';
import 'package:sqflite/sqflite.dart';
import '../models/tasbih_model.dart';

class TasbihDao {
  final Database _db;
  TasbihDao(this._db);
  Future<List<TasbihModel>> getCustomTasbihList() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.customTasbih.name,
      orderBy:
          '${DbConstants.customTasbih.colSortOrder} ASC, ${DbConstants.customTasbih.colId} ASC',
    );
    return List.generate(maps.length, (i) => TasbihModel.fromMap(maps[i]));
  }

  Future<List<TasbihModel>> getActiveTasbihList() async {
    final query = '''
      SELECT t.*
      FROM ${DbConstants.customTasbih.name} t
      JOIN ${DbConstants.dailyGoals.name} g ON t.${DbConstants.customTasbih.colId} = g.${DbConstants.dailyGoals.colTasbihId}
      ORDER BY t.${DbConstants.customTasbih.colSortOrder} ASC
    ''';
    final List<Map<String, dynamic>> maps = await _db.rawQuery(query);
    return List.generate(maps.length, (i) => TasbihModel.fromMap(maps[i]));
  }

  Future<TasbihModel> addTasbih(String text) async {
    final lastItem = await _db.rawQuery(
        "SELECT MAX(${DbConstants.customTasbih.colSortOrder}) as max_order FROM ${DbConstants.customTasbih.name}");
    int newSortOrder = (lastItem.first['max_order'] as int? ?? 0) + 1;
    final newTasbih = {
      DbConstants.customTasbih.colText: text,
      DbConstants.customTasbih.colSortOrder: newSortOrder,
      DbConstants.customTasbih.colIsDefault: 1, // كل ذكر جديد هو اختياري
    };
    final id = await _db.insert(DbConstants.customTasbih.name, newTasbih);
    return TasbihModel(
        id: id, text: text, sortOrder: newSortOrder, isDefault: false);
  }

  Future<void> updateTasbihText(int id, String newText) async {
    await _db.update(
      DbConstants.customTasbih.name,
      {DbConstants.customTasbih.colText: newText},
      where:
          '${DbConstants.customTasbih.colId} = ? AND ${DbConstants.customTasbih.colIsDefault} = ?',
      whereArgs: [id, 1],
    );
  }

  Future<void> updateSortOrders(Map<int, int> newOrders) async {
    final batch = _db.batch();
    newOrders.forEach((id, sortOrder) {
      batch.update(
        DbConstants.customTasbih.name,
        {DbConstants.customTasbih.colSortOrder: sortOrder},
        where: '${DbConstants.customTasbih.colId} = ?',
        whereArgs: [id],
      );
    });
    await batch.commit(noResult: true);
  }
}
