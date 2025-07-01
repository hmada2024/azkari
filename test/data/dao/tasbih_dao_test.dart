// test/data/dao/tasbih_dao_test.dart

import 'package:azkari/data/dao/tasbih_dao.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import '../../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database db;
  late TasbihDao tasbihDao;

  setUp(() async {
    db = await setupTestDatabase();
    tasbihDao = TasbihDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TasbihDao Tests', () {
    test('addTasbih should insert a new record and return a TasbihModel',
        () async {
      // Act
      const newTasbihText = 'ذكر جديد';
      final newTasbihModel = await tasbihDao.addTasbih(newTasbihText);

      // Assert
      expect(newTasbihModel, isA<TasbihModel>());
      expect(newTasbihModel.text, newTasbihText);
      expect(newTasbihModel.isDeletable, isTrue);

      // Verify insertion in DB
      final result = await db
          .query('custom_tasbih', where: 'id = ?', whereArgs: [newTasbihModel.id]);
      expect(result, isNotEmpty);
      expect(result.first['text'], newTasbihText);
    });

    test('getCustomTasbihList should return all tasbihs ordered by sort_order',
        () async {
      // Arrange: The DB is pre-populated by the migration script.
      // Let's add one more to test ordering.
      await tasbihDao.addTasbih('آخر ذكر'); // This will have the highest sort_order

      // Act
      final tasbihList = await tasbihDao.getCustomTasbihList();

      // Assert
      expect(tasbihList, isNotEmpty);
      // Check if it is sorted
      for (int i = 0; i < tasbihList.length - 1; i++) {
        expect(tasbihList[i].sortOrder, lessThanOrEqualTo(tasbihList[i + 1].sortOrder));
      }
      expect(tasbihList.last.text, 'آخر ذكر');
    });

    test('deleteTasbih should remove a deletable record', () async {
      // Arrange
      final newTasbih = await tasbihDao.addTasbih('ذكر سيتم حذفه');
      expect(newTasbih.isDeletable, isTrue);

      // Act
      await tasbihDao.deleteTasbih(newTasbih.id);

      // Assert
      final result = await db.query('custom_tasbih', where: 'id = ?', whereArgs: [newTasbih.id]);
      expect(result, isEmpty);
    });

    test('deleteTasbih should NOT remove a non-deletable record', () async {
      // Arrange: Get a non-deletable tasbih (e.g., id=2 from migration)
      const nonDeletableId = 2;

      // Act
      await tasbihDao.deleteTasbih(nonDeletableId);

      // Assert
      final result = await db.query('custom_tasbih', where: 'id = ?', whereArgs: [nonDeletableId]);
      expect(result, isNotEmpty, reason: 'Non-deletable tasbih should not be deleted');
    });

    test('updateTasbihText should modify the text of a specific record', () async {
      // Arrange
      final tasbihToUpdate = await tasbihDao.addTasbih('نص قديم');
      const updatedText = 'نص جديد ومحدث';
      
      // Act
      await tasbihDao.updateTasbihText(tasbihToUpdate.id, updatedText);

      // Assert
      final result = await db.query('custom_tasbih', where: 'id = ?', whereArgs: [tasbihToUpdate.id]);
      expect(result.first['text'], updatedText);
    });

    test('updateSortOrders should update the order of multiple records in a batch', () async {
      // Arrange
      // The DB already has items. Let's get them.
      final initialList = await tasbihDao.getCustomTasbihList();
      final firstItemId = initialList.first.id;
      final secondItemId = initialList[1].id;
      
      // Create a new order map, swapping the first two items
      final Map<int, int> newOrders = {
        for (int i = 0; i < initialList.length; i++) initialList[i].id: i
      };
      newOrders[firstItemId] = 1; // old 0 -> new 1
      newOrders[secondItemId] = 0; // old 1 -> new 0
      
      // Act
      await tasbihDao.updateSortOrders(newOrders);

      // Assert
      final updatedList = await tasbihDao.getCustomTasbihList();
      expect(updatedList[0].id, secondItemId);
      expect(updatedList[1].id, firstItemId);
    });
  });
}