import 'dart:convert';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Porntop extends BaseScraper {
  Porntop(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map watchingLink = {};

        List<Element> scriptTags = element!.querySelectorAll('script');

        // Find the script tag containing '<![CDATA[' in its content
        Element? cdataScriptTag = scriptTags.firstWhere(
          (scriptTag) => scriptTag.text.startsWith('let vpage_data='),
          // orElse: () => null,
        );
        // print('cdataScriptTag is $cdataScriptTag');
        Map<String, String> dataMap = extractDataFromScript(cdataScriptTag);

        // Print the extracted data map
        Map params = {'auto': '${source.url}embed.php?id=${dataMap['vid']}'};
        watchingLink.addEntries(params.entries);
        return Future.value(json.encode(watchingLink));
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    }
    return null;
  }

  Map<String, String> extractDataFromScript(Element scriptTag) {
    // Initialize an empty map to store the extracted data
    Map<String, String> dataMap = {};

    // Get the text content of the script tag
    String jsContent = scriptTag.text;
    // print('jsContent is ${jsContent.replaceAll('let vpage_data={', '')}');
    // Define regular expressions to extract key-value pairs from the JavaScript content
    RegExp regex = RegExp(r'vid:(\d+)');

    Match? match = regex.firstMatch(jsContent);
    if (match != null) {
      String vid = match.group(1)!;
      dataMap.addEntries({'vid': vid}.entries);
    } else {}
    // Return the extracted data map
    return dataMap;
  }
}
