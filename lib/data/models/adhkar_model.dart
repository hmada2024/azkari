// lib/data/models/adhkar_model.dart

class AzkarModel {
  final int id;
  final String category;
  final String text;
  final int count;
  final String? virtue; // Can be null
  final String? note;   // Can be null
  final int? sortOrder; // Can be null

  AzkarModel({
    required this.id,
    required this.category,
    required this.text,
    required this.count,
    this.virtue,
    this.note,
    this.sortOrder,
  });

  // Factory constructor to create an instance from a map (database row)
  factory AzkarModel.fromMap(Map<String, dynamic> map) {
    return AzkarModel(
      id: map['id'],
      category: map['category'],
      text: map['text'],
      count: map['count'],
      virtue: map['virtue'],
      note: map['note'],
      sortOrder: map['sort_order'],
    );
  }
}