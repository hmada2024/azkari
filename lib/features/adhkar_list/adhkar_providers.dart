// lib/features/adhkar_list/adhkar_providers.dart
import 'package:azkari/data/dao/adhkar_dao.dart';
import 'package:azkari/data/dao/goal_dao.dart';
import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/data/repositories/adhkar_repository.dart';
import 'package:azkari/data/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

// -- Level 1: Database Service --
// هذا الـ Provider يبقى كما هو، فهو المصدر الأساسي لاتصال قاعدة البيانات.
final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseService.instance.database;
});

// -- Level 2: Repository Provider (The Correct Way) --
// ✨✨✨ هذا هو التعديل الجوهري ✨✨✨
// نجعل المستودع نفسه FutureProvider. هذا يضمن عدم إنشاء أي شيء
// يعتمد على قاعدة البيانات إلا بعد أن تكون جاهزة تماماً.
final adhkarRepositoryProvider = FutureProvider<AdhkarRepository>((ref) async {
  // ننتظر هنا حتى يكتمل تحميل قاعدة البيانات
  final db = await ref.watch(databaseProvider.future);

  // الآن وبعد أن أصبحت قاعدة البيانات جاهزة، يمكننا بأمان إنشاء الـ DAOs والـ Repository.
  return AdhkarRepository(
    AdhkarDao(db),
    TasbihDao(db),
    GoalDao(db),
  );
});

// -- Level 3: Feature-Specific Providers --
// الآن، يجب أن تتعامل هذه الـ providers مع حقيقة أن الـ repository أصبح Future.
final adhkarByCategoryProvider =
    FutureProvider.family<List<AdhkarModel>, String>((ref, category) async {
  // ننتظر حتى يصبح المستودع جاهزاً
  final repository = await ref.watch(adhkarRepositoryProvider.future);
  return repository.getAdhkarByCategory(category);
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  // ننتظر حتى يصبح المستودع جاهزاً
  final repository = await ref.watch(adhkarRepositoryProvider.future);
  return repository.getCategories();
});
