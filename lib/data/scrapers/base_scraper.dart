import 'dart:convert';
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

  BaseScraper(this.source);

  // Content Scraping Methods
  Future<List<ContentItem>> scrapeContent(String data) =>
      _scrapeHtml(data, source.config!.contentSelector, parseElements);
  Future<List<ContentItem>> scrapeTikTokContent(String data) =>
      source.decodeType == '2'
          ? _scrapeJson(data, source.config!.contentSelector, parseJsonElements)
          : _scrapeHtml(data, source.config!.contentSelector, parseElements);

  Future<List<ContentItem>> scrapeDetailContent(String data) =>
      _scrapeHtml(data, source.config!.detailSelector, parseElements);

  Future<List<ContentItem>> scrapeChapterContent(String data) => _scrapeHtml(
      data, source.config!.chapterImagesByIdSelectionSelector, parseElements);

  Future<List<VideoSource>> scrapeVideos(String data) async {
    log("this is videoSelector and ${source.config!.videoSelector!.selector}");
    if (source.config!.videoSelector == null) return [];
    final document = parse(data);
    final elements =
        document.querySelectorAll(source.config!.videoSelector!.selector ?? '');
    return elements.isNotEmpty
        ? videoParseElement(document, elements.first)
        : [];
  }

  Future<List<ContentItem>> scrapeSimilarContent(String data) async {
    final provider = _getSimilarContentProvider();
    await provider.setSimilarContents([]);

    if (source.config!.similarContentSelector?.selector?.isEmpty ?? true) {
      return [];
    }

    return _scrapeHtml(data, source.config!.similarContentSelector,
        (elements) async {
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

  Future<List<ContentItem>> getTikTokContent(String url, int page) =>
      _fetchAndScrape(source.getQueryUrl(url, page), scrapeTikTokContent);
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
    // log("elements map is ${elements.map((e) => e.outerHtml)}");
    for (final element in elements) {
      try {
        items.add(await _parseContentItem(element));
      } catch (e) {
        _logError('Error parsing element: $e');
      }
    }
    return items;
  }

  Future<List<ContentItem>> parseJsonElements(List elements) async {
    final items = <ContentItem>[];
    log("elements is $elements");
    try {
      for (var element in elements) {
        items.add(await _parseTiTokContentItem(element));
      }
    } catch (e) {
      _logError('Error parsing json element: $e');
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
    if (selector!.selector == null) return "";
    try {
      if (selector.customExtraction == true) {
        return await extractCustomValue(selector,
            element: element, document: document);
      }

      if (selector.selector == "this") {
        return selector.attribute != null
            ? element?.attributes[selector.attribute]?.trim()
            : element?.text.trim();
      } else {
        final target = document?.querySelector(selector.selector ?? '') ??
            element?.querySelector(selector.selector ?? '');
        return selector.attribute != null
            ? target?.attributes[selector.attribute]?.trim()
            : target?.text.trim();
      }
    } catch (e) {
      _logDebug('Error getting single attribute from ${selector.selector}: $e');
      return null;
    }
  }

  Future<List<Element>?> getMultipleAttributeValue(
    ElementSelector? selector, {
    Element? element,
    Document? document,
  }) async {
    if (selector == null) return null;

    try {
      // if (selector.customExtraction == true) {
      //   return await extractCustomValue(selector,
      //       element: element, document: document);
      // }

      final targets = document?.querySelectorAll(selector.selector ?? '') ??
          element?.querySelectorAll(selector.selector ?? '');
      if (targets!.isEmpty) return null;
      return targets;
      // final values = targets.map((target) => selector.attribute != null
      //     ? target.attributes[selector.attribute]?.trim()
      //     : target.text.trim()).whereType<String>();

      // return values;
    } catch (e) {
      _logDebug(
          'Error getting multiple attribute from ${selector.selector}: $e');
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

  Future<List<T>> _scrapeHtml<T>(
    String html,
    ElementSelector? selector,
    Future<List<T>> Function(List<Element>) parser,
  ) async {
    final document = parse(html);
    // log("selector of main is ${selector!.toJson()}");
    // log("elements is ${document.querySelectorAll(selector.selector ?? '')}");
    final elements = document.querySelectorAll(selector!.selector ?? '');
    return elements.isEmpty ? [] : await parser(elements);
  }

  Future<List<T>> _scrapeJson<T>(
    String jsonString,
    ElementSelector? selector,
    Future<List<T>> Function(List) parser,
  ) async {
    try {
      Map jsonData = jsonDecode(jsonString);
      // log("jsonData is $jsonData");
      final elements = _extractJsonElements(jsonData, selector?.selector ?? '');
      return elements.isEmpty ? [] : await parser(elements);
    } catch (e) {
      _logError('Error parsing JSON: $e');
      return [];
    }
  }

  List _extractJsonElements(Map jsonData, String selector) {
    try {
      log(selector.contains('.').toString());
      if (!selector.contains('.')) {
        return jsonData[selector] ?? [];
      }

      final keys = selector.split('.');
      dynamic value = jsonData;
      for (final key in keys) {
        value = value[key];
      }
      return (value is List) ? value : [value];
    } catch (e) {
      _logDebug('Error extracting JSON elements for $selector: $e');
      return [];
    }
  }

  Future<ContentItem> _parseContentItem(Element element) async {
    // log("config is ${source.config!.toJson()}");
    return ContentItem(
      title: await getAttributeValue(source.config!.titleSelector,
              element: element) ??
          'Unknown',
      thumbnailUrl: await getAttributeValue(source.config!.thumbnailSelector,
              element: element) ??
          '',
      contentUrl: await getAttributeValue(source.config!.contentUrlSelector,
              element: element) ??
          '',
      duration: await getAttributeValue(source.config!.durationSelector,
              element: element) ??
          '0:00',
      preview: await getAttributeValue(source.config!.previewSelector,
              element: element) ??
          '',
      quality: await getAttributeValue(source.config!.qualitySelector,
              element: element) ??
          'HD',
      time: await getAttributeValue(source.config!.timeSelector,
              element: element) ??
          'Unknown',
      views: await getAttributeValue(source.config!.viewsSelector,
              element: element) ??
          'Unknown',
      scrapedAt: DateTime.now(),
      addedAt: DateTime.now(),
      source: source,
      detailContent: DetailModel(
        discription: await getAttributeValue(source.config!.descriptionSelector,
                element: element) ??
            '',
        genre: await getAttributeValue(source.config!.genreSelector,
                element: element) ??
            '',
        chapterSelector: await getAttributeValue(
                source.config!.chaptersSelector,
                element: element) ??
            '',
        status: await getAttributeValue(source.config!.statusSelector,
                element: element) ??
            '',
        chapter: await Future.wait((await getMultipleAttributeValue(
                    source.config!.chaptersSelector,
                    element: element) ??
                [])
            .map((c) async {
          // log("chapter for this is ${c} annd ${source.config!.chapterIdSelector!.toJson()} ${source.config!.chapterNameSelector!.toJson()}");
          return Chapter(
            chapterId: await getAttributeValue(source.config!.chapterIdSelector,
                    element: c) ??
                '',
            chapterName: await getAttributeValue(
                    source.config!.chapterNameSelector,
                    element: c) ??
                '',
            chapterImage: await getAttributeValue(
                    source.config!.chapterImageSelector,
                    element: c) ??
                '',
          );
        })),
        // chapter:
      ),
      chapterImagesById: await Future.wait((await getMultipleAttributeValue(
                  source.config!.chapterImagesByIdSelectionSelector,
                  element: element) ??
              [])
          .map((c) async {
        log("chapter for this is ${c} annd ${source.config!.chapterIdSelector!.toJson()} ${source.config!.chapterNameSelector!.toJson()}");
        return Chapter(
          chapterId: await getAttributeValue(
                  source.config!.chapterImagesByIdSelector,
                  element: c) ??
              '',
          chapterName: await getAttributeValue(
                  source.config!.chapterTitleByIdSelector,
                  element: c) ??
              '',
          chapterImage: await getAttributeValue(
                  source.config!.chapterImagesByIdSelector,
                  element: c) ??
              '',
        );
      })),
    );
  }

  Future<ContentItem> _parseTiTokContentItem(Map element) async {
    return ContentItem(
      title: await _extractNestedValue(
              element, source.config!.titleSelector.selector!.split('.')) ??
          'Unknown',
      thumbnailUrl: await _extractNestedValue(
              element, source.config!.thumbnailSelector.selector!.split('.')) ??
          'Unknown',
      contentUrl: await _extractNestedValue(element,
              source.config!.contentUrlSelector.selector!.split('.')) ??
          'Unknown',
      videoUrl: await _extractNestedValue(
              element, source.config!.videoSelector!.selector!.split('.')) ??
          'Unknown',
      scrapedAt: DateTime.now(),
      addedAt: DateTime.now(),
      source: source,
    );
  }

  dynamic _extractNestedValue(Map data, List<String> paths) {
    dynamic value = data;
    for (final path in paths) {
      if (value is Map) {
        value = value[path];
      } else if (value is List) {
        // Try to parse path as integer for list index
        try {
          final index = int.parse(path);
          value = value[index];
        } catch (e) {
          return null;
        }
      } else {
        return value?.toString();
      }
    }
    return value?.toString();
  }

  Future<VideoSource> _parseVideoSource(
      Document document, Element element) async {
    return VideoSource(
      scrapedAt: DateTime.now(),
      source: source,
      watchingLink: await getAttributeValue(source.config!.watchingLinkSelector,
              element: element) ??
          '',
      keywords: await getAttributeValue(source.config!.keywordsSelector,
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
