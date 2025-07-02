// lib/features/goal_management/use_cases/reorder_tasbih_list_use_case.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/data/repositories/tasbih_repository.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:dartz/dartz.dart';
class ReorderTasbihListUseCase {
  final TasbihRepository _repository;
  ReorderTasbihListUseCase(this._repository);
  Future<Either<Failure, void>> execute(
      List<GoalManagementItem> currentList, int oldIndex, int newIndex) async {
    try {
      final reorderedList = List<GoalManagementItem>.from(currentList);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = reorderedList.removeAt(oldIndex);
      reorderedList.insert(newIndex, item);
      final Map<int, int> newOrders = {
        for (int i = 0; i < reorderedList.length; i++)
          reorderedList[i].tasbih.id: i
      };
      await _repository.updateSortOrders(newOrders);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure("فشلت عملية إعادة ترتيب الأذكار."));
    }
  }
}