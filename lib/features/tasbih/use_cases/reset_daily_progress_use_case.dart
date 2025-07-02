// lib/features/tasbih/use_cases/reset_daily_progress_use_case.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/data/repositories/goals_repository.dart';
import 'package:dartz/dartz.dart';

class ResetDailyProgressUseCase {
  final GoalsRepository _repository;
  ResetDailyProgressUseCase(this._repository);
  Future<Either<Failure, void>> execute(int tasbihId) async {
    try {
      await _repository.resetDailyCountForTasbih(tasbihId);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure("فشلت عملية تصفير العداد."));
    }
  }
}
