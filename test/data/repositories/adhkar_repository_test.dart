// test/data/repositories/adhkar_repository_test.dart

import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/data/repositories/adhkar_repository.dart';
import 'package:azkari/data/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// 1. إنشاء ملف وهمي لـ DatabaseHelper
import 'adhkar_repository_test.mocks.dart';

// 2. تفعيل إنشاء الملف الوهمي
@GenerateMocks([DatabaseHelper])
void main() {
  // 3. إعداد البيئة
  late MockDatabaseHelper mockDatabaseHelper;
  late AdhkarRepository adhkarRepository;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    adhkarRepository = AdhkarRepository(mockDatabaseHelper);
  });

  group('AdhkarRepository Unit Tests', () {
    test('getCategories returns list of strings from DatabaseHelper', () async {
      // الإعداد (Arrange)
      final mockCategories = ['أذكار الصباح', 'أذكار المساء'];
      // برمجة النسخة الوهمية لتعيد البيانات عند استدعائها
      when(mockDatabaseHelper.getCategories())
          .thenAnswer((_) async => mockCategories);

      // التنفيذ (Act)
      final categories = await adhkarRepository.getCategories();

      // التحقق (Assert)
      expect(categories, equals(mockCategories));
      // التحقق من أن الدالة في النسخة الوهمية قد استُدعيت مرة واحدة
      verify(mockDatabaseHelper.getCategories()).called(1);
    });

    test('getAdhkarByCategory correctly maps data from DatabaseHelper',
        () async {
      // الإعداد (Arrange)
      final mockDbResponse = [
        {'id': 1, 'category': 'test', 'text': 'ذكر 1', 'count': 5},
        {'id': 2, 'category': 'test', 'text': 'ذكر 2', 'count': 3},
      ];
      when(mockDatabaseHelper.getAdhkarByCategory('test')).thenAnswer(
          (_) async =>
              mockDbResponse.map((map) => AdhkarModel.fromMap(map)).toList());

      // التنفيذ (Act)
      final result = await adhkarRepository.getAdhkarByCategory('test');

      // التحقق (Assert)
      expect(result, isA<List<AdhkarModel>>());
      expect(result.length, 2);
      expect(result[0].text, 'ذكر 1');
      expect(result[1].count, 3);
      verify(mockDatabaseHelper.getAdhkarByCategory('test')).called(1);
    });

    test('getAdhkarByIds returns empty list if ids list is empty', () async {
      // التنفيذ (Act)
      final result = await adhkarRepository.getAdhkarByIds([]);

      // التحقق (Assert)
      expect(result, isEmpty);
      // التحقق من أن قاعدة البيانات لم تُستدعى على الإطلاق
      verifyNever(mockDatabaseHelper.getAdhkarByIds(any));
    });

    test('getAdhkarByIds calls database and maps data correctly', () async {
      // الإعداد (Arrange)
      final mockDbResponse = [
        {'id': 10, 'category': 'cat1', 'text': 'ذكر 10', 'count': 1},
        {'id': 20, 'category': 'cat2', 'text': 'ذكر 20', 'count': 1},
      ];
      when(mockDatabaseHelper.getAdhkarByIds([10, 20])).thenAnswer((_) async =>
          mockDbResponse.map((map) => AdhkarModel.fromMap(map)).toList());

      // التنفيذ (Act)
      final result = await adhkarRepository.getAdhkarByIds([10, 20]);

      // التحقق (Assert)
      expect(result.length, 2);
      expect(result.any((adhkar) => adhkar.id == 10), isTrue);
      verify(mockDatabaseHelper.getAdhkarByIds([10, 20])).called(1);
    });

    test('addTasbih calls the corresponding method in DatabaseHelper',
        () async {
      // الإعداد (Arrange)
      const newTasbihText = 'سبحان الله';
      final mockReturnedTasbih = TasbihModel(
          id: 1, text: newTasbihText, sortOrder: 1, isDeletable: true);
      when(mockDatabaseHelper.addTasbih(newTasbihText))
          .thenAnswer((_) async => mockReturnedTasbih);

      // التنفيذ (Act)
      final result = await adhkarRepository.addTasbih(newTasbihText);

      // التحقق (Assert)
      expect(result, equals(mockReturnedTasbih));
      verify(mockDatabaseHelper.addTasbih(newTasbihText)).called(1);
    });

    test('deleteTasbih calls the corresponding method in DatabaseHelper',
        () async {
      // الإعداد (Arrange)
      const tasbihIdToDelete = 5;
      // لا نحتاج لـ when() لأن الدالة void

      // التنفيذ (Act)
      await adhkarRepository.deleteTasbih(tasbihIdToDelete);

      // التحقق (Assert)
      verify(mockDatabaseHelper.deleteTasbih(tasbihIdToDelete)).called(1);
    });
  });
}
