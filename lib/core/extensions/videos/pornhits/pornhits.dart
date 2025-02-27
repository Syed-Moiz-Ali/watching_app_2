import 'dart:convert';
import 'dart:developer';

import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../services/scrapers/base_scraper.dart';

class PornHits extends BaseScraper {
  PornHits(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'a > .img > img',
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
              selector: '',
              // attribute: 'text', // Extract quality from text content
            ),
            timeSelector: ElementSelector(
              selector: 'a > .img > .duration',
              // attribute: 'text', // Extract time from text content
            ),
            durationSelector: ElementSelector(
              selector: 'a > .img > .duration',
              // attribute: 'text', // Extract duration from text content
            ),
            previewSelector: ElementSelector(
              selector: 'a > .img > img',
              attribute:
                  'data-trailer_url', // Extract duration from text content
            ),
            watchingLinkSelector: ElementSelector(
              customExtraction: (element) {
                Map watchingLinks = {};
                log("this is videoLInk and ${element.querySelector('.player-wrap')!.innerHtml.toString()}");
                var links =
                    element.querySelectorAll('.info > .item:last-child > a');

                for (var element in links) {
                  var parts = element.text.replaceAll('MP4', '').split(',');
                  if (parts.length > 1) {
                    parts.removeLast();
                  }
                  var key = parts.isNotEmpty ? parts.join(',') : '';

                  Map params = {
                    key.toString().trim(): element.attributes['href'].toString()
                  };
                  watchingLinks.addAll(params);
                }
                // Return the encoded JSON string of watching links
                return Future.value(json.encode(watchingLinks));
              },
            ),
            keywordsSelector: ElementSelector(
              selector: 'meta[name="keywords"]',
              attribute: 'content', // Extract duration from text content
            ),
            contentSelector: ElementSelector(
                selector:
                    '.main-container > .box > .list-videos > .margin-fix > .item'),
            videoSelector: ElementSelector(selector: '.block-video'),
          ),
        );
}
