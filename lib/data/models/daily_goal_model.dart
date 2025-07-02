// lib/data/models/daily_goal_model.dart
class DailyGoalModel {
  final int tasbihId;
  final String tasbihText;
  final int targetCount;
  final int currentProgress;
  final bool isCompleted;
  DailyGoalModel({
    required this.tasbihId,
    required this.tasbihText,
    required this.targetCount,
    required this.currentProgress,
  }) : isCompleted = currentProgress >= targetCount && targetCount > 0;
  factory DailyGoalModel.fromMap(Map<String, dynamic> map) {
    return DailyGoalModel(
      tasbihId: map['tasbihId'],
      tasbihText: map['tasbihText'],
      targetCount: map['targetCount'] ?? 0,
      currentProgress: map['currentProgress'] ?? 0,
    );
  }
  double get progressFraction => (targetCount == 0)
      ? 0.0
      : (currentProgress / targetCount).clamp(0.0, 1.0);
}