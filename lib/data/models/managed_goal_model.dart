// lib/data/models/managed_goal_model.dart
import 'package:azkari/data/models/tasbih_model.dart';

class ManagedGoal {
  final TasbihModel tasbih;
  final bool isActive;
  final int targetCount;

  ManagedGoal({
    required this.tasbih,
    required this.isActive,
    required this.targetCount,
  });

  factory ManagedGoal.fromMap(Map<String, dynamic> map) {
    final tasbih = TasbihModel.fromMap(map);
    final targetCountFromDb = map['target_count'];
    final bool isMandatory = tasbih.isMandatory;

    final bool isActive = isMandatory || (targetCountFromDb != null);

    final int currentTarget = isActive ? (targetCountFromDb ?? 100) : 0;

    return ManagedGoal(
      tasbih: tasbih,
      isActive: isActive,
      targetCount: currentTarget,
    );
  }

  ManagedGoal copyWith({
    TasbihModel? tasbih,
    bool? isActive,
    int? targetCount,
  }) {
    return ManagedGoal(
      tasbih: tasbih ?? this.tasbih,
      isActive: isActive ?? this.isActive,
      targetCount: targetCount ?? this.targetCount,
    );
  }
}
