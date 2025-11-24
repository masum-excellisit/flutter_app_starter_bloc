import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A generic, JSON-based local cache for any model type. This stores one row
/// per item containing the id and the whole JSON-serialized object. This keeps
/// the schema generic and usable for arbitrary models.
class GenericLocalDataSource<T, Id> {
  static const String _databaseName = 'app_cache.db';
  final String tableName; // table used for this model
  final Id Function(T item) idSelector;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T item) toJson;

  GenericLocalDataSource({
    required this.tableName,
    required this.idSelector,
    required this.fromJson,
    required this.toJson,
  });

  Database? _database;
  static const int _databaseVersion = 1;

  Future<Database> _getDatabase() async {
    if (_database != null) return _database!;

    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await _createTable(db);
      },
      onOpen: (Database db) async {
        await _createTable(db);
      },
    );

    return _database!;
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY,
        json TEXT
      )
    ''');
  }

  Future<void> cacheItems(List<T> items) async {
    final db = await _getDatabase();
    final Batch batch = db.batch();
    batch.delete(tableName);

    for (final item in items) {
      final Map<String, dynamic> jsonMap = toJson(item);
      final dynamic id = idSelector(item);
      batch.insert(
        tableName,
        {
          'id': id,
          'json': jsonEncode(jsonMap),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<T>> getCachedItems() async {
    final db = await _getDatabase();
    final rows = await db.query(
      tableName,
      orderBy: 'id ASC',
    );

    return rows.map((r) {
      final rawJson = r['json'] as String? ?? '{}';
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(jsonDecode(rawJson));
      return fromJson(map);
    }).toList();
  }

  Future<void> clearCache() async {
    final db = await _getDatabase();
    await db.delete(tableName);
  }

  Future<void> close() async {
    final Database? db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }
}
