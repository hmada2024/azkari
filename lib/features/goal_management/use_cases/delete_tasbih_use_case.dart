// lib/features/goal_management/use_cases/delete_tasbih_use_case.dart

import 'package:azkari/data/repositories/azkar_repository.dart';

/// حالة استخدام مسؤولة عن منطق حذف ذكر محدد.
class DeleteTasbihUseCase {
  final AzkarRepository _repository;

  DeleteTasbihUseCase(this._repository);

  /// ينفذ عملية الحذف.
  Future<void> execute(int tasbihId) async {
    await _repository.deleteTasbih(tasbihId);
  }
}
