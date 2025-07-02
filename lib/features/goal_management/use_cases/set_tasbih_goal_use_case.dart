// lib/features/goal_management/use_cases/set_tasbih_goal_use_case.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/data/repositories/goals_repository.dart';
import 'package:dartz/dartz.dart';

class SetTasbihGoalUseCase {
  final GoalsRepository _repository;
  SetTasbihGoalUseCase(this._repository);
  Future<Either<Failure, void>> execute(int tasbihId, int targetCount) async {
    try {
      final count = targetCount < 0 ? 0 : targetCount;
      await _repository.setGoal(tasbihId, count);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure("فشلت عملية تحديد الهدف."));
    }
  }
}
