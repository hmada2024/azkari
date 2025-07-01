// test/test_helper.dart
import 'package:azkari/data/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// دالة مساعدة رئيسية لإعداد بيئة الاختبار.
/// تقوم بإنشاء قاعدة بيانات وهمية في الذاكرة وتطبيق جميع الترقيات (migrations) عليها.
/// هذا يضمن أن كل اختبار يبدأ بقاعدة بيانات نظيفة ومُهيئة بالكامل.
Future<Database> setupTestDatabase() async {
  // تهيئة sqflite_ffi للاستخدام في بيئة الاختبار (خارج المحاكي)
  sqfliteFfiInit();
  // تغيير الـ factory الافتراضي ليستخدم نسخة الـ ffi التي تعمل في الذاكرة
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

  // بما أننا لا ننسخ من assets في الاختبار، سنقوم بتنفيذ دوال الترقية يدويًا
  // استدعاء الترقية من الإصدار 0 إلى الإصدار الحالي (4) يضمن إنشاء جميع الجداول
  await DatabaseService.instance.testOnUpgrade(db, 0, 4);

  return db;
}
