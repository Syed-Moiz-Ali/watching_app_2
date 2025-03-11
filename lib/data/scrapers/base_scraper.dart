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

abstract class BaseScraper {
  final ContentSource source;
  final ScraperConfig config;

  BaseScraper(this.source, this.config);

  Future<List<ContentItem>> scrapeContent(String html) {
    final document = parse(html);
    final contentElements =
        document.querySelectorAll(config.contentSelector?.selector ?? '');
    return parseElements(contentElements);
  }

  Future<List<ContentItem>> scrapeDetailContent(String html) {
    final document = parse(html);
    final contentElements =
        document.querySelectorAll(config.detailSelector?.selector ?? '');
    return parseElements(contentElements);
  }

  Future<List<ContentItem>> scrapeChapterContent(String html) {
    final document = parse(html);
    final contentElements =
        document.querySelectorAll(config.chapterDataSelector?.selector ?? '');
    return parseElements(contentElements);
  }

  Future<List<ContentItem>> search(String query, int page) async {
    final url = source.getSearchUrl(query, page);
    try {
      final response = await ApiClient.request(url: url);
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

  Future<List<ContentItem>> getDetails(String url) async {
    return await fetchDetailAndScrape(url);
  }

  Future<List<ContentItem>> getChapter(String url) async {
    return await fetchChapterAndScrape(url);
  }

  Future<List<VideoSource>> scrapeVideos(String html) async {
    if (config.videoSelector != null) {
      final document = parse(html);
      final contentElements =
          document.querySelectorAll(config.videoSelector!.selector ?? '');
      return await videoParseElement(document, contentElements.first);
    }
    return [];
  }

  Future<List<VideoSource>> getVideos(String url) async {
    return await fetchVideoAndScrape(url);
  }

  Future<List<ContentItem>> fetchCotentAndScrape(String url) async {
    try {
      final response = await ApiClient.request(url: url);
      return scrapeContent(response);
    } catch (e) {
      SMA.logger.logError('Error fetching data from $url: $e');
      return [];
    }
  }

  Future<List<ContentItem>> fetchDetailAndScrape(String url) async {
    try {
      final response = await ApiClient.request(url: url);
      return scrapeDetailContent(response);
    } catch (e) {
      SMA.logger.logError('Error fetching data from $url: $e');
      return [];
    }
  }

  Future<List<ContentItem>> fetchChapterAndScrape(String url) async {
    try {
      final response = await ApiClient.request(url: url);
      return scrapeChapterContent(response);
    } catch (e) {
      SMA.logger.logError('Error fetching data from $url: $e');
      return [];
    }
  }

  Future<List<VideoSource>> fetchVideoAndScrape(String url) async {
    try {
      final response = await ApiClient.request(url: url);
      await scrapeSimilarContent(response);
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
    final similarContentElements = document
        .querySelectorAll(config.similarContentSelector?.selector ?? '');

    var similarContent = await parseElements(similarContentElements);
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
      final item = await parseSingleVideoElement(document, element);
      items.add(item);
    } catch (e) {
      SMA.logger.logError('Error parsing video element: $e');
    }
    return items;
  }

  Future<String?> getAttributeValue(ElementSelector? selector,
      {Element? element, Document? document}) async {
    try {
      if (selector == null) return null;
      log("selector value is ${selector.customExtraction}");
      if (selector.customExtraction != null &&
          selector.customExtraction == true) {
        return await extractCustomValue(selector,
            element: element, document: document);
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

  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    return null; // Overridden by specific scrapers
  }

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
      addedAt: DateTime.now(),
      source: source,
      genre:
          await getAttributeValue(element: element, config.genreSelector) ?? '',
      status:
          await getAttributeValue(element: element, config.statusSelector) ??
              '',
      chapterCount: await getAttributeValue(
              element: element, config.chapterCountSelector) ??
          '',
      chapterId:
          await getAttributeValue(element: element, config.chapterIdSelector) ??
              '',
      chapterImages: await getAttributeValue(
              element: element, config.chapterImageSelector) ??
          '',
      user:
          await getAttributeValue(element: element, config.userSelector) ?? '',
      likes:
          await getAttributeValue(element: element, config.likesSelector) ?? '',
      comments:
          await getAttributeValue(element: element, config.commentsSelector) ??
              '',
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
