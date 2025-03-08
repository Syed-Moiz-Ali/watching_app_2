import 'dart:convert';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class NoodleMagazine extends BaseScraper {
  NoodleMagazine(ContentSource source)
      : super(
            source,
            ScraperConfig(
              titleSelector: ElementSelector(
                selector: 'a > .i_img >  img',
                attribute: 'alt', // Extract title from 'title' attribute
              ),
              thumbnailSelector: ElementSelector(
                selector: 'a > .i_img >  img',
                attribute: 'data-src', // Extract thumbnail from 'data-src'
              ),
              contentUrlSelector: ElementSelector(
                selector: 'a',
                attribute: 'href', // Extract content URL from 'href' attribute
              ),
              qualitySelector: ElementSelector(
                selector: 'a > .i_img >.hd_mark',
                // attribute: 'text', // Extract quality from text content
              ),
              timeSelector: ElementSelector(
                selector: 'a > .i_img >  .m_time',
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
                  Map<String, dynamic> watchingLinks = {};

                  final scriptTags = element.getElementsByTagName('script');

                  for (var script in scriptTags) {
                    final scriptContent = script.outerHtml;

                    if (scriptContent.contains('window.playlist')) {
                      // Extract JSON-like data from the script
                      final jsonPattern = RegExp(
                          r'window\.playlist\s*=\s*(\{.*?\});',
                          dotAll: true);
                      final jsonMatch = jsonPattern.firstMatch(scriptContent);

                      if (jsonMatch != null) {
                        final jsonString = jsonMatch.group(1)!;

                        try {
                          // Try to parse the JSON string to validate its structure
                          final jsonData = json.decode(jsonString);
                          // If valid, return the JSON string or process it as needed
                          var sources = jsonData['sources'];

                          final sourceList = List.from(sources);

                          for (var source in sourceList) {
                            final label = source['label'].toString();
                            final file = source['file'].toString();

                            watchingLinks['${label}p'] = file;
                          }
                        } catch (e) {
                          // Handle JSON parsing error
                        }
                      }
                    }
                  }

                  // Return the encoded JSON string of watching links
                  return Future.value(json.encode(watchingLinks));
                },
              ),
              keywordsSelector: ElementSelector(
                selector: 'meta[name="keywords"]',
                attribute: 'content', // Extract duration from text content
              ),
              similarContentSelector: ElementSelector(
                selector: '.box > #list_videos > .item',
              ),
              contentSelector:
                  ElementSelector(selector: '#list_videos > .item'),
              videoSelector: ElementSelector(selector: 'body'),
            ));
}
