import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:watching_app_2/data/models/category_model.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import '../api/api_client.dart';

class SourceManager {
  static const _baseUrl =
      'https://syed-moiz-ali.github.io/watching_app_2/assets';

  /// Loads content sources for a given category from remote JSON using isolate.
  Future<List<ContentSource>> loadSources(String category) async {
    final url = '$_baseUrl/extensions/$category.json';
    return _fetchDataWithIsolate<ContentSource>(
      url,
      ContentSource.fromJson,
      'sources',
    );
  }

  /// Loads all categories from remote JSON using isolate.
  Future<List<CategoryModel>> loadCategories() async {
    const url = '$_baseUrl/categories.json';
    return _fetchDataWithIsolate<CategoryModel>(
      url,
      CategoryModel.fromJson,
      'categories',
    );
  }

  /// Loads all stars from remote JSON using isolate.
  Future<List<CategoryModel>> loadStars() async {
    const url = '$_baseUrl/stars.json';
    return _fetchDataWithIsolate<CategoryModel>(
      url,
      CategoryModel.fromJson,
      'stars',
    );
  }

  /// Enhanced method to fetch and parse large JSON data using compute/isolate.
  Future<List<T>> _fetchDataWithIsolate<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
    String logLabel,
  ) async {
    try {
      // Step 1: Fetch raw JSON data from API
      final response = await ApiClient.request(url: url, type: 'GET');

      // Step 2: Parse JSON in isolate to avoid blocking UI thread
      final List<Map<String, dynamic>> jsonData =
          await _parseJsonInIsolate(response);

      // Step 3: Convert parsed JSON to model objects
      // This is also done in isolate for large datasets
      final List<T> objects =
          await _convertToModelsInIsolate<T>(jsonData, fromJson);

      if (kDebugMode) {
        print('Successfully loaded ${objects.length} $logLabel');
      }

      return objects;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading $logLabel: $e');
      }
      return [];
    }
  }

  /// Parse JSON string in isolate using compute function.
  Future<List<Map<String, dynamic>>> _parseJsonInIsolate(
      dynamic response) async {
    final String jsonString =
        response is String ? response : jsonEncode(response);

    // Use compute to parse JSON in background isolate
    return await compute(_parseJsonData, jsonString);
  }

  /// Convert parsed JSON data to model objects in isolate for large datasets.
  Future<List<T>> _convertToModelsInIsolate<T>(
    List<Map<String, dynamic>> jsonData,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // For very large datasets (>1000 items), use isolate
    if (jsonData.length > 1000) {
      final isolateData = _IsolateData<T>(jsonData, fromJson);
      return await compute(_convertJsonToModels<T>, isolateData);
    } else {
      // For smaller datasets, process on main thread to avoid isolate overhead
      return jsonData.map((json) => fromJson(json)).toList();
    }
  }
}

// Static functions for compute/isolate execution

/// Parse JSON data in isolate - must be top-level function for compute.
List<Map<String, dynamic>> _parseJsonData(String jsonString) {
  try {
    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    } else if (decoded is Map) {
      // Handle case where JSON might be wrapped in an object
      return [decoded.cast<String, dynamic>()];
    } else {
      throw Exception('Unexpected JSON format');
    }
  } catch (e) {
    if (kDebugMode) {
      print('JSON parsing error: $e');
    }
    return [];
  }
}

/// Convert JSON to model objects in isolate - must be top-level function.
List<T> _convertJsonToModels<T>(_IsolateData<T> data) {
  try {
    return data.jsonData.map((json) => data.fromJson(json)).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Model conversion error: $e');
    }
    return [];
  }
}

class _IsolateData<T> {
  final List<Map<String, dynamic>> jsonData;
  final T Function(Map<String, dynamic>) fromJson;

  _IsolateData(this.jsonData, this.fromJson);
}

extension SourceManagerExtensions on SourceManager {
  /// Preload and cache frequently used sources.
  Future<void> preloadSources(List<String> categories) async {
    final futures = categories.map((category) => loadSources(category));
    await Future.wait(futures);

    if (kDebugMode) {
      print('Preloaded ${categories.length} source categories');
    }
  }

  /// Get source statistics without loading full data.
  Future<Map<String, int>> getSourceCounts(List<String> categories) async {
    final Map<String, int> counts = {};

    for (final category in categories) {
      try {
        final sources = await loadSources(category);
        counts[category] = sources.length;
      } catch (e) {
        counts[category] = 0;
      }
    }

    return counts;
  }
}
