// lib/data/services/database_service.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  static const String _dbName = "azkar.db";
  // [تعديل] زيادة إصدار قاعدة البيانات لتشغيل الترقية
  static const int _dbVersion = 4;

  @visibleForTesting
  Future<void> closeDatabaseForTest() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    bool dbExists = await databaseExists(path);

    if (!dbExists) {
      debugPrint("Database not found. Copying from assets...");
      try {
        ByteData data = await rootBundle.load("assets/database_files/$_dbName");
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        debugPrint("Database copied successfully to $path");
      } catch (e) {
        debugPrint("Error copying database: $e");
        throw Exception("Failed to copy database from assets: $e");
      }
    }
    return await openDatabase(path, version: _dbVersion, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 2) {
      // Note: This logic seems to have a flaw, if a user jumps from v1 to v4,
      // this will run, but then subsequent checks won't. For simplicity, we assume incremental upgrades.
      // A more robust solution would be a loop or sequential `if`s.
      await _createGoalTablesV2(db);
    }
    if (oldVersion < 3) {
      await _upgradeToV3(db);
    }
    // [جديد] الترقية للإصدار 4
    if (oldVersion < 4) {
      await _upgradeToV4(db);
    }
  }

  // ... (الكود السابق _createGoalTablesV2 و _upgradeToV3 يبقى كما هو)
  Future<void> _createGoalTablesV2(Database db) async {
    // ...
  }
  Future<void> _upgradeToV3(Database db) async {
    // ...
  }
  // ...

  // [جديد] منطق الترقية للإصدار الرابع لتحديث واجهة إدارة الأهداف
  Future<void> _upgradeToV4(Database db) async {
    final batch = db.batch();

    // 1. إضافة عمود الاسم المستعار (alias)
    batch.execute('ALTER TABLE custom_tasbih ADD COLUMN alias TEXT');

    // 2. تحديث الأسماء المستعارة للأذكار الافتراضية
    // (IDs هي من قاعدة البيانات الأصلية)
    batch.update('custom_tasbih', {'alias': 'الاستغفار'},
        where: 'id = ?', whereArgs: [2]);
    batch.update('custom_tasbih', {'alias': 'الحوقلة'},
        where: 'id = ?', whereArgs: [3]);
    batch.update('custom_tasbih', {'alias': 'التسبيح'},
        where: 'id = ?', whereArgs: [4]);
    batch.update('custom_tasbih', {'alias': 'التوحيد'},
        where: 'id = ?', whereArgs: [5]);
    batch.update('custom_tasbih', {'alias': 'الصلاة على النبي'},
        where: 'id = ?', whereArgs: [6]);

    // 3. حذف الذكر رقم 1 (لا إله إلا الله) لأنه مكرر مع الذكر رقم 5
    batch.delete('custom_tasbih', where: 'id = ?', whereArgs: [1]);

    await batch.commit();
    debugPrint(
        "Database upgraded to v4: Added aliases and cleaned up defaults.");
  }
}
