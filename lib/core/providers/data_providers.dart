// lib/core/providers/data_providers.dart

import 'package:azkari/data/dao/azkar_dao.dart';
import 'package:azkari/data/dao/goal_dao.dart';
import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/dao/tasbih_progress_dao.dart';
import 'package:azkari/data/repositories/azkar_repository.dart';
import 'package:azkari/data/repositories/goals_repository.dart';
import 'package:azkari/data/repositories/tasbih_repository.dart';
import 'package:azkari/data/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

// -- Level 1: Core Service Provider --
final databaseProvider = FutureProvider<Database>((ref) {
  return DatabaseService.instance.database;
});

// -- Level 2: DAO Providers --
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
