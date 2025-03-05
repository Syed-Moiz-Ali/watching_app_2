import 'dart:convert';

import '../../../../data/models/content_source.dart';
import '../../../../data/models/scraper_config.dart';
import '../../../../data/scrapers/base_scraper.dart';

class YouJizz extends BaseScraper {
  YouJizz(ContentSource source)
      : super(
          source,
          ScraperConfig(
              titleSelector: ElementSelector(
                selector: '.video-item > .frame-wrapper > a ',
              ),
              thumbnailSelector: ElementSelector(
                  selector: '.video-item > .frame-wrapper > a >  img',
                  attribute: 'data-orignal'),
              contentUrlSelector: ElementSelector(
                selector: '.video-item > .frame-wrapper > a ',
                attribute: 'href', // Extract content URL from 'href' attribute
              ),
              durationSelector: ElementSelector(
                selector: '.video-item  > .video-content-wrapper  > .time',
                // attribute: 'text', // Extract duration from text content
              ),
              previewSelector: ElementSelector(
                selector: '.video-item > .frame-wrapper > a',
                attribute: 'data-clip', // Extract duration from text content
              ),
              watchingLinkSelector: ElementSelector(
                customExtraction: (element) {
                  Map watchingLinks = {};
                  var links = element
                      .querySelector('video > source')
                      ?.attributes['src'];
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
              contentSelector:
                  ElementSelector(selector: '.clearfix > .video-thumb'),
              videoSelector: ElementSelector(selector: '..video-wrapper'),
              similarContentSelector: ElementSelector(
                  selector:
                      '.g1-more-from > .g1-collection > .g1-collection-viewport > .g1-collection-item')),
        );
}
