import 'dart:convert';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Kompoz2 extends BaseScraper {
  Kompoz2(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map watchingLink = {};
        var links = element!.querySelector('video > source')?.attributes['src'];

        Map params = {'auto': links};
        watchingLink.addEntries(params.entries);
        return Future.value(json.encode(watchingLink));
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    }
    return null;
  }
}
