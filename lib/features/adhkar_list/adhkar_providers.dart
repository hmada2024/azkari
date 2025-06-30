// lib/features/adhkar_list/adhkar_providers.dart
import 'package:azkari/data/dao/adhkar_dao.dart';
import 'package:azkari/data/dao/goal_dao.dart';
import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/data/repositories/adhkar_repository.dart';
import 'package:azkari/data/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
export 'providers/adhkar_card_provider.dart';

// -- Level 1: Database Service --
final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseService.instance.database;
});

final adhkarRepositoryProvider = FutureProvider<AdhkarRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AdhkarRepository(
    AdhkarDao(db),
    TasbihDao(db),
    GoalDao(db),
  );
});

// -- Level 3: Feature-Specific Providers --
final adhkarByCategoryProvider =
    FutureProvider.family<List<AdhkarModel>, String>((ref, category) async {
  final repository = await ref.watch(adhkarRepositoryProvider.future);
  return repository.getAdhkarByCategory(category);
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(adhkarRepositoryProvider.future);
  return repository.getCategories();
});
