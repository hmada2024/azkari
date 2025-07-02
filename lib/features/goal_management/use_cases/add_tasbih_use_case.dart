// lib/features/goal_management/use_cases/add_tasbih_use_case.dart

import 'package:azkari/core/error/failures.dart';
import 'package:azkari/data/repositories/goals_repository.dart';
import 'package:azkari/data/repositories/tasbih_repository.dart';
import 'package:dartz/dartz.dart';

class AddTasbihUseCase {
  final TasbihRepository _tasbihRepository;
  final GoalsRepository _goalsRepository; // ✨ [جديد]

  AddTasbihUseCase(this._tasbihRepository, this._goalsRepository);

  Future<Either<Failure, void>> execute(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return const Left(DatabaseFailure("لا يمكن إضافة ذكر فارغ."));
    }
    try {
      // ✨ [تعديل] إضافة الذكر ثم تحديد هدف افتراضي له
      final newTasbih = await _tasbihRepository.addTasbih(trimmedText);
      await _goalsRepository.setGoal(newTasbih.id, 10); // الهدف الافتراضي 10
      return const Right(null);
    } catch (e) {
      return const Left(
          DatabaseFailure("فشلت عملية إضافة الذكر إلى قاعدة البيانات."));
    }
  }
}
