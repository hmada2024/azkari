// lib/features/tasbih/use_cases/increment_daily_count_use_case.dart

import 'package:azkari/data/repositories/goals_repository.dart'; // [مُعدَّل]

/// حالة استخدام مسؤولة عن زيادة عداد ذكر معين لليوم الحالي.
class IncrementDailyCountUseCase {
  // [مُعدَّل] الاعتماد على GoalsRepository الجديد
  final GoalsRepository _repository;

  IncrementDailyCountUseCase(this._repository);

  /// ينفذ عملية زيادة العداد في قاعدة البيانات.
  Future<void> execute(int tasbihId) async {
    await _repository.incrementTasbihDailyCount(tasbihId);
  }
}
