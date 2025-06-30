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
  // [مهم] زيادة إصدار قاعدة البيانات لتشغيل الترقية
  static const int _dbVersion = 3;

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
      await _createGoalTablesV2(db);
    }
    // [جديد] الترقية للإصدار 3
    if (oldVersion < 3) {
      await _upgradeToV3(db);
    }
  }

  // [ملاحظة] تم تغيير اسم الدالة لتجنب الالتباس
  Future<void> _createGoalTablesV2(Database db) async {
    // ... (الكود السابق لإنشاء جداول الأهداف يبقى كما هو)
    await db.execute('''
        CREATE TABLE daily_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tasbih_id INTEGER NOT NULL UNIQUE,
          target_count INTEGER NOT NULL,
          FOREIGN KEY (tasbih_id) REFERENCES custom_tasbih (id) ON DELETE CASCADE
        )
      ''');
    await db.execute('''
        CREATE TABLE goal_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          current_count INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (goal_id) REFERENCES daily_goals (id) ON DELETE CASCADE,
          UNIQUE(goal_id, date)
        )
      ''');
  }

  // [جديد] منطق الترقية للإصدار الثالث
  Future<void> _upgradeToV3(Database db) async {
    // 1. إنشاء جدول تتبع العداد اليومي لكل ذكر
    await db.execute('''
      CREATE TABLE tasbih_daily_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tasbih_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (tasbih_id) REFERENCES custom_tasbih (id) ON DELETE CASCADE,
        UNIQUE(tasbih_id, date)
      )
    ''');
    debugPrint("Table 'tasbih_daily_progress' created.");

    // 2. إدخال الأهداف الافتراضية للمستخدمين الجدد (أو عند الترقية)
    // هذه الـ IDs (1, 2, 3, 4, 5) هي IDs افتراضية للأذكار في ملف الـ DB
    final batch = db.batch();
    batch.insert('daily_goals', {'tasbih_id': 1, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore); // لا إله إلا الله
    batch.insert('daily_goals', {'tasbih_id': 2, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore); // أستغفر الله
    batch.insert('daily_goals', {'tasbih_id': 3, 'target_count': 100},
        conflictAlgorithm:
            ConflictAlgorithm.ignore); // لا حول ولا قوة إلا بالله
    batch.insert('daily_goals', {'tasbih_id': 4, 'target_count': 10},
        conflictAlgorithm: ConflictAlgorithm.ignore); // سبحان الله وبحمده...
    batch.insert('daily_goals', {'tasbih_id': 5, 'target_count': 10},
        conflictAlgorithm: ConflictAlgorithm.ignore); // لا إله إلا الله وحده...
    await batch.commit(noResult: true);
    debugPrint("Default daily goals have been set.");
  }
}
