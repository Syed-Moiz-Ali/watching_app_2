import 'package:flutter/material.dart';

import '../models/content_item.dart';

class SimilarContentProvider extends ChangeNotifier {
  List<ContentItem> similarContents = [];
  setSimilarContents(List<ContentItem> contents) {
    similarContents = contents;
    notifyListeners();
  }
}
