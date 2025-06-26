// lib/data/services/database_helper.dart
import 'dart:io';
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
    } else {
      debugPrint("Database already exists at $path.");
    }

    return await openDatabase(path);
  }

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

  // دالة جديدة لجلب الأذكار حسب الـ ID
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
    // للحفاظ على ترتيب المفضلة
    final adhkarList =
        List.generate(maps.length, (i) => AdhkarModel.fromMap(maps[i]));
    adhkarList.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    return adhkarList;
  }

  // دالة لجلب كل التسابيح المخصصة مرتبة
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
      where: 'id = ? AND is_deletable = ?', // شرط إضافي للأمان
      whereArgs: [id, 1],
    );
  }
}
