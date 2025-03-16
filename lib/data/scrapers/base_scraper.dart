import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/data/models/video_source.dart';
import '../../core/api/api_client.dart';
import '../../core/global/globals.dart';
import '../models/content_item.dart';
import '../models/content_source.dart';
import '../models/scraper_config.dart';
import '../../presentation/provider/similar_content_provider.dart';

/// Abstract base class for content scraping operations
abstract class BaseScraper {
  final ContentSource source;
  final ScraperConfig config;

  BaseScraper(this.source, this.config);

  // Content Scraping Methods
  Future<List<ContentItem>> scrapeContent(String html) =>
      _scrape(html, config.contentSelector, parseElements);

  Future<List<ContentItem>> scrapeDetailContent(String html) =>
      _scrape(html, config.detailSelector, parseElements);

  Future<List<ContentItem>> scrapeChapterContent(String html) =>
      _scrape(html, config.chapterDataSelector, parseElements);

  Future<List<VideoSource>> scrapeVideos(String html) async {
    log("this is videoSelector and ${config.videoSelector!.selector}");
    if (config.videoSelector == null) return [];
    final document = parse(html);
    final elements =
        document.querySelectorAll(config.videoSelector!.selector ?? '');
    return elements.isNotEmpty
        ? videoParseElement(document, elements.first)
        : [];
  }

  Future<List<ContentItem>> scrapeSimilarContent(String html) async {
    final provider = _getSimilarContentProvider();
    await provider.setSimilarContents([]);

    if (config.similarContentSelector?.selector?.isEmpty ?? true) {
      return [];
    }

    return _scrape(html, config.similarContentSelector, (elements) async {
      final items = await parseElements(elements);
      await provider.setSimilarContents(items);
      return items;
    });
  }

  // Fetch Methods
  Future<List<ContentItem>> search(String query, int page) =>
      _fetchAndScrape(source.getSearchUrl(query, page), scrapeContent);

  Future<List<ContentItem>> getContentByType(String queryType, int page) =>
      _fetchAndScrape(source.getQueryUrl(queryType, page), scrapeContent);

  Future<List<ContentItem>> getDetails(String url) =>
      _fetchAndScrape(url, scrapeDetailContent);

  Future<List<ContentItem>> getChapter(String url) =>
      _fetchAndScrape(url, scrapeChapterContent);

  Future<List<VideoSource>> getVideos(String url) =>
      _fetchAndScrape(url, (html) async {
        await scrapeSimilarContent(html);
        return scrapeVideos(html);
      });

  // Parsing Methods
  Future<List<ContentItem>> parseElements(List<Element> elements) async {
    final items = <ContentItem>[];
    for (final element in elements) {
      try {
        items.add(await _parseContentItem(element));
      } catch (e) {
        _logError('Error parsing element: $e');
      }
    }
    return items;
  }

  Future<List<VideoSource>> videoParseElement(
      Document document, Element element) async {
    try {
      return [await _parseVideoSource(document, element)];
    } catch (e) {
      _logError('Error parsing video element: $e');
      return [];
    }
  }

  // Utility Methods
  Future<String?> getAttributeValue(
    ElementSelector? selector, {
    Element? element,
    Document? document,
  }) async {
    if (selector == null) return null;

    try {
      if (selector.customExtraction == true) {
        return await extractCustomValue(selector,
            element: element, document: document);
      }

      final target = document?.querySelector(selector.selector ?? '') ??
          element?.querySelector(selector.selector ?? '');
      return selector.attribute != null
          ? target?.attributes[selector.attribute]!.trim()
          : target?.text.trim();
    } catch (e) {
      _logDebug('Error getting attribute from ${selector.selector}: $e');
      return null;
    }
  }

  Future<String?> extractCustomValue(
    ElementSelector selector, {
    Element? element,
    Document? document,
  }) async =>
      null; // To be overridden by specific scrapers

  // Private Helper Methods
  Future<T> _fetchAndScrape<T>(
      String url, Future<T> Function(String) scraper) async {
    try {
      final response = await ApiClient.request(url: url);
      return await scraper(response);
    } catch (e) {
      _logError('Error fetching data from $url: $e');
      return _defaultResult<T>();
    }
  }

  Future<List<T>> _scrape<T>(
    String html,
    ElementSelector? selector,
    Future<List<T>> Function(List<Element>) parser,
  ) async {
    final document = parse(html);
    final elements = document.querySelectorAll(selector?.selector ?? '');
    return elements.isEmpty ? [] : await parser(elements);
  }

  Future<ContentItem> _parseContentItem(Element element) async {
    return ContentItem(
      title: await getAttributeValue(config.titleSelector, element: element) ??
          'Unknown',
      thumbnailUrl:
          await getAttributeValue(config.thumbnailSelector, element: element) ??
              '',
      contentUrl: await getAttributeValue(config.contentUrlSelector,
              element: element) ??
          '',
      duration:
          await getAttributeValue(config.durationSelector, element: element) ??
              '0:00',
      preview:
          await getAttributeValue(config.previewSelector, element: element) ??
              '',
      quality:
          await getAttributeValue(config.qualitySelector, element: element) ??
              'HD',
      time: await getAttributeValue(config.timeSelector, element: element) ??
          'Unknown',
      views: await getAttributeValue(config.viewsSelector, element: element) ??
          'Unknown',
      scrapedAt: DateTime.now(),
      addedAt: DateTime.now(),
      source: source,
      genre:
          await getAttributeValue(config.genreSelector, element: element) ?? '',
      status:
          await getAttributeValue(config.statusSelector, element: element) ??
              '',
      chapterCount: await getAttributeValue(config.chapterCountSelector,
              element: element) ??
          '',
      chapterId:
          await getAttributeValue(config.chapterIdSelector, element: element) ??
              '',
      chapterImages: await getAttributeValue(config.chapterImageSelector,
              element: element) ??
          '',
      user:
          await getAttributeValue(config.userSelector, element: element) ?? '',
      likes:
          await getAttributeValue(config.likesSelector, element: element) ?? '',
      comments:
          await getAttributeValue(config.commentsSelector, element: element) ??
              '',
    );
  }

  Future<VideoSource> _parseVideoSource(
      Document document, Element element) async {
    return VideoSource(
      scrapedAt: DateTime.now(),
      source: source,
      watchingLink: await getAttributeValue(config.watchingLinkSelector,
              element: element) ??
          '',
      keywords: await getAttributeValue(config.keywordsSelector,
              document: document) ??
          '',
    );
  }

  SimilarContentProvider _getSimilarContentProvider() {
    return SMA.navigationKey.currentContext!.read<SimilarContentProvider>();
  }

  void _logError(String message) => SMA.logger.logError(message);
  void _logDebug(String message) {
    if (kDebugMode) print(message);
  }

  T _defaultResult<T>() {
    if (T == List<ContentItem>) {
      return <ContentItem>[] as T;
    }
    if (T == List<VideoSource>) {
      return <VideoSource>[] as T;
    }
    return switch (T) {
      const (String) => '' as T,
      const (int) => 0 as T,
      const (double) => 0.0 as T,
      const (bool) => false as T,
      _ => throw UnimplementedError('No default value for type $T'),
    };
  }
}
