import 'dart:convert';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class SxyPrn extends BaseScraper {
  SxyPrn(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: '.js-pop',
              attribute: 'aria-label', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              selector: '.js-pop > .vid_container >   .post_vid_thumb > img',
              attribute: 'data-src', // Extract thumbnail from 'data-src'
            ),
            contentUrlSelector: ElementSelector(
              selector: '.js-pop',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            qualitySelector: ElementSelector(
              selector:
                  '.js-pop  > .vid_container >   .post_vid_thumb > .shd_small',
            ),
            timeSelector: ElementSelector(
              selector: '.post_control >.post_time > .post_control_time',
            ),
            durationSelector: ElementSelector(
              selector:
                  '.js-pop  > .vid_container >   .post_vid_thumb >.duration_small',
            ),
            previewSelector: ElementSelector(
              selector:
                  '.js-pop  > .vid_container >   .post_vid_thumb >  video',
              attribute: 'src',
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
            videoSelector: ElementSelector(
              selector: 'main',
            ),
            contentSelector: ElementSelector(
              selector: '#content_div > .main_content > div > .post_el_small',
            ),
          ),
        );
}
