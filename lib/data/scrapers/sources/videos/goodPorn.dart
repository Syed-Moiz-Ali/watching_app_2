// ignore_for_file: file_names

import 'dart:convert';

import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class GoodPorn extends BaseScraper {
  GoodPorn(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map watchingLinks = {};
        var links =
            element!.querySelector('.video-holder > .player > .player-holder');

        List<Element> scriptTags = links!.querySelectorAll('script');

        // Find the script tag containing '<![CDATA[' in its content
        Element? cdataScriptTag = scriptTags.firstWhere(
          (scriptTag) => scriptTag.text.contains('<![CDATA['),
          // orElse: () => null,
        );

        String jsContent = cdataScriptTag.text;

        // Define regular expressions to extract key-value pairs from the JavaScript content
        RegExp videoUrlRegex = RegExp(r"video_id: '([^']+)'");

        // Find the first match for video_url
        RegExpMatch? match = videoUrlRegex.firstMatch(jsContent);

        // Return the video_url if found, otherwise return null
        var newMatch = match?.group(1)!.replaceAll('function/0/', '');

        Map params = {'auto': '${source.url}/embed/$newMatch'};
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
