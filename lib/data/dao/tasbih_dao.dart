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

  Future<TasbihModel> addTasbih(String text) async {
    final lastItem = await _db.rawQuery(
        "SELECT MAX(${DbConstants.customTasbih.colSortOrder}) as max_order FROM ${DbConstants.customTasbih.name}");
    int newSortOrder = (lastItem.first['max_order'] as int? ?? 0) + 1;
    final newTasbih = {
      DbConstants.customTasbih.colText: text,
      DbConstants.customTasbih.colSortOrder: newSortOrder,
      DbConstants.customTasbih.colIsDeletable: 1,
    };
    final id = await _db.insert(DbConstants.customTasbih.name, newTasbih);
    return TasbihModel(
        id: id, text: text, sortOrder: newSortOrder, isDeletable: true);
  }

  Future<void> deleteTasbih(int id) async {
    await _db.delete(
      DbConstants.customTasbih.name,
      where:
          '${DbConstants.customTasbih.colId} = ? AND ${DbConstants.customTasbih.colIsDeletable} = ?',
      whereArgs: [id, 1],
    );
  }

  Future<void> updateTasbihText(int id, String newText) async {
    await _db.update(
      DbConstants.customTasbih.name,
      {DbConstants.customTasbih.colText: newText},
      where:
          '${DbConstants.customTasbih.colId} = ? AND ${DbConstants.customTasbih.colIsDeletable} = ?',
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
