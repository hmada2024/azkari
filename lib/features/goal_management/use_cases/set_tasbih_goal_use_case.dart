// lib/features/goal_management/use_cases/set_tasbih_goal_use_case.dart

import 'package:azkari/data/repositories/goals_repository.dart'; // [مُعدَّل]

/// حالة استخدام مسؤولة عن منطق تحديد أو إلغاء هدف لذكر معين.
class SetTasbihGoalUseCase {
  // [مُعدَّل] الاعتماد على GoalsRepository الجديد
  final GoalsRepository _repository;

  SetTasbihGoalUseCase(this._repository);

  /// ينفذ عملية تحديد الهدف.
  Future<void> execute(int tasbihId, int targetCount) async {
    final count = targetCount < 0 ? 0 : targetCount;
    await _repository.setGoal(tasbihId, count);
  }
}
