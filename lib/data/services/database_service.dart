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

  @visibleForTesting
  Future<void> testOnUpgrade(Database db, int oldV, int newV) async {
    await _onUpgrade(db, oldV, newV);
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
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint(
        "Creating database for the first time, applying all migrations from scratch...");
    await _onUpgrade(db, 0, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion...");
    final batch = db.batch();

    // ✨ [الإصلاح] الخطوة 0: إنشاء الجداول الأساسية إذا لم تكن موجودة.
    // هذا يضمن أن بيئة الاختبار (التي تبدأ من الصفر) سيكون لديها الجداول اللازمة.
    // استخدام `IF NOT EXISTS` آمن تمامًا ولن يؤثر على قواعد البيانات الموجودة.
    if (oldVersion < 1) {
      batch.execute('''
        CREATE TABLE IF NOT EXISTS adhkar (
            id INTEGER PRIMARY KEY,
            category TEXT NOT NULL,
            text TEXT NOT NULL,
            count INTEGER NOT NULL,
            virtue TEXT,
            note TEXT,
            sort_order INTEGER
        )
      ''');
      batch.execute('''
        CREATE TABLE IF NOT EXISTS custom_tasbih (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            sort_order INTEGER,
            is_deletable INTEGER DEFAULT 1 NOT NULL
        )
      ''');
    }

    // الترقيات المتسلسلة
    if (oldVersion < 2) {
      debugPrint("Applying V2 migration: Creating goal tables...");
      _createGoalTablesV2(batch);
    }
    if (oldVersion < 3) {
      debugPrint(
          "Applying V3 migration: Creating tasbih_daily_progress table...");
      await _upgradeToV3(batch, db); // Needs db for inserts
    }
    if (oldVersion < 4) {
      debugPrint("Applying V4 migration: Adding alias column and new data...");
      await _upgradeToV4(batch, db); // Needs db for PRAGMA check
    }

    await batch.commit();
  }

  // تم تحويلها لتستخدم Batch لتكون جزء من معاملة واحدة
  void _createGoalTablesV2(Batch batch) {
    batch.execute('''
        CREATE TABLE IF NOT EXISTS daily_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tasbih_id INTEGER NOT NULL UNIQUE,
          target_count INTEGER NOT NULL,
          FOREIGN KEY (tasbih_id) REFERENCES custom_tasbih (id) ON DELETE CASCADE
        )
      ''');
    batch.execute('''
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

  Future<void> _upgradeToV3(Batch batch, Database db) async {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS tasbih_daily_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tasbih_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (tasbih_id) REFERENCES custom_tasbih (id) ON DELETE CASCADE,
        UNIQUE(tasbih_id, date)
      )
    ''');
    // Note: Data insertion should ideally be separate, but let's keep it for now
    // We will commit the batch before this to ensure tables exist
    await batch.commit(noResult: true);
    // New batch for data
    final dataBatch = db.batch();
    dataBatch.insert('daily_goals', {'tasbih_id': 1, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    dataBatch.insert('daily_goals', {'tasbih_id': 2, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    dataBatch.insert('daily_goals', {'tasbih_id': 3, 'target_count': 100},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    dataBatch.insert('daily_goals', {'tasbih_id': 4, 'target_count': 10},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    dataBatch.insert('daily_goals', {'tasbih_id': 5, 'target_count': 10},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await dataBatch.commit(noResult: true);
  }

  Future<void> _upgradeToV4(Batch batch, Database db) async {
    // Commit previous changes to ensure table exists before altering it
    await batch.commit(noResult: true);

    var tableInfo = await db.rawQuery('PRAGMA table_info(custom_tasbih)');
    bool aliasExists = tableInfo.any((column) => column['name'] == 'alias');

    if (!aliasExists) {
      await db.execute('ALTER TABLE custom_tasbih ADD COLUMN alias TEXT');
    }

    final dataBatch = db.batch();
    dataBatch.update('custom_tasbih', {'alias': 'الاستغفار'},
        where: 'id = ?', whereArgs: [2]);
    dataBatch.update('custom_tasbih', {'alias': 'الحوقلة'},
        where: 'id = ?', whereArgs: [3]);
    dataBatch.update('custom_tasbih', {'alias': 'التسبيح'},
        where: 'id = ?', whereArgs: [4]);
    dataBatch.update('custom_tasbih', {'alias': 'التوحيد'},
        where: 'id = ?', whereArgs: [5]);
    dataBatch.update('custom_tasbih', {'alias': 'الصلاة على النبي'},
        where: 'id = ?', whereArgs: [6]);
    dataBatch.delete('custom_tasbih', where: 'id = ?', whereArgs: [1]);
    dataBatch.insert(
        'custom_tasbih',
        {
          'text': 'سُبْحَانَ اللَّهِ',
          'sort_order': 6,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    dataBatch.insert(
        'custom_tasbih',
        {
          'text': 'الْحَمْدُ لِلَّهِ',
          'sort_order': 7,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    dataBatch.insert(
        'custom_tasbih',
        {
          'text': 'لَا إِلَهَ إِلَّا اللَّهُ',
          'sort_order': 8,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    dataBatch.insert(
        'custom_tasbih',
        {
          'text': 'اللَّهُ أَكْبَرُ',
          'sort_order': 9,
          'is_deletable': 0,
          'alias': null
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    // This last commit belongs to the new batch
    await dataBatch.commit(noResult: true);
  }
}
