import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class StorageService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'vaultx.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            front_path TEXT,
            back_path TEXT,
            created_at TEXT
          )
        ''');
      },
    );
  }

  static Future<String> saveImage(File image, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(p.join(dir.path, 'vault_images'));
    if (!await vaultDir.exists()) await vaultDir.create(recursive: true);
    final savedPath = p.join(vaultDir.path, fileName);
    await image.copy(savedPath);
    return savedPath;
  }

  static Future<int> saveDocument({
    required String name,
    required String category,
    required String frontPath,
    String? backPath,
  }) async {
    final database = await db;
    return database.insert('documents', {
      'name': name,
      'category': category,
      'front_path': frontPath,
      'back_path': backPath,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getDocumentsByCategory(
      String category) async {
    final database = await db;
    return database.query(
      'documents',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  static Future<void> deleteDocument(int id) async {
    final database = await db;
    await database.delete('documents', where: 'id = ?', whereArgs: [id]);
  }
}
