import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:watching_app_2/core/api/api_fetch_module.dart';

import '../../../../models/content_item.dart';
import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../models/video_source.dart';
import '../../../../services/scrapers/base_scraper.dart';
import 'package:html/parser.dart';

class CrazyShit extends BaseScraper {
  CrazyShit(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'a',
              attribute: 'title', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              selector: 'a >  .image-container > img',
              attribute: 'src', // Extract thumbnail from 'data-src'
            ),
            contentUrlSelector: ElementSelector(
              selector: 'a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            qualitySelector: ElementSelector(
              selector: '.is-hd',
              // attribute: 'text', // Extract quality from text content
            ),
            timeSelector: ElementSelector(
              selector: '.meta > .stats >.views',
              // attribute: 'text', // Extract time from text content
            ),
            durationSelector: ElementSelector(
              selector: 'a > .i_img >  .m_time',
              // attribute: 'text', // Extract duration from text content
            ),
            previewSelector: ElementSelector(
              selector: 'a > .i_img',
              attribute:
                  'data-trailer_url', // Extract duration from text content
            ),
            watchingLinkSelector: ElementSelector(
              customExtraction: (element) {
                Map watchingLinks = {};
                var links =
                    element.querySelector('video > source')?.attributes['src'];

                Map params = {'auto': links};
                watchingLinks.addEntries(params.entries);

                // Return the encoded JSON string of watching links
                return Future.value(json.encode(watchingLinks));
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
        document.querySelectorAll('.column > .container_box> .tiles > .tile');
    return parseElements(contentElements);
  }

  @override
  Future<List<VideoSource>> scrapeVideos(String html) async {
    final document = parse(html);
    final contentElements = document.querySelectorAll('.mediabox');
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
