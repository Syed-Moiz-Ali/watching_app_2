import 'dart:developer';

import 'package:watching_app_2/data/models/content_item.dart';

import '../../data/database/local_database.dart'; // Adjust import path as needed

class DatabaseManager {
  final LocalDatabase _db = LocalDatabase.instance;

  // Singleton pattern (optional)
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  // Backup Operations
  // Future<String> backupDatabase() async {
  //   try {
  //     final backupPath = await _db.createBackup();
  //     return backupPath;
  //   } catch (e) {
  //     throw Exception('Backup failed: $e');
  //   }
  // }

  Future<void> restoreDatabase(String backupPath) async {
    try {
      await _db.restoreBackup(backupPath);
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }

  Future<void> deleteBackup(String backupPath) async {
    try {
      await _db.deleteBackup(backupPath);
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }

  // Favorite Operations
  Future<int> addToFavorites(ContentItem item, String contentType) async {
    try {
      final id = await _db.addToFavorites(item, contentType);
      return id;
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<int> removeFromFavorites(int id) async {
    try {
      final rowsAffected = await _db.removeFromFavorites(id);
      rowsAffected > 0;
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<bool> removeFromFavoritesByContentUrl(String url) async {
    try {
      final rowsAffected = await _db.removeFromFavoritesByContentUrl(url);
      final success = rowsAffected == true;
      return success;
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<bool> isFavorite(String contentUrl) async {
    try {
      final isFav = await _db.isFavorite(contentUrl);
      return isFav;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  Future<List<ContentItem>> getFavoritesByType(String contentType) async {
    try {
      final favorites = await _db.getFavoritesByType(contentType);
      log("favorites from db is $favorites");
      return favorites;
    } catch (e) {
      throw Exception('Failed to get favorites by type: $e');
    }
  }

  Future<List<ContentItem>> getAllFavorites() async {
    try {
      final favorites = await _db.getAllFavorites();
      return favorites;
    } catch (e) {
      throw Exception('Failed to get all favorites: $e');
    }
  }

  Future<int> getFavoritesCountByType(String contentType) async {
    try {
      final count = await _db.getFavoritesCountByType(contentType);
      return count;
    } catch (e) {
      throw Exception('Failed to get favorites count by type: $e');
    }
  }

  Future<int> getTotalFavoritesCount() async {
    try {
      final count = await _db.getTotalFavoritesCount();
      return count;
    } catch (e) {
      throw Exception('Failed to get total favorites count: $e');
    }
  }

  // Database Management
  Future<void> closeDatabase() async {
    try {
      await _db.close();
    } catch (e) {
      throw Exception('Failed to close database: $e');
    }
  }

  // Additional Utility Methods
  Future<void> clearFavorites() async {
    try {
      final db = await _db.database;
      await db.delete(LocalDatabase.FAVORITES_TABLE);
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }

  Future<void> clearSources() async {
    try {
      final db = await _db.database;
      await db.delete(LocalDatabase.SOURCE_TABLE);
    } catch (e) {
      throw Exception('Failed to clear sources: $e');
    }
  }

  Future<void> resetDatabase() async {
    try {
      final db = await _db.database;
      await db.delete(LocalDatabase.FAVORITES_TABLE);
      await db.delete(LocalDatabase.SOURCE_TABLE);
    } catch (e) {
      throw Exception('Failed to reset database: $e');
    }
  }
}
