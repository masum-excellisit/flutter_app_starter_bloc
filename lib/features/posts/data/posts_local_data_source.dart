import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/post_model.dart';

class PostsLocalDataSource {
  static const String _databaseName = 'app_cache.db';
  static const String _tableName = 'posts';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }

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

  Future<void> cachePosts(List<PostModel> posts) async {
    final Database db = await _getDatabase();
    final Batch batch = db.batch();

    batch.delete(_tableName);

    for (final PostModel post in posts) {
      batch.insert(
        _tableName,
        <String, dynamic>{
          'id': post.id,
          'title': post.title,
          'body': post.body,
          'tags': jsonEncode(post.tags),
          'reactions': post.reactions,
          'reactionMeta': jsonEncode(post.reactionMeta ?? <String, dynamic>{}),
          'userId': post.userId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<PostModel>> getCachedPosts() async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      orderBy: 'id ASC',
    );

    return rows.map((Map<String, dynamic> row) {
      final List<dynamic> tagsRaw = jsonDecode(row['tags'] as String? ?? '[]');
      final dynamic reactionMetaRaw = row['reactionMeta'];
      Map<String, dynamic>? reactionMeta;
      if (reactionMetaRaw != null && reactionMetaRaw is String) {
        reactionMeta = Map<String, dynamic>.from(jsonDecode(reactionMetaRaw));
      }

      return PostModel(
        id: row['id'] as int,
        title: row['title'] as String? ?? '',
        body: row['body'] as String? ?? '',
        tags: tagsRaw.map((dynamic e) => e.toString()).toList(),
        reactions: row['reactions'] as int?,
        reactionMeta: reactionMeta,
        userId: row['userId'] as int?,
      );
    }).toList();
  }

  Future<void> clearCache() async {
    final Database db = await _getDatabase();
    await db.delete(_tableName);
  }

  Future<void> close() async {
    final Database? db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY,
        title TEXT,
        body TEXT,
        tags TEXT,
        reactions INTEGER,
        reactionMeta TEXT,
        userId INTEGER
      )
    ''');
  }
}
