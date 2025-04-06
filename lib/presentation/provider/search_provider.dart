import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import '../../../data/models/content_item.dart';
import '../../../data/models/content_source.dart';
import '../../../data/scrapers/scraper_service.dart';
import '../../../core/services/source_manager.dart';

class SearchProvider with ChangeNotifier {
  Map<String, Map<String, List<ContentItem>>> _allCategoryResults = {};
  final List<String> _categories = ["videos", "movies", "tv_shows", "anime"];
  final Map<String, int> _currentPageMap = {};
  final Map<String, String?> _errorMap = {};
  final Map<String, bool> _hasMoreDataMap = {};
  bool _isGrid = false;
  bool _isLoading = false;
  final Map<String, bool> _isLoadingMoreMap = {};
  final Map<String, ScraperService> _scraperServices = {};
  final SourceManager _sourceManager = SourceManager();
  List<ContentSource> _sources = [];
  int _activeSourceIndex = 0;
  String _currentCategory = "videos";
  String _currentQuery = '';

  // Getters
  Map<String, Map<String, List<ContentItem>>> get allCategoryResults =>
      _allCategoryResults;
  List<String> get categories => _categories;
  bool get isGrid => _isGrid;
  bool get isLoading => _isLoading;
  String get currentCategory => _currentCategory;
  String get currentQuery => _currentQuery;
  List<ContentSource> get sources => _sources;
  int get activeSourceIndex => _activeSourceIndex;
  Map<String, String?> get errorMap => _errorMap;

  SearchProvider() {
    _initializeDataStructures();
  }

  setAllCategoryResults(Map val) {
    _allCategoryResults = Map.from(val);
    notifyListeners();
  }

  void _initializeDataStructures() {
    for (String category in _categories) {
      _allCategoryResults[category] = {};
      _isLoadingMoreMap[category] = false;
      _errorMap[category] = null;
      _currentPageMap[category] = 1;
      _hasMoreDataMap[category] = true;
    }
  }

  Future<void> loadSourcesAndSearch(String category, String query) async {
    _currentQuery = query;
    _isLoading = true;
    _activeSourceIndex = 0;
    notifyListeners();

    // Determine which categories to process
    List<String> categoriesToProcess =
        category.toLowerCase() == "all" ? ContentTypes.ALL_TYPES : [category];

    for (String currentCategory in categoriesToProcess) {
      _errorMap[currentCategory] = null;

      try {
        final loadedSources = await _sourceManager.loadSources(currentCategory);
        _sources = loadedSources;

        final activeSources = _sources.where((source) {
          final mappedCategory = ContentTypes.TYPE_TO_CATEGORY[source.type];
          return mappedCategory == currentCategory;
        }).toList();
        for (var source in activeSources) {
          // log("source.url is ${_scraperServices[source.url]}");
          if (_scraperServices[source.url] == null) {
            _scraperServices[source.url] = ScraperService(source);
          }
          _currentPageMap["${currentCategory}_${source.url}"] = 1;
          _hasMoreDataMap["${currentCategory}_${source.url}"] = true;
        }

        for (int i = 0; i < activeSources.length; i++) {
          _activeSourceIndex = i;
          notifyListeners();
          await _searchVideosFromSource(activeSources[i], currentCategory);
        }
      } catch (e) {
        _errorMap[currentCategory] = 'Failed to load sources: $e';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _searchVideosFromSource(
      ContentSource source, String category) async {
    String sourceKey = "${category}_${source.url}";

    try {
      final newVideos = await _scraperServices[source.url]!
          .search(_currentQuery, _currentPageMap[sourceKey] ?? 1);
      // log("newVideos is $newVideos");

      if (_allCategoryResults[category] == null) {
        _allCategoryResults[category] = {};
      }

      _allCategoryResults[category]![source.searchUrl] =
          newVideos.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      if (newVideos.isEmpty) {
        _hasMoreDataMap[sourceKey] = false;
      }
      log("_allCategoryResults is $_allCategoryResults");
      notifyListeners();
    } catch (e) {
      _errorMap["${category}_${source.url}"] =
          'Failed to load videos from ${source.name}: $e';
      if (_allCategoryResults[category] == null) {
        _allCategoryResults[category] = {};
      }
      _allCategoryResults[category]![source.searchUrl] = [];
      _hasMoreDataMap[sourceKey] = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreContent(String category, String sourceId) async {
    // if (_isLoadingMoreMap["${category}_$sourceId"] == true) return;

    final sourceKey = "${category}_$sourceId";
    log("sourceKey is $sourceKey");
    // if (!_hasMoreDataMap[sourceKey]!) return;

    // _isLoadingMoreMap[sourceKey] = true;
    // notifyListeners();

    try {
      final source = _sources.firstWhere((s) => s.searchUrl == sourceId);
      final nextPage = (_currentPageMap[sourceKey] ?? 1) + 1;
      final newVideos =
          await _scraperServices[source.url]!.search(_currentQuery, nextPage);

      if (newVideos.isNotEmpty) {
        final filteredVideos = newVideos.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();

        _allCategoryResults[category]![sourceId]!.addAll(filteredVideos);
        // _currentPageMap[sourceKey] = nextPage;
      } else {
        // _hasMoreDataMap[sourceKey] = false;
      }
    } catch (e) {
      _errorMap[sourceKey] = 'Failed to load more content: $e';
    } finally {
      // _isLoadingMoreMap[sourceKey] = false;
      notifyListeners();
    }
  }

  void toggleViewMode() {
    _isGrid = !_isGrid;
    notifyListeners();
  }

  void setCurrentCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  void setQuery(String query) {
    _currentQuery = query;
    notifyListeners();
  }
}
