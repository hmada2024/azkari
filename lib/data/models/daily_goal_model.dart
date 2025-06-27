// lib/data/models/daily_goal_model.dart

// هذا النموذج لا يمثل جدولاً واحداً، بل هو نموذج عرض مجمع (View Model)
// يجمع بيانات من جدول الأهداف (daily_goals) والتقدم اليومي (goal_progress)
// والذكر نفسه (custom_tasbih) لتسهيل عرضها في الواجهة.
class DailyGoalModel {
  final int goalId;
  final int tasbihId;
  final String tasbihText;
  final int targetCount;
  final int currentProgress;
  final bool isCompleted;

  DailyGoalModel({
    required this.goalId,
    required this.tasbihId,
    required this.tasbihText,
    required this.targetCount,
    required this.currentProgress,
  }) : isCompleted = currentProgress >= targetCount;

  // Factory constructor to create an instance from a database map
  factory DailyGoalModel.fromMap(Map<String, dynamic> map) {
    return DailyGoalModel(
      goalId: map['goalId'],
      tasbihId: map['tasbihId'],
      tasbihText: map['tasbihText'],
      targetCount: map['targetCount'],
      currentProgress: map['currentProgress'] ?? 0, // قد يكون التقدم null
    );
  }

  double get progressFraction => (targetCount == 0)
      ? 0.0
      : (currentProgress / targetCount).clamp(0.0, 1.0);
}
