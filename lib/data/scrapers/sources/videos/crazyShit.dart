// ignore_for_file: file_names

import 'dart:convert';

import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class CrazyShit extends BaseScraper {
  CrazyShit(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map watchingLinks = {};
        var selector = element!.querySelector('.media > .mediabox');
        var links =
            selector!.querySelector('video > source')?.attributes['src'];

        Map params = {'auto': links};
        watchingLinks.addEntries(params.entries);

        // Return the encoded JSON string of watching links
        return Future.value(json.encode(watchingLinks));
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    }
    return null;
  }
}
