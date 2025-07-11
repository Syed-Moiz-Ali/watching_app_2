import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class EroWall extends BaseScraper {
  EroWall(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    if (selector == source.config!.thumbnailSelector) {
      try {
        String imageUrl = element!
            .querySelector(' a > img')!
            .attributes['src']
            .toString()
            .replaceAll('thumb', 'original');
        // }
        // log('image is $imageUrl');
        return Future.value(imageUrl.trim());
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    }
    return null;
  }
}
