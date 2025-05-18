import 'dart:convert';

import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class HQPorner extends BaseScraper {
  HQPorner(ContentSource source)
      : super(
          source,
        );

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map watchingLinks = {};
        var links = element!.querySelector('script')?.text;
        RegExp regExp = RegExp(r"url: '.*\?i=(//.*?/video/.*?)'");

        // Find the first match in the script content
        RegExpMatch? match = regExp.firstMatch(links!);
        String? link = '';
        if (match != null) {
          link = 'https:${match.group(1)}';
        } else {}
        Map params = {'auto': link};
        watchingLinks.addEntries(params.entries);
        // Return the encoded JSON string of watching links
        return Future.value(json.encode(watchingLinks));
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    } else if (selector == source.config!.thumbnailSelector) {
      try {
        var imageElement = element!
            .querySelector('section > a > div')!
            .attributes['onmouseleave']!
            .split(',')
            .first
            .replaceAll('defaultImage(', '')
            .replaceAll('"', '');

        return Future.value(imageElement);
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    }
    return null;
  }
}
