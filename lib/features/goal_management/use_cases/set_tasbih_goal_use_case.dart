// lib/features/goal_management/use_cases/set_tasbih_goal_use_case.dart

import 'package:azkari/data/repositories/azkar_repository.dart';

/// حالة استخدام مسؤولة عن منطق تحديد أو إلغاء هدف لذكر معين.
class SetTasbihGoalUseCase {
  final AzkarRepository _repository;

  SetTasbihGoalUseCase(this._repository);

  /// ينفذ عملية تحديد الهدف.
  /// يتم إلغاء الهدف إذا كانت قيمة `targetCount` أقل من أو تساوي صفر.
  Future<void> execute(int tasbihId, int targetCount) async {
    // منطق العمل (Business Logic) موجود هنا بمعزل عن الواجهة.
    final count = targetCount < 0 ? 0 : targetCount;
    await _repository.setGoal(tasbihId, count);
  }
}
