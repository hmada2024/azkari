// lib/data/models/tasbih_model.dart
class TasbihModel {
  final int id;
  final String text;
  final int sortOrder;
  final bool isMandatory;

  TasbihModel({
    required this.id,
    required this.text,
    required this.sortOrder,
    required this.isMandatory,
  });

  String get displayName => text;

  factory TasbihModel.fromMap(Map<String, dynamic> map) {
    return TasbihModel(
      id: map['id'],
      text: map['text'],
      sortOrder: map['sort_order'],
      isMandatory: map['is_default'] == 0,
    );
  }
}
