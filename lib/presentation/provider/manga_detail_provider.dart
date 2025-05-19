import 'dart:developer';

import 'package:flutter/material.dart';

import '../../core/global/globals.dart';
import '../../data/models/content_item.dart';
import '../../data/scrapers/scraper_service.dart';

class MangaDetailProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  ContentItem? mangaDetail;
  List<Chapter>? chapterDetail;

  Future<void> loadMangaDetails(ContentItem item) async {
    ScraperService scraperService = ScraperService(item.source);
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final details = await scraperService.getDetails(
          SMA.formatImage(image: item.contentUrl, baseUrl: item.source.url));
      log("thiis is details ${details.map((i) => i.toJson())}");
      mangaDetail = details.first;
      // await loadChapterDetails(item);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      log(e.toString());
      error = 'Failed to load manga details: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChapterDetails(ContentItem item) async {
    ScraperService scraperService = ScraperService(item.source);
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      // log('chapter id is ${item.}');
      final details = await scraperService.getChapter(SMA.formatImage(
          image: item.detailContent!.chapter![0].chapterId!,
          baseUrl: item.source.url));
      // log("thiis is chapterImages ${details.first.chapterImages}");
      chapterDetail = details.first.chapterImagesById;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Failed to load manga details: $e';
      isLoading = false;
      notifyListeners();
    }
  }
}
