import 'dart:convert';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';
import 'package:html/dom.dart';

class NoodleMagazine extends BaseScraper {
  NoodleMagazine(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map<String, dynamic> watchingLinks = {};

        final scriptTags = element!.getElementsByTagName('script');

        for (var script in scriptTags) {
          final scriptContent = script.outerHtml;

          if (scriptContent.contains('window.playlist')) {
            // Extract JSON-like data from the script
            final jsonPattern =
                RegExp(r'window\.playlist\s*=\s*(\{.*?\});', dotAll: true);
            final jsonMatch = jsonPattern.firstMatch(scriptContent);

            if (jsonMatch != null) {
              final jsonString = jsonMatch.group(1)!;

              try {
                // Try to parse the JSON string to validate its structure
                final jsonData = json.decode(jsonString);
                // If valid, return the JSON string or process it as needed
                var sources = jsonData['sources'];

                final sourceList = List.from(sources);

                for (var source in sourceList) {
                  final label = source['label'].toString();
                  final file = source['file'].toString();

                  watchingLinks['${label}p'] = file;
                }
              } catch (e) {
                // Handle JSON parsing error
              }
            }
          }
        }

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
