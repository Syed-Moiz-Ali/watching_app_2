// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/data/models/content_item.dart';

// Content type constants
class ContentTypes {
  static const String VIDEO = 'video';
  static const String TIKTOK = 'tiktok';
  static const String IMAGE = 'photos';
  static const String MANGA = 'manga';
  static const String ANIME = 'anime';

  // List of all available content types for validation
  static const List<String> ALL_TYPES = [VIDEO, TIKTOK, IMAGE, MANGA, ANIME];

  // Validate if a content type is valid
  static bool isValidType(String type) {
    return ALL_TYPES.contains(type);
  }
}

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  // Database table and column names
  static const String SOURCE_TABLE = 'content_sources';
  static const String FAVORITES_TABLE = 'favorites';

  // Column names for better maintainability
  static const String COLUMN_ID = 'id';
  static const String COLUMN_TITLE = 'title';
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
  static const String COLUMN_URL = 'url';
  static const String COLUMN_SEARCH_URL = 'search_url';
  static const String COLUMN_TYPE = 'type';
  static const String COLUMN_DECODE_TYPE = 'decode_type';
  static const String COLUMN_NSFW = 'nsfw';
  static const String COLUMN_GET_TYPE = 'get_type';
  static const String COLUMN_IS_PREVIEW = 'is_preview';
  static const String COLUMN_IS_EMBED = 'is_embed';
  static const String COLUMN_NAME = 'name';
  static const String COLUMN_ICON = 'icon';
  static const String COLUMN_PAGE_TYPE = 'page_type';
  static const String COLUMN_QUERY = 'query';

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
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    // const boolType = 'INTEGER NOT NULL'; // For boolean values (0 or 1)
    const timestampType = 'TEXT NOT NULL';

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
        $COLUMN_QUERY $textType
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
        $COLUMN_SOURCE_ID INTEGER NOT NULL,
        $COLUMN_SCRAPED_AT $timestampType,
        $COLUMN_CONTENT_TYPE $textType,
        $COLUMN_ADDED_AT $timestampType,
        FOREIGN KEY ($COLUMN_SOURCE_ID) REFERENCES $SOURCE_TABLE ($COLUMN_ID)
      )
    ''');
  }

  // Add a content item to favorites
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

  // Store content source and return its ID
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
    };

    return await db.insert(SOURCE_TABLE, sourceMap);
  }

  // Remove from favorites
  Future<int> removeFromFavorites(int id) async {
    final db = await database;
    return await db.delete(
      FAVORITES_TABLE,
      where: '$COLUMN_ID = ?',
      whereArgs: [id],
    );
  }

  Future<bool> removeFromFavoritesByContentUrl(String contentUrl) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        LocalDatabase.FAVORITES_TABLE,
        where: '${LocalDatabase.COLUMN_CONTENT_URL} = ?',
        whereArgs: [contentUrl],
      );
      final success = rowsAffected > 0;
      print('Remove by content URL ${success ? 'succeeded' : 'failed'}');
      return success;
    } catch (e) {
      throw Exception('Failed to remove by content URL: $e');
    }
  }

  // Check if an item is in favorites
  Future<bool> isFavorite(String contentUrl) async {
    final db = await database;
    final result = await db.query(
      FAVORITES_TABLE,
      where: '$COLUMN_CONTENT_URL = ?',
      whereArgs: [contentUrl],
    );
    return result.isNotEmpty;
  }

  // Get all favorites by content type
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
      final queryMap = jsonDecode(sourceMap[COLUMN_QUERY] as String);

      // Recreate ContentSource
      final source = ContentSource(
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
      );

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
      );
    }).toList());
  }

  // Get all favorites
  Future<List<ContentItem>> getAllFavorites() async {
    final db = await database;
    final favorites = await db.query(
      FAVORITES_TABLE,
      orderBy: '$COLUMN_ADDED_AT DESC',
    );

    return await Future.wait(favorites.map((favorite) async {
      final sources = await db.query(
        SOURCE_TABLE,
        where: '$COLUMN_ID = ?',
        whereArgs: [favorite[COLUMN_SOURCE_ID]],
      );

      if (sources.isEmpty) {
        throw Exception('Content source not found');
      }

      final sourceMap = sources.first;
      final queryMap = jsonDecode(sourceMap[COLUMN_QUERY] as String);

      final source = ContentSource(
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
      );

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
      );
    }).toList());
  }

  // Get favorites count by type
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

  // Get total favorites count
  Future<int> getTotalFavoritesCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $FAVORITES_TABLE');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }

  Future<String> createBackup() async {
    try {
      final db = await database;

      // Get the application documents directory
      final directory = await getDownloadsDirectory();

      // Create a backup directory if it doesn't exist
      final backupDir = Directory('${directory!.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Generate backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = '${backupDir.path}/favorites_backup_$timestamp.db';

      // Get current database path
      final dbPath = db.path;

      // Copy the database file to backup location
      final dbFile = File(dbPath);
      await dbFile.copy(backupPath);

      return backupPath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Restore database from a backup file
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

  // Delete a specific backup
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
}
