// lib/data/repositories/azkar_repository.dart

import '../dao/azkar_dao.dart';
import '../models/azkar_model.dart';

// [مُعدَّل] تم تقليص مسؤوليات هذا المستودع ليقتصر على الأذكار الثابتة فقط.
class AzkarRepository {
  final AzkarDao _azkarDao;

  AzkarRepository(this._azkarDao);

  Future<List<String>> getCategories() => _azkarDao.getCategories();

  Future<List<AzkarModel>> getAzkarByCategory(String category) =>
      _azkarDao.getAzkarByCategory(category);

  Future<List<AzkarModel>> getAzkarByIds(List<int> ids) =>
      _azkarDao.getAzkarByIds(ids);
}
