// lib/data/constants/database_constants.dart
class DbConstants {
  DbConstants._(); 
  static const adhkar = _AdhkarTable();
  static const customTasbih = _CustomTasbihTable();
  static const dailyGoals = _DailyGoalsTable();
  static const tasbihDailyProgress = _TasbihDailyProgressTable();
}
class _AdhkarTable {
  const _AdhkarTable();
  final String name = 'adhkar';
  final String colId = 'id';
  final String colCategory = 'category';
  final String colText = 'text';
  final String colCount = 'count';
  final String colVirtue = 'virtue';
  final String colNote = 'note';
  final String colSortOrder = 'sort_order';
}
class _CustomTasbihTable {
  const _CustomTasbihTable();
  final String name = 'custom_tasbih';
  final String colId = 'id';
  final String colText = 'text';
  final String colAlias = 'alias';
  final String colSortOrder = 'sort_order';
  final String colIsDeletable = 'is_deletable';
}
class _DailyGoalsTable {
  const _DailyGoalsTable();
  final String name = 'daily_goals';
  final String colId = 'id';
  final String colTasbihId = 'tasbih_id';
  final String colTargetCount = 'target_count';
}
class _TasbihDailyProgressTable {
  const _TasbihDailyProgressTable();
  final String name = 'tasbih_daily_progress';
  final String colId = 'id';
  final String colTasbihId = 'tasbih_id';
  final String colDate = 'date';
  final String colCount = 'count';
}