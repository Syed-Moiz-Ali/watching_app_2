// import 'dart:developer';

// import 'package:html/dom.dart' as html;

// class XTapes {
//   dynamic getProperty(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       switch (propertyName) {
//         case 'image':
//           return element.querySelector('img')?.attributes['src'] ?? '';
//         case 'id':
//           return element.querySelector('a')?.attributes['href'] ?? '';
//         case 'title':
//           return element.querySelector('a > span')?.text ?? '';
//         case 'duration':
//           return element
//                   .querySelector('l.isting-infos  > .time-infos')
//                   ?.text
//                   .replaceAll('HD', '')
//                   .trim() ??
//               '';
//         case 'preview':
//           return '';
//         case 'quality':
//           return element.querySelector(
//                       '.inner-wrapper > .video-thumb > a > .video-time > .quality') !=
//                   null
//               ? element
//                   .querySelector(
//                       '.inner-wrapper > .video-thumb > a > .video-time > .quality')!
//                   .text
//               : 'HD';
//         case 'time':
//           return "";
//         default:
//           return '';
//       }
//     } else {
//       switch (propertyName) {
//         case 'selector':
//           return element.querySelectorAll('.listing-videos > li');
//         default:
//           return '';
//       }
//     }
//   }

//   dynamic getVideos(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       Map watchingLink = {};
//       log('the link of this is ${element.querySelector('.video-embed')!.outerHtml}');
//       var links =
//           element.querySelector('.video-embed > iframe')?.attributes['src'];
//       Map params = {'auto': links};
//       watchingLink.addEntries(params.entries);

//       // final streamDataJson = match.group(1)?.replaceAll("'", '"') ?? '';
//       // final streamUrls = Map<String, dynamic>.from(streamDataJson);
//       // final keywords = match2!.group(1) ?? '';
//       switch (propertyName) {
//         case 'watchingLink':

//           // return Episode(streamUrls: streamUrls, keywords: keywords);

//           return watchingLink;
//         // case 'keywords':
//         //   return keywords;
//         default:
//           return '';
//       }
//     } else {
//       switch (propertyName) {
//         case 'selector':
//           return element.querySelectorAll('#video-code');
//         case 'keywords':
//           return element
//               .querySelector('meta[name="keywords"]')
//               ?.attributes['content'];
//         default:
//           return '';
//       }
//     }
//   }
// }

import 'dart:convert';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Xtapes extends BaseScraper {
  Xtapes(ContentSource source) : super(source, source.config!);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == config.watchingLinkSelector) {
      try {
        Map watchingLink = {};
        var links =
            element!.querySelector('.video-embed > iframe')?.attributes['src'];
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
