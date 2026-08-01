import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warehouse.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // increase version or delete the app if there is any changes
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
        token TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT DEFAULT 'operator'
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        remarks TEXT,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_outs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        destination TEXT,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');
  }
}
