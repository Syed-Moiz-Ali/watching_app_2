// ignore_for_file: file_names

import 'dart:convert';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

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
              viewsSelector: ElementSelector(
                selector: '.meta > .stats >.views',
                // attribute: 'text', // Extract time from text content
              ),
              watchingLinkSelector: ElementSelector(
                customExtraction: (element) {
                  Map watchingLinks = {};
                  var selector = element.querySelector('.media > .mediabox');
                  var links = selector!
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
              contentSelector: ElementSelector(
                  selector: '.column > .container_box> .tiles > .tile'),
              videoSelector:
                  ElementSelector(selector: '.view-page > .two-column'),
              similarContentSelector: ElementSelector(
                  selector: '.sidebar > .side_box > .lists > .tile')),
        );
}
