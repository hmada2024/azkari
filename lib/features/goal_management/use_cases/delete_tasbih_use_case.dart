// lib/features/goal_management/use_cases/delete_tasbih_use_case.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/data/repositories/tasbih_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteTasbihUseCase {
  final TasbihRepository _repository;
  DeleteTasbihUseCase(this._repository);
  Future<Either<Failure, void>> execute(int tasbihId) async {
    try {
      await _repository.deleteTasbih(tasbihId);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure("فشلت عملية حذف الذكر."));
    }
  }
}
