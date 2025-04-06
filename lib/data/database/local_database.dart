// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import '../models/scraper_config.dart';

/// Content type constants for the application
class ContentTypes {
  // Content category constants
  static const String VIDEO = 'videos';
  static const String TIKTOK = 'tiktok';
  static const String IMAGE = 'photos';
  static const String MANGA = 'manga';
  static const String ANIME = 'anime';

  // List of all available content types for validation
  static const List<String> ALL_TYPES = [VIDEO, TIKTOK, IMAGE, MANGA, ANIME];
  static const Map<String, String> TYPE_TO_CATEGORY = {
    '1': VIDEO,
    '2': TIKTOK,
    '3': IMAGE,
    '4': MANGA,
    '5': ANIME,
  };

  /// Validates if a content type is supported
  static bool isValidType(String type) => ALL_TYPES.contains(type);
}

/// Database class for local storage of content and favorites
class LocalDatabase {
  // Singleton instance
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  // Database table names
  static const String SOURCE_TABLE = 'content_sources';
  static const String FAVORITES_TABLE = 'favorites';

  // Common column names
  static const String COLUMN_ID = 'id';
  static const String COLUMN_TITLE = 'title';
  static const String COLUMN_URL = 'url';
  static const String COLUMN_NAME = 'name';

  // Favorites table columns
  static const String COLUMN_DURATION = 'duration';
  static const String COLUMN_PREVIEW = 'preview';
  static const String COLUMN_QUALITY = 'quality';
  static const String COLUMN_TIME = 'time';
  static const String COLUMN_THUMBNAIL_URL = 'thumbnail_url';
  static const String COLUMN_CONTENT_URL = 'content_url';
  static const String COLUMN_VIEWS = 'views';
  static const String COLUMN_SOURCE_ID = 'source_id';
  static const String COLUMN_SCRAPED_AT = 'scraped_at';
  static const String COLUMN_CONTENT_TYPE = 'content_type';
  static const String COLUMN_ADDED_AT = 'added_at';

  // Source table columns
  static const String COLUMN_SEARCH_URL = 'search_url';
  static const String COLUMN_TYPE = 'type';
  static const String COLUMN_DECODE_TYPE = 'decode_type';
  static const String COLUMN_NSFW = 'nsfw';
  static const String COLUMN_GET_TYPE = 'get_type';
  static const String COLUMN_IS_PREVIEW = 'is_preview';
  static const String COLUMN_IS_EMBED = 'is_embed';
  static const String COLUMN_ICON = 'icon';
  static const String COLUMN_PAGE_TYPE = 'page_type';
  static const String COLUMN_QUERY = 'query';
  static const String COLUMN_CONFIG = 'config';
  static const String COLUMN_ENABLED = 'enabled';

  // Private constructor for singleton pattern
  LocalDatabase._init();

  /// Get the database instance, initializing if needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create database tables
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const timestampType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';
    const nullableIntType = 'INTEGER';

    // Create content_sources table
    await db.execute('''
      CREATE TABLE $SOURCE_TABLE (
        $COLUMN_ID $idType,
        $COLUMN_URL $textType,
        $COLUMN_SEARCH_URL $textType,
        $COLUMN_TYPE $textType,
        $COLUMN_DECODE_TYPE $textType,
        $COLUMN_NSFW $textType,
        $COLUMN_GET_TYPE $textType,
        $COLUMN_IS_PREVIEW $textType,
        $COLUMN_IS_EMBED $textType,
        $COLUMN_NAME $textType,
        $COLUMN_ICON $textType,
        $COLUMN_PAGE_TYPE $textType,
        $COLUMN_QUERY $textType,
        $COLUMN_CONFIG $nullableTextType,
        $COLUMN_ENABLED $nullableIntType
      )
    ''');

    // Create favorites table
    await db.execute('''
      CREATE TABLE $FAVORITES_TABLE (
        $COLUMN_ID $idType,
        $COLUMN_TITLE $textType,
        $COLUMN_DURATION $textType,
        $COLUMN_PREVIEW $textType,
        $COLUMN_QUALITY $textType,
        $COLUMN_TIME $textType,
        $COLUMN_THUMBNAIL_URL $textType,
        $COLUMN_CONTENT_URL $textType,
        $COLUMN_VIEWS $textType,
        $COLUMN_SOURCE_ID $intType,
        $COLUMN_SCRAPED_AT $timestampType,
        $COLUMN_CONTENT_TYPE $textType,
        $COLUMN_ADDED_AT $timestampType,
        FOREIGN KEY ($COLUMN_SOURCE_ID) REFERENCES $SOURCE_TABLE ($COLUMN_ID)
      )
    ''');
  }

  /// Add a content item to favorites
  Future<int> addToFavorites(ContentItem item, String contentType) async {
    // Validate content type
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final db = await database;

    // First, store or get the content source
    int sourceId = await _storeContentSource(item.source);

    // Convert ContentItem to a map for storage
    final favoriteMap = {
      COLUMN_TITLE: item.title,
      COLUMN_DURATION: item.duration,
      COLUMN_PREVIEW: item.preview,
      COLUMN_QUALITY: item.quality,
      COLUMN_TIME: item.time,
      COLUMN_THUMBNAIL_URL: item.thumbnailUrl,
      COLUMN_CONTENT_URL: item.contentUrl,
      COLUMN_VIEWS: item.views,
      COLUMN_SOURCE_ID: sourceId,
      COLUMN_SCRAPED_AT: item.scrapedAt.toIso8601String(),
      COLUMN_CONTENT_TYPE: contentType,
      COLUMN_ADDED_AT: DateTime.now().toIso8601String(),
    };

    return await db.insert(FAVORITES_TABLE, favoriteMap);
  }

  /// Store content source and return its ID
  Future<int> _storeContentSource(ContentSource source) async {
    final db = await database;

    // Check if the source already exists
    final List<Map<String, dynamic>> existingSources = await db.query(
      SOURCE_TABLE,
      where: '$COLUMN_NAME = ? AND $COLUMN_URL = ?',
      whereArgs: [source.name, source.url],
    );

    if (existingSources.isNotEmpty) {
      return existingSources.first[COLUMN_ID]; // Return existing ID
    }

    // Otherwise, insert new source
    final sourceMap = {
      COLUMN_URL: source.url,
      COLUMN_SEARCH_URL: source.searchUrl,
      COLUMN_TYPE: source.type,
      COLUMN_DECODE_TYPE: source.decodeType,
      COLUMN_NSFW: source.nsfw,
      COLUMN_GET_TYPE: source.getType,
      COLUMN_IS_PREVIEW: source.isPreview,
      COLUMN_IS_EMBED: source.isEmbed,
      COLUMN_NAME: source.name,
      COLUMN_ICON: source.icon,
      COLUMN_PAGE_TYPE: source.pageType,
      COLUMN_QUERY: jsonEncode(source.query), // Convert Map to JSON string
      COLUMN_CONFIG:
          source.config != null ? jsonEncode(source.config!.toJson()) : null,
      COLUMN_ENABLED: source.enabled != null ? (source.enabled! ? 1 : 0) : null,
    };

    return await db.insert(SOURCE_TABLE, sourceMap);
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

      final success = rowsAffected > 0;
      if (kDebugMode) {
        print('Remove by content URL ${success ? 'succeeded' : 'failed'}');
      }
      return success;
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
    // Validate content type
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

    return await Future.wait(favorites.map((favorite) async {
      return await _mapToContentItem(favorite, db);
    }).toList());
  }

  /// Get all favorites
  Future<List<ContentItem>> getAllFavorites() async {
    final db = await database;
    final favorites = await db.query(
      FAVORITES_TABLE,
      orderBy: '$COLUMN_ADDED_AT DESC',
    );

    return await Future.wait(favorites.map((favorite) async {
      return await _mapToContentItem(favorite, db);
    }).toList());
  }

  /// Helper method to map a database row to a ContentItem
  Future<ContentItem> _mapToContentItem(
      Map<String, dynamic> favorite, Database db) async {
    // Get the associated content source
    final sources = await db.query(
      SOURCE_TABLE,
      where: '$COLUMN_ID = ?',
      whereArgs: [favorite[COLUMN_SOURCE_ID]],
    );

    if (sources.isEmpty) {
      throw Exception('Content source not found');
    }

    final sourceMap = sources.first;
    final source = _mapToContentSource(sourceMap);

    // Create ContentItem
    return ContentItem(
      title: favorite[COLUMN_TITLE] as String,
      duration: favorite[COLUMN_DURATION] as String,
      preview: favorite[COLUMN_PREVIEW] as String,
      quality: favorite[COLUMN_QUALITY] as String,
      time: favorite[COLUMN_TIME] as String,
      thumbnailUrl: favorite[COLUMN_THUMBNAIL_URL] as String,
      contentUrl: favorite[COLUMN_CONTENT_URL] as String,
      views: favorite[COLUMN_VIEWS] as String,
      source: source,
      scrapedAt: DateTime.parse(favorite[COLUMN_SCRAPED_AT] as String),
      addedAt: DateTime.parse(favorite[COLUMN_ADDED_AT] as String),
    );
  }

  /// Helper method to map a database row to a ContentSource
  ContentSource _mapToContentSource(Map<String, dynamic> sourceMap) {
    final queryMap = jsonDecode(sourceMap[COLUMN_QUERY] as String);
    final configJson = sourceMap[COLUMN_CONFIG] != null
        ? jsonDecode(sourceMap[COLUMN_CONFIG] as String)
        : null;

    return ContentSource(
      url: sourceMap[COLUMN_URL] as String,
      searchUrl: sourceMap[COLUMN_SEARCH_URL] as String,
      type: sourceMap[COLUMN_TYPE] as String,
      decodeType: sourceMap[COLUMN_DECODE_TYPE] as String,
      nsfw: sourceMap[COLUMN_NSFW] as String,
      getType: sourceMap[COLUMN_GET_TYPE] as String,
      isPreview: sourceMap[COLUMN_IS_PREVIEW] as String,
      isEmbed: sourceMap[COLUMN_IS_EMBED] as String,
      name: sourceMap[COLUMN_NAME] as String,
      icon: sourceMap[COLUMN_ICON] as String,
      pageType: sourceMap[COLUMN_PAGE_TYPE] as String,
      query: Map<String, String>.from(queryMap),
      config: configJson != null ? ScraperConfig.fromJson(configJson) : null,
      enabled: sourceMap[COLUMN_ENABLED] != null
          ? (sourceMap[COLUMN_ENABLED] as int == 1)
          : null,
    );
  }

  /// Get favorites count by type
  Future<int> getFavoritesCountByType(String contentType) async {
    // Validate content type
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $FAVORITES_TABLE WHERE $COLUMN_CONTENT_TYPE = ?',
        [contentType]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total favorites count
  Future<int> getTotalFavoritesCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $FAVORITES_TABLE');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Create a backup of the database
  Future<String> createBackup() async {
    try {
      final db = await database;

      // Get the application downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create a backup directory if it doesn't exist
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Generate backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = '${backupDir.path}/favorites_backup_$timestamp.db';

      // Copy the database file to backup location
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

      // Close the current database
      await db.close();
      _database = null; // Reset the database instance

      // Get current database path
      final currentDbPath = await getDatabasesPath();
      final dbPath = join(currentDbPath, 'favorites.db');

      // Copy backup file to current database location
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Delete existing database file if it exists
      final currentDbFile = File(dbPath);
      if (await currentDbFile.exists()) {
        await currentDbFile.delete();
      }

      // Restore by copying backup to original location
      await backupFile.copy(dbPath);

      // Reinitialize the database
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
      } else {
        if (kDebugMode) {
          print('Backup file does not exist: $backupPath');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }
}
