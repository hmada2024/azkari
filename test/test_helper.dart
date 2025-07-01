// test/test_helper.dart
import 'package:azkari/data/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> setupTestDatabase() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

  await DatabaseService.instance.testOnUpgrade(db, 0, 4);

  return db;
}
