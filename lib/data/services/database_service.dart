// lib/data/services/database_service.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// هذا الكلاس مسؤول فقط عن إدارة اتصال قاعدة البيانات.
/// يوفر نقطة وصول واحدة (Singleton) لقاعدة البيانات ويضمن تهيئتها مرة واحدة فقط.
class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  static const String _dbName = "azkar.db";
  static const int _dbVersion = 2;

  /// دالة لإغلاق قاعدة البيانات، تستخدم بشكل أساسي في الاختبارات.
  @visibleForTesting
  Future<void> closeDatabaseForTest() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Getter رئيسي للوصول إلى قاعدة البيانات.
  /// إذا لم تكن مهيأة، سيقوم بتهيئتها أولاً.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// دالة التهيئة: تتحقق من وجود قاعدة البيانات، وتنسخها من الـ assets إذا لم تكن موجودة،
  /// ثم تفتحها وتتعامل مع الترقيات.
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
      onUpgrade: _onUpgrade,
    );
  }

  /// دالة الترقية: يتم استدعاؤها عند زيادة رقم إصدار قاعدة البيانات.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 2) {
      await _createGoalTables(db);
      debugPrint("New tables (daily_goals, goal_progress) added on upgrade.");
    }
  }

  /// دالة لإنشاء جداول الأهداف عند الترقية.
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
}
