import 'dart:convert';

import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../services/scrapers/base_scraper.dart';

class Spankbang extends BaseScraper {
  Spankbang(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: '.thumb',
              attribute: 'title', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              selector: '.thumb > picture > img',
              attribute: 'data-src', // Extract thumbnail from 'data-src'
            ),
            contentUrlSelector: ElementSelector(
              selector: '.thumb',
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
            videoSelector: ElementSelector(
              selector: 'main',
            ),
            contentSelector: ElementSelector(
              selector: '.video-list > .video-item',
            ),
          ),
        );
}
