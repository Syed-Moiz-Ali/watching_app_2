import 'package:html/dom.dart';

import '../../../../data/models/content_source.dart';
import '../../../../data/models/scraper_config.dart';
import '../../../../data/scrapers/base_scraper.dart';

class EroWall extends BaseScraper {
  EroWall(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'a >  img',
              attribute: 'alt', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              customExtraction: (Element element) {
                String imageUrl = element
                    .querySelector(' a > img')!
                    .attributes['src']
                    .toString()
                    .replaceAll('thumb', 'original');
                // }
                // log('image is $imageUrl');
                return Future.value(imageUrl.trim());
              },
            ),
            contentUrlSelector: ElementSelector(
              selector: ' a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            contentSelector: ElementSelector(
              selector: '.wrapper > .content > .wpmini',
            ),
            similarContentSelector: ElementSelector(
              selector: '',
            ),
          ),
        );
}
