// lib/features/goal_management/use_cases/reorder_tasbih_list_use_case.dart

import 'package:azkari/data/repositories/azkar_repository.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';

/// حالة استخدام مسؤولة عن منطق إعادة ترتيب قائمة الأذكار.
class ReorderTasbihListUseCase {
  final AzkarRepository _repository;

  ReorderTasbihListUseCase(this._repository);

  /// ينفذ عملية إعادة الترتيب ويحفظ الترتيب الجديد في قاعدة البيانات.
  Future<void> execute(
      List<GoalManagementItem> currentList, int oldIndex, int newIndex) async {
    // نسخة قابلة للتعديل من القائمة
    final reorderedList = List<GoalManagementItem>.from(currentList);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = reorderedList.removeAt(oldIndex);
    reorderedList.insert(newIndex, item);

    // إنشاء خريطة بالترتيب الجديد
    final Map<int, int> newOrders = {
      for (int i = 0; i < reorderedList.length; i++)
        reorderedList[i].tasbih.id: i
    };

    await _repository.updateSortOrders(newOrders);
  }
}
