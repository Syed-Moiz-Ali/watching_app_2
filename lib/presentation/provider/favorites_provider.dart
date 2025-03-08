import 'package:flutter/material.dart';
import 'package:watching_app_2/data/models/content_item.dart';

import '../../core/services/database_manager.dart';
import '../../data/database/local_database.dart';

// Favorites provider that manages favorites state
class FavoritesProvider with ChangeNotifier {
  // DatabaseManager instance instead of LocalDatabase
  final DatabaseManager _dbManager = DatabaseManager();

  // Cache for favorites
  final Map<String, List<ContentItem>> _favoritesByType = {};
  List<ContentItem>? _allFavorites;

  // Cache for counts
  final Map<String, int> _countsCache = {};
  int? _totalCount;

  // Flag to track initial load
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Initialize provider and load data
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await _loadAllFavorites();
      _isInitialized = true;
    } finally {
      _setLoading(false);
    }
  }

  // Get all favorites
  Future<List<ContentItem>> getAllFavorites() async {
    if (_allFavorites == null) {
      await _loadAllFavorites();
    }
    return _allFavorites ?? [];
  }

  // Load all favorites from database
  Future<void> _loadAllFavorites() async {
    _allFavorites = await _dbManager.getAllFavorites();

    // Clear and rebuild type-specific caches
    _favoritesByType.clear();
    _countsCache.clear();

    // Group by content type
    for (final type in ContentTypes.ALL_TYPES) {
      _favoritesByType[type] = _allFavorites!
          .where((item) => _getContentType(item) == type)
          .toList();
      _countsCache[type] = _favoritesByType[type]!.length;
    }

    _totalCount = _allFavorites!.length;
  }

  // Helper method to determine content type of an item
  String _getContentType(ContentItem item) {
    // This is just a placeholder - implement your actual logic
    if (item.source.type.contains('video')) {
      return ContentTypes.VIDEO;
    } else if (item.source.type.contains('tiktok')) {
      return ContentTypes.TIKTOK;
    } else if (item.source.type.contains('image')) {
      return ContentTypes.IMAGE;
    } else if (item.source.type.contains('manga')) {
      return ContentTypes.MANGA;
    } else if (item.source.type.contains('anime')) {
      return ContentTypes.ANIME;
    } else {
      // Default fallback
      return ContentTypes.VIDEO;
    }
  }

  // Get favorites by type
  Future<List<ContentItem>> getFavoritesByType(String contentType) async {
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    if (!_isInitialized || _favoritesByType[contentType] == null) {
      _setLoading(true);
      try {
        _favoritesByType[contentType] =
            await _dbManager.getFavoritesByType(contentType);
        _countsCache[contentType] = _favoritesByType[contentType]!.length;
      } finally {
        _setLoading(false);
      }
    }

    return _favoritesByType[contentType] ?? [];
  }

  // Add to favorites
  Future<void> addToFavorites(ContentItem item, String contentType) async {
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    _setLoading(true);
    try {
      await _dbManager.addToFavorites(item, contentType);

      // Update caches
      if (_favoritesByType[contentType] != null) {
        _favoritesByType[contentType]!.add(item);
      }

      if (_allFavorites != null) {
        _allFavorites!.add(item);
      }

      // Update counts
      _countsCache[contentType] = (_countsCache[contentType] ?? 0) + 1;
      _totalCount = (_totalCount ?? 0) + 1;

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(ContentItem item, String contentType) async {
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    _setLoading(true);
    try {
      final bool isFavorite = await _dbManager.isFavorite(item.contentUrl);
      if (isFavorite) {
        // Using removeFromFavorites with ID would be ideal, but since we only have contentUrl
        // we'll need to modify DatabaseManager to support this
        await _dbManager.removeFromFavoritesByContentUrl(item.contentUrl);

        // Update caches
        if (_favoritesByType[contentType] != null) {
          _favoritesByType[contentType]!.removeWhere(
              (favorite) => favorite.contentUrl == item.contentUrl);
        }

        if (_allFavorites != null) {
          _allFavorites!.removeWhere(
              (favorite) => favorite.contentUrl == item.contentUrl);
        }

        // Update counts
        _countsCache[contentType] = (_countsCache[contentType] ?? 1) - 1;
        _totalCount = (_totalCount ?? 1) - 1;

        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(ContentItem item, String contentType) async {
    final bool isFavorite = await _dbManager.isFavorite(item.contentUrl);
    if (isFavorite) {
      await removeFromFavorites(item, contentType);
    } else {
      await addToFavorites(item, contentType);
    }
  }

  // Check if an item is favorite
  Future<bool> isFavorite(String contentUrl) async {
    return await _dbManager.isFavorite(contentUrl);
  }

  // Get count by type
  Future<int> getCountByType(String contentType) async {
    if (!ContentTypes.isValidType(contentType)) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    if (_countsCache.containsKey(contentType)) {
      return _countsCache[contentType]!;
    }

    final count = await _dbManager.getFavoritesCountByType(contentType);
    _countsCache[contentType] = count;
    return count;
  }

  // Get total count
  Future<int> getTotalCount() async {
    if (_totalCount != null) {
      return _totalCount!;
    }

    _totalCount = await _dbManager.getTotalFavoritesCount();
    return _totalCount!;
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Clear cache and reload data
  Future<void> refresh() async {
    _allFavorites = null;
    _favoritesByType.clear();
    _countsCache.clear();
    _totalCount = null;

    _setLoading(true);
    try {
      await _loadAllFavorites();
    } finally {
      _setLoading(false);
    }
  }

  // Additional methods using DatabaseManager features
  Future<String> createBackup() async {
    return await _dbManager.backupDatabase();
  }

  Future<void> restoreBackup(String backupPath) async {
    await _dbManager.restoreDatabase(backupPath);
    await refresh(); // Refresh the cache after restore
  }

  Future<void> deleteBackup(String backupPath) async {
    await _dbManager.deleteBackup(backupPath);
  }
}
