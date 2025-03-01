import 'package:html/dom.dart';

import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../services/scrapers/base_scraper.dart';

class WallpaperPorn extends BaseScraper {
  WallpaperPorn(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: ' a >  img',
              attribute: 'alt', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              customExtraction: (Element element) {
                var imageUrl = element
                    .querySelector(' a > img')
                    ?.attributes['src']
                    .toString()
                    .replaceAll('thumbnail/md', '1920x1080')
                    .replaceAll('thumbnail/lg', '1920x1080');

                // log('image is $imageUrl');
                return Future.value(imageUrl!.trim());
              },
            ),
            contentUrlSelector: ElementSelector(
              selector: ' a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            contentSelector: ElementSelector(
              selector: '.row > .col-sm-6 ',
            ),
          ),
        );
}
