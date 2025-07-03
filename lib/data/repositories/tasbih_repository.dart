// lib/data/repositories/tasbih_repository.dart
import '../dao/tasbih_dao.dart';
import '../models/tasbih_model.dart';

class TasbihRepository {
  final TasbihDao _tasbihDao;
  TasbihRepository(this._tasbihDao);

  Future<List<TasbihModel>> getCustomTasbihList() =>
      _tasbihDao.getCustomTasbihList();

  Future<List<TasbihModel>> getActiveTasbihList() =>
      _tasbihDao.getActiveTasbihList();

  Future<TasbihModel> addTasbih(String text) => _tasbihDao.addTasbih(text);

  // Future<void> deleteTasbih(int id) => _tasbihDao.deleteTasbih(id); // <-- تم الحذف

  Future<void> updateTasbihText(int id, String newText) =>
      _tasbihDao.updateTasbihText(id, newText);

  Future<void> updateSortOrders(Map<int, int> newOrders) =>
      _tasbihDao.updateSortOrders(newOrders);
}
