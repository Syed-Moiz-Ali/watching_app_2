import 'package:flutter/material.dart';

import '../../data/models/content_item.dart';

class SimilarContentProvider extends ChangeNotifier {
  List<ContentItem> similarContents = [];
  setSimilarContents(List<ContentItem> contents) {
    similarContents = contents;
    notifyListeners();
  }
}
