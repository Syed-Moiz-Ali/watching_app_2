import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:watching_app_2/core/api/api_fetch_module.dart';

import '../../../../models/content_item.dart';
import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../models/video_source.dart';
import '../../../../services/scrapers/base_scraper.dart';
import 'package:html/parser.dart';

class GoodPorn extends BaseScraper {
  GoodPorn(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'a',
              attribute: 'title', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              selector: 'a > .img > img',
              attribute: 'data-original', // Extract thumbnail from 'data-src'
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
              selector: 'a > .wrap >.duration',
              // attribute: 'text', // Extract time from text content
            ),
            durationSelector: ElementSelector(
              selector: 'a > .wrap >.duration',
              // attribute: 'text', // Extract duration from text content
            ),
            previewSelector: ElementSelector(
              selector: 'a > .img > img',
              attribute: 'data-preview', // Extract duration from text content
            ),
            watchingLinkSelector: ElementSelector(
              customExtraction: (element) {
                Map watchingLinks = {};
                var links = element
                    .querySelector('.video-holder > .player > .player-holder');

                List<Element> scriptTags = links!.querySelectorAll('script');

                // Find the script tag containing '<![CDATA[' in its content
                Element? cdataScriptTag = scriptTags.firstWhere(
                  (scriptTag) => scriptTag.text.contains('<![CDATA['),
                  // orElse: () => null,
                );

                String jsContent = cdataScriptTag.text;

                // Define regular expressions to extract key-value pairs from the JavaScript content
                RegExp videoUrlRegex = RegExp(r"video_id: '([^']+)'");

                // Find the first match for video_url
                RegExpMatch? match = videoUrlRegex.firstMatch(jsContent);

                // Return the video_url if found, otherwise return null
                var newMatch = match?.group(1)!.replaceAll('function/0/', '');

                Map params = {
                  'auto': 'https://www.tabooporn.tv/embed/$newMatch'
                };
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
        document.querySelectorAll('.box > .list-videos > .margin-fix > .item');
    return parseElements(contentElements);
  }

  @override
  Future<List<VideoSource>> scrapeVideos(String html) async {
    final document = parse(html);
    final contentElements = document.querySelectorAll('.block-video');
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
