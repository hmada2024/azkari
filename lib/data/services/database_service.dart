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
    // [تعديل مهم] إضافة دالة onCreate هنا
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate, // يتم استدعاؤها عند الإنشاء لأول مرة
      onUpgrade: _onUpgrade, // يتم استدعاؤها عند تحديث الإصدار
    );
  }

  // [جديد] هذه الدالة تُستدعى فقط عندما يتم إنشاء قاعدة البيانات من الصفر
  // (أي بعد نسخها من assets لأول مرة).
  Future<void> _onCreate(Database db, int version) async {
    debugPrint(
        "Creating database for the first time, applying all migrations...");
    // سنقوم بتشغيل كل الترقيات بالترتيب لضمان بناء كل الجداول
    await _onUpgrade(db, 0, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion...");
    // استخدام if متسلسل يضمن تنفيذ الترقيات بالترتيب
    if (oldVersion < 2) {
      await _createGoalTablesV2(db);
    }
    if (oldVersion < 3) {
      await _upgradeToV3(db);
    }
    if (oldVersion < 4) {
      await _upgradeToV4(db);
    }
  }

  // لقد قمت بإعادة الكود الكامل لدوال الترقية هنا للتأكد من أنه صحيح
  Future<void> _createGoalTablesV2(Database db) async {
    debugPrint("Applying V2 migration: Creating goal tables...");
    await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tasbih_id INTEGER NOT NULL UNIQUE,
          target_count INTEGER NOT NULL,
          FOREIGN KEY (tasbih_id) REFERENCES custom_tasbih (id) ON DELETE CASCADE
        )
      ''');
    await db.execute('''
        CREATE TABLE IF NOT EXISTS goal_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          current_count INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (goal_id) REFERENCES daily_goals (id) ON DELETE CASCADE,
          UNIQUE(goal_id, date)
        )
      ''');
  }

  Future<void> _upgradeToV3(Database db) async {
    debugPrint(
        "Applying V3 migration: Creating tasbih_daily_progress table...");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasbih_daily_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tasbih_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (tasbih_id) REFERENCES custom_tasbih (id) ON DELETE CASCADE,
        UNIQUE(tasbih_id, date)
      )
    ''');
    final batch = db.batch();
    batch.insert('daily_goals', {'tasbih_id': 1, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert('daily_goals', {'tasbih_id': 2, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert('daily_goals', {'tasbih_id': 3, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert('daily_goals', {'tasbih_id': 4, 'target_count': 10},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert('daily_goals', {'tasbih_id': 5, 'target_count': 10},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await batch.commit(noResult: true);
  }

  Future<void> _upgradeToV4(Database db) async {
    debugPrint("Applying V4 migration: Adding alias column and new data...");
    var tableInfo = await db.rawQuery('PRAGMA table_info(custom_tasbih)');
    bool aliasExists = tableInfo.any((column) => column['name'] == 'alias');

    if (!aliasExists) {
      await db.execute('ALTER TABLE custom_tasbih ADD COLUMN alias TEXT');
    }

    final batch = db.batch();
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
    batch.delete('custom_tasbih', where: 'id = ?', whereArgs: [1]);
    batch.insert(
        'custom_tasbih',
        {
          'text': 'سُبْحَانَ اللَّهِ',
          'sort_order': 6,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert(
        'custom_tasbih',
        {
          'text': 'الْحَمْدُ لِلَّهِ',
          'sort_order': 7,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert(
        'custom_tasbih',
        {
          'text': 'لَا إِلَهَ إِلَّا اللَّهُ',
          'sort_order': 8,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert(
        'custom_tasbih',
        {
          'text': 'اللَّهُ أَكْبَرُ',
          'sort_order': 9,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await batch.commit();
  }
}
