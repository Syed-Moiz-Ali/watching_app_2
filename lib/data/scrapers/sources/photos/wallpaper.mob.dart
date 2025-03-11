import 'package:html/dom.dart';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class WallpaperMob extends BaseScraper {
  WallpaperMob(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'div > a >  img',
              attribute: 'alt', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
                // customExtraction: (Element element) {
                //   var srcset = element
                //       .querySelector('div > a > img')
                //       ?.attributes['srcset'];
                //   var imageUrl = '';
                //   if (srcset != null) {
                //     // Split the srcset attribute by comma to get individual sources
                //     var sources = srcset.split(', ');
                //     if (sources.isNotEmpty) {
                //       // Get the first source
                //       var firstSource = sources.last;
                //       // Split the first source by space to get the URL and size
                //       var parts = firstSource.split(' ');
                //       if (parts.length >= 2) {
                //         // The URL is the first part
                //         imageUrl = parts[0];
                //       }
                //     }
                //   } else {
                //     imageUrl = element
                //             .querySelector('figure > a > img')
                //             ?.attributes['data-src'] ??
                //         '';
                //   }
                //   // log('image is $imageUrl');
                //   return Future.value(imageUrl.trim());
                // },
                ),
            contentUrlSelector: ElementSelector(
              selector: 'div > a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            contentSelector: ElementSelector(
              selector:
                  '.container-2  > .image-gallery-items > .image-gallery-items__item ',
            ),
          ),
        );
}
