// lib/data/dao/adhkar_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/azkar_model.dart';

/// كلاس كائن الوصول للبيانات (DAO) الخاص بجدول الأذكار (adhkar).
/// يحتوي على جميع الاستعلامات المتعلقة بالأذكار الرئيسية.
class AzkarDao {
  final Database _db;

  AzkarDao(this._db);

  Future<List<AzkarModel>> getAzkarByCategory(String category) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'adhkar',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'sort_order ASC, id ASC',
    );
    return List.generate(maps.length, (i) => AzkarModel.fromMap(maps[i]));
  }

  Future<List<String>> getCategories() async {
    final List<Map<String, dynamic>> maps = await _db
        .rawQuery('SELECT DISTINCT category FROM adhkar ORDER BY category');
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => maps[i]['category'] as String);
  }

  Future<List<AzkarModel>> getAzkarByIds(List<int> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final List<Map<String, dynamic>> maps = await _db.query(
      'adhkar',
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
    final adhkarList =
        List.generate(maps.length, (i) => AzkarModel.fromMap(maps[i]));
    // إعادة ترتيب القائمة لتطابق ترتيب الـ IDs المطلوبة (مهم للمفضلة)
    adhkarList.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    return adhkarList;
  }
}
