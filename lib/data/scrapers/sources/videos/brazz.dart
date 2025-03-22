// // ignore_for_file: file_names
// import 'dart:developer';

// import 'package:html/dom.dart' as html;

// class Brazz {
//   dynamic getProperty(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       switch (propertyName) {
//         case 'image':
//           return element
//                   .querySelector(
//                       'a > .post-thumbnail > .post-thumbnail-container > img')
//                   ?.attributes['data-src'] ??
//               '';
//         case 'id':
//           return element.querySelector('a')?.attributes['href'] ?? '';
//         case 'title':
//           return element.querySelector('a > .entry-header > span')?.text ?? '';
//         case 'duration':
//           return element
//                   .querySelector('a > .post-thumbnail > .duration')
//                   ?.text
//                   .replaceAll('HD', '')
//                   .trim() ??
//               '';
//         case 'preview':
//           return
//               // element
//               //         .querySelector(
//               //             'a > .post-thumbnail > .post-thumbnail-container > .video-preview > source')
//               //         ?.attributes['src'] ??
//               '';
//         case 'quality':
//           return 'HD';
//         case 'time':
//           return "";
//         default:
//           return '';
//       }
//     } else {
//       switch (propertyName) {
//         case 'selector':
//           log('the selector is ${element.querySelectorAll(' .videos-list').first.outerHtml}');
//           return element.querySelectorAll('.videos-list > article');
//         default:
//           return '';
//       }
//     }
//   }

//   dynamic getVideos(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       Map watchingLink = {};
//       var links = element.querySelector('video > source')?.attributes['src'];
//       Map params = {'auto': links};
//       watchingLink.addEntries(params.entries);
//       switch (propertyName) {
//         case 'watchingLink':
//           return watchingLink;
//         default:
//           return '';
//       }
//     } else {
//       switch (propertyName) {
//         case 'selector':
//           return element.querySelectorAll('.mediabox');
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

class Brazz extends BaseScraper {
  Brazz(ContentSource source) : super(source, source.config!);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    if (selector == config.watchingLinkSelector) {
      try {
        Map watchingLink = {};
        var links = element!.querySelector('video > source')?.attributes['src'];

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
