// test/test_helper.dart

import 'dart:io';

import 'package:azkari/data/services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ✨ [إصلاح جوهري] دالة جديدة لتهيئة بيئة الاختبار التكاملي
Future<void> setupIntegrationTest() async {
  // تهيئة FFI لـ sqflite على أجهزة سطح المكتب
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // هذا هو الجزء الأهم: حذف قاعدة البيانات القديمة قبل كل اختبار
  // هذا يضمن أن كل اختبار يبدأ بحالة نظيفة تمامًا
  final Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final String path = join(documentsDirectory.path, "azkar.db");

  final dbFile = File(path);
  if (await dbFile.exists()) {
    // تجاهل أي أخطاء في حال كان الملف مستخدمًا، ولكن حاول الحذف
    try {
      await dbFile.delete();
      if (kDebugMode) {
        print("Deleted existing test database at $path");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Could not delete test database: $e");
      }
    }
  }

  // أغلق أي اتصال قديم بقاعدة البيانات إذا كان موجودًا
  // هذا يضمن أن الخدمة ستقوم بإعادة الإنشاء من جديد
  await DatabaseService.instance.closeDatabaseForTest();
}

// هذه الدالة تبقى كما هي لاختبارات الوحدات (Unit Tests)
Future<Database> setupTestDatabase() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

  // تم تعديل هذه لتشمل جميع الترقيات حتى الإصدار 4
  await DatabaseService.instance.testOnUpgrade(db, 0, 4);

  return db;
}
