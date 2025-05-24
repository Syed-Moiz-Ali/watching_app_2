import 'package:watching_app_2/data/models/video_source.dart';

import '../models/content_item.dart';
import '../models/content_source.dart';
import '../../core/services/scraper_factory.dart';

import 'base_scraper.dart';

class ScraperService {
  final ContentSource source;
  late final BaseScraper scraper;

  ScraperService(this.source) {
    scraper = ScraperFactory.createScraper(source);
  }

  Future<List<ContentItem>> getContent(String queryType, int page) {
    return scraper.getContentByType(queryType, page);
  }

  Future<List<ContentItem>> getTikTokContent(String url, int page) {
    return scraper.getTikTokContent(url, page);
  }

  Future<List<ContentItem>> getDetails(String url) {
    return scraper.getDetails(url);
  }

  Future<List<Chapter>> getChapter(String url) {
    return scraper.getChapter(url);
  }

  Future<List<VideoSource>> getVideo(String url) {
    return scraper.getVideos(url);
  }

  Future<List<ContentItem>> search(String query, int page) {
    return scraper.search(query, page);
  }
}
