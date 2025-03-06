import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/data/models/category_model.dart';
import 'package:watching_app_2/data/models/content_source.dart';

class SourceManager {
  // Load sources from JSON file in assets
  Future<List<ContentSource>> loadSources(String category) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/extensions/$category.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ContentSource.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sources: $e');
      }
      return [];
    }
  }

  Future<List<CategoryModel>> loadCategories() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/categories.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sources: $e');
      }
      return [];
    }
  }
}
