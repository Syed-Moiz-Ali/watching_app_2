import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/data/models/content_source.dart';

/// Content type constants for the application
class ContentTypes {
  static const String VIDEO = 'videos';
  static const String TIKTOK = 'tiktok';
  static const String IMAGE = 'photos';
  static const String MANGA = 'manga';
  static const String ANIME = 'anime';

  static const List<String> ALL_TYPES = [VIDEO, TIKTOK, IMAGE, MANGA, ANIME];

  static bool isValidType(String type) => ALL_TYPES.contains(type);
  static const Map<String, String> TYPE_TO_CATEGORY = {
    '1': VIDEO,
    '2': TIKTOK,
    '3': IMAGE,
    '4': MANGA,
    '5': ANIME,
  };
}

/// Simplified database class for local storage
class LocalDatabase {
  // Singleton instance
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  // Table names
  static const String SOURCE_TABLE = 'content_sources';
  static const String FAVORITES_TABLE = 'favorites';

  // Column names
  static const String COLUMN_ID = 'id';
  static const String COLUMN_DATA = 'data';
  static const String COLUMN_CONTENT_TYPE = 'content_type';
  static const String COLUMN_ADDED_AT = 'added_at';
  static const String COLUMN_CONTENT_URL = 'content_url';

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const timestampType = 'TEXT NOT NULL';

    // Create content_sources table
    await db.execute('''
      CREATE TABLE $SOURCE_TABLE (
        $COLUMN_ID $idType,
        $COLUMN_DATA $textType
      )
    ''');

    // Create favorites table
    await db.execute('''
      CREATE TABLE $FAVORITES_TABLE (
        $COLUMN_ID $idType,
        $COLUMN_DATA $textType,
        $COLUMN_CONTENT_TYPE $textType,
        $COLUMN_CONTENT_URL $textType,
        $COLUMN_ADDED_AT $timestampType
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
    if (oldVersion < 1) {
      await _createDB(db, newVersion);
    }
  }

  /// Add a content item to favorites
  Future<int> addToFavorites(ContentItem item, String contentType) async {
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final db = await database;

    // Store content source and get its ID
    final sourceId = await _storeContentSource(item.source);

    final favoriteData = {
      COLUMN_DATA: jsonEncode(item.toJson()),
      COLUMN_CONTENT_TYPE: contentType,
      COLUMN_CONTENT_URL: item.contentUrl,
      COLUMN_ADDED_AT: DateTime.now().toIso8601String(),
    };

    return await db.insert(FAVORITES_TABLE, favoriteData);
  }

  /// Store content source and return its ID
  Future<int> _storeContentSource(ContentSource source) async {
    final db = await database;

    // Check if source exists by comparing JSON data
    final sourceJson = jsonEncode(source.toJson());
    final existingSources = await db.query(
      SOURCE_TABLE,
      where: '$COLUMN_DATA = ?',
      whereArgs: [sourceJson],
    );

    if (existingSources.isNotEmpty) {
      return existingSources.first[COLUMN_ID] as int;
    }

    return await db.insert(SOURCE_TABLE, {COLUMN_DATA: sourceJson});
  }

  /// Remove content item from favorites by ID
  Future<int> removeFromFavorites(int id) async {
    final db = await database;
    return await db.delete(
      FAVORITES_TABLE,
      where: '$COLUMN_ID = ?',
      whereArgs: [id],
    );
  }

  /// Remove content item from favorites by content URL
  Future<bool> removeFromFavoritesByContentUrl(String contentUrl) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        FAVORITES_TABLE,
        where: '$COLUMN_CONTENT_URL = ?',
        whereArgs: [contentUrl],
      );
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Failed to remove by content URL: $e');
    }
  }

  /// Check if an item is in favorites
  Future<bool> isFavorite(String contentUrl) async {
    final db = await database;
    final result = await db.query(
      FAVORITES_TABLE,
      where: '$COLUMN_CONTENT_URL = ?',
      whereArgs: [contentUrl],
    );
    return result.isNotEmpty;
  }

  /// Get all favorites by content type
  Future<List<ContentItem>> getFavoritesByType(String contentType) async {
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final db = await database;
    final favorites = await db.query(
      FAVORITES_TABLE,
      where: '$COLUMN_CONTENT_TYPE = ?',
      whereArgs: [contentType],
      orderBy: '$COLUMN_ADDED_AT DESC',
    );

    return favorites
        .map((fav) =>
            ContentItem.fromJson(jsonDecode(fav[COLUMN_DATA] as String)))
        .toList();
  }

  /// Get all favorites
  Future<List<ContentItem>> getAllFavorites() async {
    final db = await database;
    final favorites = await db.query(
      FAVORITES_TABLE,
      orderBy: '$COLUMN_ADDED_AT DESC',
    );

    return favorites
        .map((fav) =>
            ContentItem.fromJson(jsonDecode(fav[COLUMN_DATA] as String)))
        .toList();
  }

  /// Get favorites count by type
  Future<int> getFavoritesCountByType(String contentType) async {
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $FAVORITES_TABLE WHERE $COLUMN_CONTENT_TYPE = ?',
      [contentType],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total favorites count
  Future<int> getTotalFavoritesCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $FAVORITES_TABLE');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Create a backup of the database
  Future<String> createBackup() async {
    try {
      final db = await database;
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = '${backupDir.path}/favorites_backup_$timestamp.db';

      final dbFile = File(db.path);
      await dbFile.copy(backupPath);

      return backupPath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Restore database from a backup file
  Future<void> restoreBackup(String backupPath) async {
    try {
      final db = await database;
      await db.close();
      _database = null;

      final currentDbPath = await getDatabasesPath();
      final dbPath = join(currentDbPath, 'favorites.db');

      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      final currentDbFile = File(dbPath);
      if (await currentDbFile.exists()) {
        await currentDbFile.delete();
      }

      await backupFile.copy(dbPath);
      _database = await _initDB('favorites.db');
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  /// Delete a specific backup
  Future<void> deleteBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
