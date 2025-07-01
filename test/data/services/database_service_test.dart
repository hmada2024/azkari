// test/data/services/database_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import '../../test_helper.dart';

void main() {
  // تهيئة بيئة الاختبار لـ Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database db;

  // setUp يتم تنفيذها قبل كل اختبار في هذا الملف
  setUp(() async {
    db = await setupTestDatabase();
  });

  // tearDown يتم تنفيذها بعد كل اختبار للتنظيف
  tearDown(() async {
    await db.close();
  });

  group('DatabaseService Tests', () {
    test('Database should be initialized correctly and all tables should exist',
        () async {
      // Arrange & Act
      // تم التنفيذ في دالة setUp

      // Assert: تحقق من النتائج المتوقعة
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);

      // تحقق من وجود الجداول الرئيسية التي تم إنشاؤها عبر الترقيات (migrations)
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;");
      final tableNames = tables.map((row) => row['name'] as String).toList();

      // تحقق من أن الجداول الأساسية موجودة. هذا يثبت أن دوال onUpgrade عملت بنجاح.
      expect(tableNames, contains('adhkar')); // يجب أن يكون موجودًا من الأصل
      expect(tableNames, contains('custom_tasbih'));
      expect(tableNames, contains('daily_goals')); // من ترقية v2
      expect(tableNames, contains('tasbih_daily_progress')); // من ترقية v3

      // تحقق من أن التعديلات تمت
      final customTasbihInfo =
          await db.rawQuery('PRAGMA table_info(custom_tasbih)');
      expect(customTasbihInfo.any((col) => col['name'] == 'alias'), isTrue,
          reason: 'alias column should be added in v4 upgrade'); // من ترقية v4
    });
  });
}
