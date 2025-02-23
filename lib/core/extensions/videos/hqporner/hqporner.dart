import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:watching_app_2/core/api/api_fetch_module.dart';

import '../../../../models/content_item.dart';
import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../models/video_source.dart';
import '../../../../services/scrapers/base_scraper.dart';
import 'package:html/parser.dart';

class HQPorner extends BaseScraper {
  HQPorner(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'section > #span-case > .meta-data-title',
            ),
            thumbnailSelector: ElementSelector(
              selector: 'img',
              attribute: 'src', // Extract thumbnail from 'data-src'
            ),
            contentUrlSelector: ElementSelector(
              selector: 'section > a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            qualitySelector: ElementSelector(
              selector:
                  '.inner-wrapper > .video-thumb > a > .video-time > .quality',
              // attribute: 'text', // Extract quality from text content
            ),
            timeSelector: ElementSelector(
              selector: 'a > .i_img >  .m_time',
              // attribute: 'text', // Extract time from text content
            ),
            durationSelector: ElementSelector(
              selector: 'section > #span-case > span',
              // attribute: 'text', // Extract duration from text content
            ),
            previewSelector: ElementSelector(
              selector: '',
              attribute:
                  'data-trailer_url', // Extract duration from text content
            ),
            watchingLinkSelector: ElementSelector(
              customExtraction: (element) {
                Map watchingLinks = {};
                var links = element.querySelector('script')?.text;
                RegExp regExp = RegExp(r"url: '.*\?i=(//.*?/video/.*?)'");

                // Find the first match in the script content
                RegExpMatch? match = regExp.firstMatch(links!);
                String? link = '';
                if (match != null) {
                  link = 'https:${match.group(1)}';
                } else {}
                Map params = {'auto': link};
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
    final contentElements = document.querySelectorAll(
        '.page-content > section > div > .row > [class="6u"]');
    return parseElements(contentElements);
  }

  @override
  Future<List<VideoSource>> scrapeVideos(String html) async {
    final document = parse(html);
    final contentElements =
        document.querySelectorAll('.page-content > section > div[class="12u"]');
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
