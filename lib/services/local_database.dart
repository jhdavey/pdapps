import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        displayName TEXT NOT NULL,
        email TEXT NOT NULL,
        isEmailVerified INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE builds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Add this new method
  Future<List<Map<String, dynamic>>> getAllBuildsJoined() async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        b.id AS buildId,
        b.make,
        b.model,
        b.year,
        b.userId,
        u.displayName
      FROM builds b
      INNER JOIN users u ON b.userId = u.id
      ORDER BY b.id DESC
    ''');
  }

  Future close() async {
    final db = _database;
    if (db != null) await db.close();
  }
}
