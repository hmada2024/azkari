// lib/features/azkar_list/providers/azkar_list_providers.dart
import 'package:azkari/data/dao/azkar_dao.dart';
import 'package:azkari/data/dao/goal_dao.dart';
import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/dao/tasbih_progress_dao.dart';
import 'package:azkari/data/models/azkar_model.dart';
import 'package:azkari/data/repositories/azkar_repository.dart';
import 'package:azkari/data/repositories/goals_repository.dart';
import 'package:azkari/data/repositories/tasbih_repository.dart';
import 'package:azkari/data/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
export 'azkar_card_provider.dart';

// -- Level 1: Core Providers --
final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseService.instance.database;
});

// -- Level 2: DAO Providers --
// [جديد] إنشاء providers لكل DAO لتسهيل الاعتمادية.
final azkarDaoProvider = FutureProvider((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AzkarDao(db);
});

final tasbihDaoProvider = FutureProvider((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TasbihDao(db);
});

final goalDaoProvider = FutureProvider((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return GoalDao(db);
});

final tasbihProgressDaoProvider = FutureProvider((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TasbihProgressDao(db);
});

// -- Level 3: Repository Providers --
// [مُعدَّل] أصبح كل provider مسؤولاً عن مستودع واحد فقط.
final azkarRepositoryProvider = FutureProvider<AzkarRepository>((ref) async {
  final dao = await ref.watch(azkarDaoProvider.future);
  return AzkarRepository(dao);
});

final tasbihRepositoryProvider = FutureProvider<TasbihRepository>((ref) async {
  final dao = await ref.watch(tasbihDaoProvider.future);
  return TasbihRepository(dao);
});

final goalsRepositoryProvider = FutureProvider<GoalsRepository>((ref) async {
  final goalDao = await ref.watch(goalDaoProvider.future);
  final progressDao = await ref.watch(tasbihProgressDaoProvider.future);
  return GoalsRepository(goalDao, progressDao);
});

// -- Level 4: Feature-Specific Data Providers --
final azkarByCategoryProvider =
    FutureProvider.family<List<AzkarModel>, String>((ref, category) async {
  // [مُعدَّل] الاعتماد على azkarRepositoryProvider الجديد (لم يتغير الاسم ولكن تغير المحتوى).
  final repository = await ref.watch(azkarRepositoryProvider.future);
  return repository.getAzkarByCategory(category);
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  // [مُعدَّل] الاعتماد على azkarRepositoryProvider الجديد.
  final repository = await ref.watch(azkarRepositoryProvider.future);
  return repository.getCategories();
});
