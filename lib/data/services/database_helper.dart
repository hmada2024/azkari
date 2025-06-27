// lib/data/services/database_helper.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:azkari/data/models/daily_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/adhkar_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const String _dbName = "azkar.db";
  static const int _dbVersion = 2;

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
        // 1. نسخ قاعدة البيانات الأولية من Assets
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

    // 2. الآن، قم بفتح قاعدة البيانات مع تحديد الإصدار ودالة الترقية
    // سيتم استدعاء onUpgrade فقط إذا كان إصدار قاعدة البيانات على القرص < 2
    return await openDatabase(
      path,
      version: _dbVersion,
      onUpgrade: _onUpgrade,
    );
  }

  // دالة الترقية تبقى كما هي، وهي تُستدعى فقط عند الحاجة
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 2) {
      await _createGoalTables(db);
      debugPrint("New tables (daily_goals, goal_progress) added on upgrade.");
    }
  }

  // ❌ لم نعد بحاجة لدالة _onCreate بهذا الشكل المعقد.
  // عملية الإنشاء تمت معالجتها عبر نسخ الملف مباشرة.

  // دالة إنشاء جداول الأهداف تبقى كما هي
  Future<void> _createGoalTables(Database db) async {
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

  // --- باقي الدوال تبقى كما هي بدون أي تغيير ---
  Future<List<AdhkarModel>> getAdhkarByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'adhkar',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'sort_order ASC, id ASC',
    );
    return List.generate(maps.length, (i) => AdhkarModel.fromMap(maps[i]));
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT DISTINCT category FROM adhkar ORDER BY category');
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => maps[i]['category'] as String);
  }

  Future<List<AdhkarModel>> getAdhkarByIds(List<int> ids) async {
    final db = await database;
    if (ids.isEmpty) {
      return [];
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'adhkar',
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
    final adhkarList =
        List.generate(maps.length, (i) => AdhkarModel.fromMap(maps[i]));
    adhkarList.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    return adhkarList;
  }

  Future<List<TasbihModel>> getCustomTasbihList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'custom_tasbih',
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => TasbihModel.fromMap(maps[i]));
  }

  Future<TasbihModel> addTasbih(String text) async {
    final db = await database;
    final lastItem = await db
        .rawQuery("SELECT MAX(sort_order) as max_order FROM custom_tasbih");
    int newSortOrder = (lastItem.first['max_order'] as int? ?? 0) + 1;

    final newTasbih = {
      'text': text,
      'sort_order': newSortOrder,
      'is_deletable': 1,
    };

    final id = await db.insert('custom_tasbih', newTasbih);
    return TasbihModel(
        id: id, text: text, sortOrder: newSortOrder, isDeletable: true);
  }

  Future<void> deleteTasbih(int id) async {
    final db = await database;
    await db.delete(
      'custom_tasbih',
      where: 'id = ? AND is_deletable = ?',
      whereArgs: [id, 1],
    );
  }

  Future<void> setOrUpdateGoal(int tasbihId, int targetCount) async {
    final db = await database;
    await db.insert(
      'daily_goals',
      {'tasbih_id': tasbihId, 'target_count': targetCount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeGoal(int tasbihId) async {
    final db = await database;
    await db
        .delete('daily_goals', where: 'tasbih_id = ?', whereArgs: [tasbihId]);
  }

  Future<void> incrementGoalProgress(int goalId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await db.rawUpdate('''
      UPDATE goal_progress 
      SET current_count = current_count + 1 
      WHERE goal_id = ? AND date = ?
    ''', [goalId, today]);
  }

  Future<List<DailyGoalModel>> getGoalsWithTodayProgress() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _ensureTodayProgressRecords(db, today);
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        g.id as goalId, 
        g.tasbih_id as tasbihId, 
        t.text as tasbihText, 
        g.target_count as targetCount, 
        p.current_count as currentProgress
      FROM daily_goals g
      JOIN custom_tasbih t ON g.tasbih_id = t.id
      LEFT JOIN goal_progress p ON g.id = p.goal_id AND p.date = ?
      ORDER BY t.sort_order ASC
    ''', [today]);
    return List.generate(maps.length, (i) => DailyGoalModel.fromMap(maps[i]));
  }

  Future<void> _ensureTodayProgressRecords(Database db, String today) async {
    final List<Map<String, dynamic>> goals =
        await db.query('daily_goals', columns: ['id']);
    if (goals.isEmpty) return;
    final batch = db.batch();
    for (var goal in goals) {
      batch.insert(
        'goal_progress',
        {'goal_id': goal['id'], 'date': today, 'current_count': 0},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, dynamic>?> getGoalForTasbih(int tasbihId) async {
    final db = await database;
    final result = await db
        .query('daily_goals', where: 'tasbih_id = ?', whereArgs: [tasbihId]);
    return result.isNotEmpty ? result.first : null;
  }
}
