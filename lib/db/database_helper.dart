import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = "breathing_logs.db";
  static const int dbVersion = 1;
  static const String tableName = "logs";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocDir.path, dbName);

    return await openDatabase(
      dbPath,
      version: dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        startTime TEXT,
        endTime TEXT,
        totalTime TEXT
      )
    ''');
  }

  Future<int> insertLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert(tableName, log);
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await database;
    return await db.query(tableName, orderBy: "id DESC");
  }

  Future<int> deleteLog(int id) async {
    final db = await database;
    return await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
}
