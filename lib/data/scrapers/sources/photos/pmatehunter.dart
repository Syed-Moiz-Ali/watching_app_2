import 'package:html/dom.dart';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class PMateHunter extends BaseScraper {
  PMateHunter(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: 'figure > a >  img',
              attribute: 'alt', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              customExtraction: (Element element) {
                var srcset = element
                    .querySelector('figure > a > img')
                    ?.attributes['srcset'];
                // log('srcset is ${srcset!.trim()}');
                var imageUrl = '';
                // if (srcset != null) {
                // Split the srcset attribute by comma to get individual sources
                var sources = srcset!.trim().split(', ');
                if (sources.isNotEmpty) {
                  // Get the first source
                  var firstSource = sources.first;
                  // Split the first source by space to get the URL and size
                  var parts = firstSource.split(' ');
                  // log('parts is $parts');
                  if (parts.length >= 2) {
                    // The URL is the first part
                    imageUrl = parts[0];
                  }
                } else {
                  imageUrl = element
                          .querySelector('figure > a > img')
                          ?.attributes['src'] ??
                      '';
                }
                // }
                // log('image is $imageUrl');
                return Future.value(imageUrl.trim());
              },
            ),
            contentUrlSelector: ElementSelector(
              selector: 'figure > a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            similarContentSelector: ElementSelector(
              selector: '.user_uploads > .video-list > .video-item',
            ),
            contentSelector: ElementSelector(
              selector: '#content > .list-gallery > li',
            ),
          ),
        );
}
