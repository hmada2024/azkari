import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/data/services/database_helper.dart';
import 'package:azkari/data/models/tasbih_model.dart';

// طبقة المستودع التي تعمل كوسيط بين منطق التطبيق ومصدر البيانات
class AdhkarRepository {
  final DatabaseHelper _dbHelper;

  AdhkarRepository(this._dbHelper);

  Future<List<String>> getCategories() async {
    return _dbHelper.getCategories();
  }

  Future<List<AdhkarModel>> getAdhkarByCategory(String category) async {
    return _dbHelper.getAdhkarByCategory(category);
  }

  // دالة جديدة لجلب الأذكار بناءً على قائمة من الـ IDs (سنحتاجها في شاشة المفضلة)
  Future<List<AdhkarModel>> getAdhkarByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    return _dbHelper.getAdhkarByIds(ids);
  }

  Future<List<TasbihModel>> getCustomTasbihList() {
    return _dbHelper.getCustomTasbihList();
  }

  Future<TasbihModel> addTasbih(String text) {
    return _dbHelper.addTasbih(text);
  }

  Future<void> deleteTasbih(int id) {
    return _dbHelper.deleteTasbih(id);
  }
}
