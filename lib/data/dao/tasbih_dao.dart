// lib/data/dao/tasbih_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/tasbih_model.dart';

/// كلاس كائن الوصول للبيانات (DAO) الخاص بجدول التسابيح (custom_tasbih).
/// يحتوي على جميع العمليات (CRUD) المتعلقة بالتسابيح.
class TasbihDao {
  final Database _db;

  TasbihDao(this._db);

  Future<List<TasbihModel>> getCustomTasbihList() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'custom_tasbih',
      orderBy: 'sort_order ASC, id ASC',
    );
    return List.generate(maps.length, (i) => TasbihModel.fromMap(maps[i]));
  }

  Future<TasbihModel> addTasbih(String text) async {
    final lastItem = await _db
        .rawQuery("SELECT MAX(sort_order) as max_order FROM custom_tasbih");
    int newSortOrder = (lastItem.first['max_order'] as int? ?? 0) + 1;

    final newTasbih = {
      'text': text,
      'sort_order': newSortOrder,
      'is_deletable': 1, // كل ما يضاف من المستخدم قابل للحذف
    };

    final id = await _db.insert('custom_tasbih', newTasbih);
    return TasbihModel(
        id: id, text: text, sortOrder: newSortOrder, isDeletable: true);
  }

  Future<void> deleteTasbih(int id) async {
    await _db.delete(
      'custom_tasbih',
      where: 'id = ? AND is_deletable = ?',
      whereArgs: [id, 1], // حماية إضافية لعدم حذف الافتراضي
    );
  }

  /// [دالة جديدة] لتعديل نص الذكر المضاف من قبل المستخدم.
  Future<void> updateTasbihText(int id, String newText) async {
    await _db.update(
      'custom_tasbih',
      {'text': newText},
      where: 'id = ? AND is_deletable = ?',
      whereArgs: [id, 1], // يسمح بتعديل ما أضافه المستخدم فقط
    );
  }

  /// [دالة جديدة] لتحديث ترتيب جميع التسابيح بعد السحب والإفلات.
  Future<void> updateSortOrders(Map<int, int> newOrders) async {
    final batch = _db.batch();
    newOrders.forEach((id, sortOrder) {
      batch.update(
        'custom_tasbih',
        {'sort_order': sortOrder},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    await batch.commit(noResult: true);
  }
}
