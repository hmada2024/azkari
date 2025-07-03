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
    final target = map['target_count'];
    return ManagedGoal(
      tasbih: tasbih,
      isActive: target != null,
      targetCount: target ?? 0,
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
