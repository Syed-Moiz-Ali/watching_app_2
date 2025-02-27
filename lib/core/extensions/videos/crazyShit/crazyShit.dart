// ignore_for_file: file_names

import 'dart:convert';

import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../services/scrapers/base_scraper.dart';

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
            contentSelector: ElementSelector(
                selector: '.column > .container_box> .tiles > .tile'),
            videoSelector: ElementSelector(selector: '.mediabox'),
          ),
        );
}
