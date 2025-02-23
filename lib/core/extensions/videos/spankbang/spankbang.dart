import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:watching_app_2/core/api/api_fetch_module.dart';

import '../../../../models/content_item.dart';
import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../models/video_source.dart';
import '../../../../services/scrapers/base_scraper.dart';
import 'package:html/parser.dart';

class Spankbang extends BaseScraper {
  Spankbang(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: '.thumb',
              attribute: 'title', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              selector: '.thumb > picture > img',
              attribute: 'data-src', // Extract thumbnail from 'data-src'
            ),
            contentUrlSelector: ElementSelector(
              selector: '.thumb',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            qualitySelector: ElementSelector(
              selector: '.thumb >  .h',
              // attribute: 'text', // Extract quality from text content
            ),
            timeSelector: ElementSelector(
              selector: '.thumb >  .l',
              // attribute: 'text', // Extract time from text content
            ),
            durationSelector: ElementSelector(
              selector: '.thumb >  .l',
              // attribute: 'text', // Extract duration from text content
            ),
            previewSelector: ElementSelector(
              selector: '.thumb > picture > img',
              attribute: 'data-preview', // Extract duration from text content
            ),
            watchingLinkSelector: ElementSelector(
              customExtraction: (element) {
                var scripts = element
                    .querySelectorAll('script[type="application/ld+json"]');
                var scriptContainingEmbedUrl = scripts.firstWhere(
                  (element) => element.text.contains('embedUrl'),
                );

                var jsonString1 = scriptContainingEmbedUrl.text;

                var jsonData = json.decode(jsonString1);

                Map watchingLink = {};
                Map params = {'auto': jsonData['contentUrl']};
                watchingLink.addEntries(params.entries);
                return Future.value(json.encode(watchingLink));
              },
            ),
            keywordsSelector: ElementSelector(
              selector: 'meta[name="keywords"]',
              attribute: 'content', // Extract duration from text content
            ),
          ),
        );

  @override
  Future<List<ContentItem>> scrapeContent(String html) async {
    final document = parse(html);
    final contentElements =
        document.querySelectorAll('.video-list > .video-item');
    return parseElements(contentElements);
  }

  @override
  Future<List<VideoSource>> scrapeVideos(String html) async {
    final document = parse(html);
    final contentElements = document.querySelectorAll('main');
    return await videoParseElement(document, contentElements.first);
  }

  @override
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

  @override
  Future<List<ContentItem>> getContentByType(String queryType, int page) async {
    final url = source.getQueryUrl(queryType, page);
    return await fetchCotentAndScrape(url);
  }

  @override
  Future<List<VideoSource>> getVideos(String url) async {
    return await fetchVideoAndScrape(url);
  }
}
