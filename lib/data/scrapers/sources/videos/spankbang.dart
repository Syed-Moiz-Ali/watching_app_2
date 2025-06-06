import 'dart:convert';
import 'dart:developer';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Spankbang extends BaseScraper {
  Spankbang(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    if (selector == source.config!.watchingLinkSelector) {
      log("this is scraper class in this and selector is ${selector == source.config!.watchingLinkSelector && document != null}");
      try {
        var scripts =
            element!.querySelectorAll('script[type="application/ld+json"]');
        var scriptContainingEmbedUrl = scripts.firstWhere(
          (element) => element.text.contains('embedUrl'),
        );

        var jsonString1 = scriptContainingEmbedUrl.text;
        var jsonData = json.decode(jsonString1);
        Map watchingLink = {};
        Map params = {'auto': jsonData['contentUrl']};
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
