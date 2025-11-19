import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lead.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('leads.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE leads (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      contact TEXT NOT NULL,
      status TEXT NOT NULL,
      notes TEXT,
      createdTime TEXT NOT NULL
    )
    ''');
  }

  Future<List<Lead>> readLeads({int limit = 10, int page = 1}) async {
    final db = await instance.database;
    final offset = (page - 1) * limit;

    final result = await db.query(
      'leads',
      orderBy: 'createdTime DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((json) => Lead.fromMap(json)).toList();
  }

  Future<List<Lead>> searchLeads(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'leads',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'createdTime DESC',
    );
    return result.map((json) => Lead.fromMap(json)).toList();
  }

  Future<int> create(Lead lead) async {
    final db = await instance.database;
    return await db.insert('leads', lead.toMap());
  }

  Future<int> update(Lead lead) async {
    final db = await instance.database;
    return db.update('leads', lead.toMap(), where: 'id = ?', whereArgs: [lead.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('leads', where: 'id = ?', whereArgs: [id]);
  }
}