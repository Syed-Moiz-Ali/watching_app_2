// import 'dart:convert';

// import '../../../models/content_source.dart';
// import '../../../models/scraper_config.dart';
// import '../../base_scraper.dart';

// class Spankbang extends BaseScraper {
//   Spankbang(ContentSource source)
//       : super(
//           source,
//           ScraperConfig(
//             titleSelector: ElementSelector(
//               selector: '.thumb',
//               attribute: 'title', // Extract title from 'title' attribute
//             ),
//             thumbnailSelector: ElementSelector(
//               selector: '.thumb > picture > img',
//               attribute: 'data-src', // Extract thumbnail from 'data-src'
//             ),
//             contentUrlSelector: ElementSelector(
//               selector: '.thumb',
//               attribute: 'href', // Extract content URL from 'href' attribute
//             ),
//             qualitySelector: ElementSelector(
//               selector: '.thumb >  .h',
//             ),
//             timeSelector: ElementSelector(
//               selector: '.thumb >  .l',
//             ),
//             durationSelector: ElementSelector(
//               selector: '.thumb >  .l',
//             ),
//             previewSelector: ElementSelector(
//               selector: '.thumb > picture > img',
//               attribute: 'data-preview',
//             ),
//             watchingLinkSelector: ElementSelector(
//               customExtraction: (element) {
//                 var scripts = element
//                     .querySelectorAll('script[type="application/ld+json"]');
//                 var scriptContainingEmbedUrl = scripts.firstWhere(
//                   (element) => element.text.contains('embedUrl'),
//                 );

//                 var jsonString1 = scriptContainingEmbedUrl.text;
//                 var jsonData = json.decode(jsonString1);

//                 Map watchingLink = {};
//                 Map params = {'auto': jsonData['contentUrl']};
//                 watchingLink.addEntries(params.entries);
//                 return Future.value(json.encode(watchingLink));
//               },
//             ),
//             keywordsSelector: ElementSelector(
//               selector: 'meta[name="keywords"]',
//               attribute: 'content',
//             ),
//             similarContentSelector: ElementSelector(
//               selector: '.user_uploads > .video-list > .video-item',
//             ),
//             videoSelector: ElementSelector(
//               selector: 'main',
//             ),
//             contentSelector: ElementSelector(
//               selector: '.video-list > .video-item',
//             ),
//           ),
//         );
// }

import 'dart:convert';
import 'dart:developer';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Spankbang extends BaseScraper {
  Spankbang(ContentSource source) : super(source, source.config!);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == config.watchingLinkSelector) {
      try {
        var scripts =
            element!.querySelectorAll('script[type="application/ld+json"]');
        log('scripts is $scripts');
        var scriptContainingEmbedUrl = scripts.firstWhere(
          (element) => element.text.contains('embedUrl'),
        );

        var jsonString1 = scriptContainingEmbedUrl.text;
        var jsonData = json.decode(jsonString1);
        log('jsonData is $jsonData');
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
