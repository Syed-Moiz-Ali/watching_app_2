import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:watching_app_2/data/models/category_model.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import '../api/api_client.dart';

class SourceManager {
  static const _baseUrl =
      'https://syed-moiz-ali.github.io/watching_app_2/assets';

  /// Loads content sources for a given category from remote JSON.
  Future<List<ContentSource>> loadSources(String category) async {
    final url = '$_baseUrl/extensions/$category.json';
    return _fetchData<ContentSource>(url, ContentSource.fromJson, 'sources');
  }

  /// Loads all categories from remote JSON.
  Future<List<CategoryModel>> loadCategories() async {
    const url = '$_baseUrl/categories.json';
    return _fetchData<CategoryModel>(url, CategoryModel.fromJson, 'categories');
  }

  /// Loads all stars (actors, actresses, etc.) from remote JSON.
  Future<List<CategoryModel>> loadStars() async {
    const url = '$_baseUrl/stars.json';
    return _fetchData<CategoryModel>(url, CategoryModel.fromJson, 'stars');
  }

  /// Generic method to fetch and parse list data from an API.
  Future<List<T>> _fetchData<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
    String logLabel,
  ) async {
    try {
      final res = await ApiClient.request(url: url, type: 'GET');
      var jsonData = res is String ? json.decode(res) : res;
      return jsonData.map<T>((json) => fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading $logLabel: $e');
      }
      return [];
    }
  }
}
