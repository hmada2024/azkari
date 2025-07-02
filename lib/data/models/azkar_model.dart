// lib/data/models/adhkar_model.dart
class AzkarModel {
  final int id;
  final String category;
  final String text;
  final int count;
  final String? virtue; 
  final String? note;   
  final int? sortOrder; 
  AzkarModel({
    required this.id,
    required this.category,
    required this.text,
    required this.count,
    this.virtue,
    this.note,
    this.sortOrder,
  });
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