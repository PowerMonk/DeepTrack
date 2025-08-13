import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'daily_stats';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'deeptrack.db');

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        work_hours INTEGER NOT NULL,
        work_goal INTEGER NOT NULL,
        study_hours INTEGER NOT NULL,
        study_goal INTEGER NOT NULL,
        social_hours INTEGER NOT NULL,
        social_goal INTEGER NOT NULL,
        exercise_hours INTEGER NOT NULL,
        exercise_goal INTEGER NOT NULL,
        rest_hours INTEGER NOT NULL,
        rest_goal INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> insertDailyStats({
    required String date,
    required int workHours,
    required int workGoal,
    required int studyHours,
    required int studyGoal,
    required int socialHours,
    required int socialGoal,
    required int exerciseHours,
    required int exerciseGoal,
    required int restHours,
    required int restGoal,
  }) async {
    final db = await database;

    await db.insert(tableName, {
      'date': date,
      'work_hours': workHours,
      'work_goal': workGoal,
      'study_hours': studyHours,
      'study_goal': studyGoal,
      'social_hours': socialHours,
      'social_goal': socialGoal,
      'exercise_hours': exerciseHours,
      'exercise_goal': exerciseGoal,
      'rest_hours': restHours,
      'rest_goal': restGoal,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> getDailyStats(String date) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [date],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  static Future<List<Map<String, dynamic>>> getAllDailyStats() async {
    final db = await database;
    return await db.query(tableName, orderBy: 'date DESC');
  }

  static Future<void> deleteDailyStats(String date) async {
    final db = await database;
    await db.delete(tableName, where: 'date = ?', whereArgs: [date]);
  }

  // Get the database file path
  static Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'deeptrack.db');
  }
}
