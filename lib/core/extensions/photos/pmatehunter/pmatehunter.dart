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

class PMateHunter extends BaseScraper {
  PMateHunter(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'figure > a >  img',
              attribute: 'alt', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              customExtraction: (Element element) {
                var srcset = element
                    .querySelector('figure > a > img')
                    ?.attributes['srcset'];
                // log('srcset is ${srcset!.trim()}');
                var imageUrl = '';
                // if (srcset != null) {
                // Split the srcset attribute by comma to get individual sources
                var sources = srcset!.trim().split(', ');
                if (sources.isNotEmpty) {
                  // Get the first source
                  var firstSource = sources.first;
                  // Split the first source by space to get the URL and size
                  var parts = firstSource.split(' ');
                  // log('parts is $parts');
                  if (parts.length >= 2) {
                    // The URL is the first part
                    imageUrl = parts[0];
                  }
                } else {
                  imageUrl = element
                          .querySelector('figure > a > img')
                          ?.attributes['src'] ??
                      '';
                }
                // }
                // log('image is $imageUrl');
                return Future.value(imageUrl.trim());
              },
            ),
            contentUrlSelector: ElementSelector(
              selector: 'figure > a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            qualitySelector: ElementSelector(
              selector: '.thumb >  .h',
            ),
            timeSelector: ElementSelector(
              selector: '.thumb >  .l',
            ),
            durationSelector: ElementSelector(
              selector: '.thumb >  .l',
            ),
            previewSelector: ElementSelector(
              selector: '.thumb > picture > img',
              attribute: 'data-preview',
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
              attribute: 'content',
            ),
            similarContentSelector: ElementSelector(
              selector: '.user_uploads > .video-list > .video-item',
            ),
          ),
        );

  @override
  Future<List<ContentItem>> scrapeContent(String html) async {
    final document = parse(html);
    final contentElements =
        document.querySelectorAll('#content > .list-gallery > li');
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
