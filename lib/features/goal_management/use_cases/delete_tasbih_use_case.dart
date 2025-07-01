// lib/features/goal_management/use_cases/delete_tasbih_use_case.dart

import 'package:azkari/data/repositories/tasbih_repository.dart'; // [مُعدَّل]

/// حالة استخدام مسؤولة عن منطق حذف ذكر محدد.
class DeleteTasbihUseCase {
  // [مُعدَّل] الاعتماد على TasbihRepository الجديد
  final TasbihRepository _repository;

  DeleteTasbihUseCase(this._repository);

  /// ينفذ عملية الحذف.
  Future<void> execute(int tasbihId) async {
    await _repository.deleteTasbih(tasbihId);
  }
}
