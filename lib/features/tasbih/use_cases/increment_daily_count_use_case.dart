// lib/features/tasbih/use_cases/increment_daily_count_use_case.dart

import 'package:azkari/data/repositories/azkar_repository.dart';

/// حالة استخدام مسؤولة عن زيادة عداد ذكر معين لليوم الحالي.
class IncrementDailyCountUseCase {
  final AzkarRepository _repository;

  IncrementDailyCountUseCase(this._repository);

  /// ينفذ عملية زيادة العداد في قاعدة البيانات.
  Future<void> execute(int tasbihId) async {
    // لا يوجد منطق معقد هنا، مجرد تمرير للـ repository.
    // لكن وجودها في كلاس مستقل يسهل الاختبار ويعزل المسؤولية.
    await _repository.incrementTasbihDailyCount(tasbihId);
  }
}
