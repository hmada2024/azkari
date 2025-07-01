// test/data/dao/tasbih_progress_dao_test.dart

import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/dao/tasbih_progress_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import '../../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database db;
  late TasbihProgressDao progressDao;
  late TasbihDao tasbihDao; // Needed to get valid tasbih IDs

  setUp(() async {
    db = await setupTestDatabase();
    progressDao = TasbihProgressDao(db);
    tasbihDao = TasbihDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TasbihProgressDao Tests', () {
    test('incrementCount should create a new record if none exists for today',
        () async {
      // Arrange
      final tasbih = await tasbihDao.addTasbih('Test Tasbih');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // Act
      await progressDao.incrementCount(tasbih.id);

      // Assert
      final result = await db.query('tasbih_daily_progress',
          where: 'tasbih_id = ? AND date = ?', whereArgs: [tasbih.id, today]);
      expect(result, isNotEmpty);
      expect(result.first['count'], 1);
    });

    test('incrementCount should update an existing record for today', () async {
      // Arrange
      final tasbih = await tasbihDao.addTasbih('Test Tasbih');
      await progressDao.incrementCount(tasbih.id); // count is now 1

      // Act
      await progressDao.incrementCount(tasbih.id); // count should be 2

      // Assert
      final counts = await progressDao.getTodayCounts();
      expect(counts[tasbih.id], 2);
    });

    test('getTodayCounts should return a map of counts for the current day',
        () async {
      // Arrange
      final tasbih1 = await tasbihDao.addTasbih('Tasbih 1');
      final tasbih2 = await tasbihDao.addTasbih('Tasbih 2');

      await progressDao.incrementCount(tasbih1.id);
      await progressDao.incrementCount(tasbih1.id); // t1 count = 2
      await progressDao.incrementCount(tasbih2.id); // t2 count = 1

      // Act
      final todayCounts = await progressDao.getTodayCounts();

      // Assert
      expect(todayCounts, isA<Map<int, int>>());
      expect(todayCounts.length, 2);
      expect(todayCounts[tasbih1.id], 2);
      expect(todayCounts[tasbih2.id], 1);
    });

    test('getTodayCounts should return an empty map if no progress for today',
        () async {
      // Act
      final todayCounts = await progressDao.getTodayCounts();

      // Assert
      expect(todayCounts, isEmpty);
    });
  });
}
