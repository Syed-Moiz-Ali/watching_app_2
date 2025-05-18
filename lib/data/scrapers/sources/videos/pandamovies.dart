// import 'package:html/dom.dart' as html;

// class PandaMovies {
//   dynamic getProperty(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       switch (propertyName) {
//         case 'image':
//           // print('image is ${element.querySelector('a >  img')!.outerHtml}');
//           return element
//                   .querySelector('a >  img')
//                   ?.attributes['data-lazy-src'] ??
//               '';
//         case 'id':
//           return element.querySelector('a')?.attributes['href'] ?? '';
//         case 'title':
//           return element.querySelector('a > img')?.attributes['alt'] ?? '';
//         case 'duration':
//           return element
//                   .querySelector('a >.mli-info1')
//                   ?.text
//                   .replaceAll('HD', '')
//                   .trim() ??
//               '';
//         case 'preview':
//           return '';
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
//           return element.querySelectorAll(
//               '.movies-list-wrap > .movies-list-full > .ml-item');
//         default:
//           return '';
//       }
//     }
//   }

//   dynamic getVideos(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       Map watchingLink = {};

//       var links = element.querySelectorAll('.Rtable1  > .Rtable1-cell > a ');

//       Map params = {'auto': links.first.attributes['href']};
//       watchingLink.addEntries(params.entries);
//       //  for (var element in links) {
//       //   var key = element.attributes['title'];

//       //   Map params = {
//       //     key.toString().trim(): element.attributes['href'].toString()
//       //   };
//       //   watchingLink.addAll(params);
//       // }
//       // Map params = {'auto': links};
//       // watchingLink.addEntries(params.entries);

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
//           return element.querySelectorAll('#main');
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

import '../../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Pandamovies extends BaseScraper {
  Pandamovies(ContentSource source)
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

        var links = element!.querySelectorAll('.Rtable1  > .Rtable1-cell > a ');

        Map params = {'auto': links.first.attributes['href']};
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
