// lib/features/goal_management/use_cases/add_tasbih_use_case.dart

import 'package:azkari/data/repositories/azkar_repository.dart';

/// حالة استخدام مسؤولة فقط عن منطق إضافة ذكر جديد.
class AddTasbihUseCase {
  final AzkarRepository _repository;

  AddTasbihUseCase(this._repository);

  /// ينفذ عملية الإضافة مع التحقق من صحة المدخلات.
  Future<void> execute(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      // يمكن استبدال هذا بنوع Exception مخصص لاحقاً.
      throw Exception("لا يمكن إضافة ذكر فارغ.");
    }
    await _repository.addTasbih(trimmedText);
  }
}
