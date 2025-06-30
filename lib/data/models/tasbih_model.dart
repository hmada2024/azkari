// lib/data/models/tasbih_model.dart
class TasbihModel {
  final int id;
  final String text;
  final String? alias;
  final int sortOrder;
  final bool isDeletable;

  TasbihModel({
    required this.id,
    required this.text,
    this.alias,
    required this.sortOrder,
    required this.isDeletable,
  });

  String get displayName => alias ?? text;

  factory TasbihModel.fromMap(Map<String, dynamic> map) {
    return TasbihModel(
      id: map['id'],
      text: map['text'],
      alias: map['alias'],
      sortOrder: map['sort_order'],
      isDeletable: map['is_deletable'] == 1,
    );
  }
}
