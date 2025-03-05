import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/data/models/video_source.dart';

import '../../core/api/api_fetch_module.dart';
import '../../core/global/app_global.dart';
import '../models/content_item.dart';
import '../models/content_source.dart';
import '../models/scraper_config.dart';
import '../../presentation/provider/similar_content_provider.dart';

abstract class BaseScraper {
  final ContentSource source;
  final ScraperConfig config;

  BaseScraper(this.source, this.config);

  // Required methods that must be implemented
  Future<List<ContentItem>> scrapeContent(String html) {
    final document = parse(html);
    final contentElements =
        document.querySelectorAll(config.contentSelector!.selector!);
    return parseElements(contentElements);
  }

  Future<List<ContentItem>> search(String query, int page) async {
    final url = source.getSearchUrl(query, page);
    try {
      final response = await ApiFetchModule.request(url: url);
      return scrapeContent(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error searching: $e');
      }
      return [];
    }
  }

  Future<List<ContentItem>> getContentByType(String queryType, int page) async {
    final url = source.getQueryUrl(queryType, page);
    return await fetchCotentAndScrape(url);
  }

  // Optional methods with default implementations
  Future<List<VideoSource>> scrapeVideos(String html) async {
    if (config.videoSelector != null) {
      final document = parse(html);
      final contentElements =
          document.querySelectorAll(config.videoSelector!.selector!);
      return await videoParseElement(document, contentElements.first);
    } else {
      return [];
    }
  }

  Future<List<VideoSource>> getVideos(String url) async {
    return await fetchVideoAndScrape(url);
  }

  Future<List<ContentItem>> fetchCotentAndScrape(String url) async {
    try {
      final response = await ApiFetchModule.request(url: url);
      return scrapeContent(response);
    } catch (e) {
      SMA.logger.logError('Error fetching data from $url: $e');
      return [];
    }
  }

  Future<List<VideoSource>> fetchVideoAndScrape(String url) async {
    try {
      final response = await ApiFetchModule.request(url: url);
      scrapeSimilarContent(response); // We call it here in base class.
      return scrapeVideos(response);
    } catch (e) {
      SMA.logger.logError('Error fetching data from $url: $e');
      return [];
    }
  }

  Future<List<ContentItem>> scrapeSimilarContent(String html) async {
    var similarContentProvider =
        SMA.navigationKey.currentContext!.read<SimilarContentProvider>();
    await similarContentProvider.setSimilarContents([]);

    final document = parse(html);
    final similarContentElements =
        document.querySelectorAll(config.similarContentSelector!.selector!);

    // Assuming we handle similar content scraping here
    var similarContent = await parseElements(similarContentElements);

    // Optionally, you could also update your `SimilarContentProvider` here,
    // which could be done in one place across all scrapers
    await similarContentProvider.setSimilarContents(similarContent);

    return similarContent;
  }

  Future<List<ContentItem>> parseElements(List<Element> elements) async {
    final List<ContentItem> items = [];
    for (var element in elements) {
      try {
        final item = await parseElement(element);
        items.add(item);
      } catch (e) {
        SMA.logger.logError('Error parsing element: $e');
      }
    }
    return items;
  }

  Future<List<VideoSource>> videoParseElement(
      Document document, Element element) async {
    final List<VideoSource> items = [];

    try {
      final item = await parseSingleVideoElement(
          document, element); // Reuses parseElement from BaseScraper
      items.add(item);
    } catch (e) {
      SMA.logger.logError('Error parsing element: $e');
    }

    return items;
  }

  // Helper methods for all scrapers
  Future<String?> getAttributeValue(ElementSelector? selector,
      {Element? element, Document? document}) async {
    try {
      if (selector == null) return null;
      if (selector.customExtraction != null) {
        return await selector.customExtraction!(element!);
      }
      final elementTag = document != null
          ? document.querySelector(selector.selector ?? '')
          : element!.querySelector(selector.selector ?? '');
      return selector.attribute != null
          ? elementTag?.attributes[selector.attribute]
          : elementTag?.text;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting attribute from ${selector!.selector}: $e');
      }
      return null;
    }
  }

  String? getText(var element, ElementSelector selector) {
    try {
      final elementTag = element.querySelector(selector.selector!);
      return elementTag?.text.trim();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting text from $selector: $e');
      }
      return null;
    }
  }

  // Scraping the content using selectors defined in config
  Future<ContentItem> parseElement(Element element) async {
    return ContentItem(
      title: await getAttributeValue(element: element, config.titleSelector) ??
          'Unknown',
      thumbnailUrl:
          await getAttributeValue(element: element, config.thumbnailSelector) ??
              '',
      contentUrl: await getAttributeValue(
              element: element, config.contentUrlSelector) ??
          '',
      duration:
          await getAttributeValue(element: element, config.durationSelector) ??
              '0:00',
      preview:
          await getAttributeValue(element: element, config.previewSelector) ??
              '',
      quality:
          await getAttributeValue(element: element, config.qualitySelector) ??
              'HD',
      time: await getAttributeValue(element: element, config.timeSelector) ??
          'Unknown',
      views: await getAttributeValue(element: element, config.viewsSelector) ??
          'Unknown',
      scrapedAt: DateTime.now(),
      source: source,
    );
  }

  Future<VideoSource> parseSingleVideoElement(
      Document document, Element element) async {
    return VideoSource(
      scrapedAt: DateTime.now(),
      source: source,
      watchingLink: await getAttributeValue(
              element: element, config.watchingLinkSelector) ??
          '',
      keywords: await getAttributeValue(
              document: document, config.keywordsSelector) ??
          '',
    );
  }
}
