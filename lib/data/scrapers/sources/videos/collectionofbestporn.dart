import 'dart:convert';
import 'package:html/dom.dart';
import '../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class CollectionOfBestPorn extends BaseScraper {
  CollectionOfBestPorn(ContentSource source)
      : super(
          source,
        );

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map watchingLink = {};
        var links = element!.querySelectorAll('div > video > source ');

        for (var element in links) {
          var key = '${element.attributes['res']}p';

          Map params = {
            key.toString().trim(): element.attributes['src'].toString()
          };
          watchingLink.addAll(params);
        }
        return Future.value(json.encode(watchingLink));
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    }
    return null;
  }
}
