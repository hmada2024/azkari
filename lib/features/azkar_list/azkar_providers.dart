// lib/features/azkar_list/azkar_providers.dart
import 'package:azkari/data/dao/azkar_dao.dart';
import 'package:azkari/data/dao/goal_dao.dart';
import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/dao/tasbih_progress_dao.dart'; // [جديد]
import 'package:azkari/data/models/azkar_model.dart';
import 'package:azkari/data/repositories/azkar_repository.dart';
import 'package:azkari/data/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
export 'providers/azkar_card_provider.dart';

// -- Level 1: Database Service --
final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseService.instance.database;
});

// [تعديل] تحديث المستودع ليتضمن الـ DAO الجديد
final azkarRepositoryProvider = FutureProvider<AzkarRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AzkarRepository(
    AzkarDao(db),
    TasbihDao(db),
    GoalDao(db),
    TasbihProgressDao(db), // [جديد]
  );
});

// -- Level 3: Feature-Specific Providers --
final azkarByCategoryProvider =
    FutureProvider.family<List<AzkarModel>, String>((ref, category) async {
  final repository = await ref.watch(azkarRepositoryProvider.future);
  return repository.getAzkarByCategory(category);
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(azkarRepositoryProvider.future);
  return repository.getCategories();
});
