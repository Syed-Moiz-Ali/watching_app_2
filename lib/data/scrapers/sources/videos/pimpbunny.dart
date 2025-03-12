import 'package:html/dom.dart';

import 'dart:convert';

import '../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class PimpBunny extends BaseScraper {
  PimpBunny(ContentSource source) : super(source, source.config!);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == config.watchingLinkSelector) {
      try {
        Map watchingLinks = {};
        // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');

        List<Element> scriptTags = element!.querySelectorAll('script');

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
        if (match != null) {
          var dataMap = match.group(1)!.replaceAll('function/0/', '');
          Map params = {'auto': 'https://pimpbunny.com/embed/$dataMap'};
          watchingLinks.addEntries(params.entries);
        } else {}
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
