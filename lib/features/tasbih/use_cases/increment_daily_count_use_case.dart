// lib/features/tasbih/use_cases/increment_daily_count_use_case.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/data/repositories/goals_repository.dart';
import 'package:dartz/dartz.dart';
class IncrementDailyCountUseCase {
  final GoalsRepository _repository;
  IncrementDailyCountUseCase(this._repository);
  Future<Either<Failure, void>> execute(int tasbihId) async {
    try {
      await _repository.incrementTasbihDailyCount(tasbihId);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure("فشل تحديث عداد الذكر."));
    }
  }
}