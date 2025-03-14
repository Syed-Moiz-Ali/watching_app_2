// ignore_for_file: avoid_print

// import 'dart:developer';

// import 'package:html/dom.dart' as html;

// class PornTop {
//   dynamic getProperty(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       switch (propertyName) {
//         case 'image':
//           return element
//                   .querySelector('a > .img > img')
//                   ?.attributes['data-original'] ??
//               '';
//         case 'id':
//           return element.querySelector('a')?.attributes['href'] ?? '';
//         case 'title':
//           return element.querySelector('a > .img > img')?.attributes['alt'] ??
//               '';
//         case 'duration':
//           return element.querySelector('a > .img >  .duration')?.text.trim() ??
//               '';
//         case 'preview':
//           return element
//                   .querySelector('a > .img > img')
//                   ?.attributes['data-preview'] ??
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
//           return element.querySelectorAll('.list-videos > .margin-fix > .item');
//         default:
//           return '';
//       }
//     }
//   }

//   dynamic getVideos(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       Map watchingLink = {};
//       // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
//       // var links = element
//       //     .querySelector('.responsive-player > iframe')
//       //     ?.attributes['src'];
//       // Map params = {'auto': links};
//       // watchingLink.addEntries(params.entries);
//       List<html.Element> scriptTags = element.querySelectorAll('script');

//       // Find the script tag containing '<![CDATA[' in its content
//       html.Element? cdataScriptTag = scriptTags.firstWhere(
//         (scriptTag) => scriptTag.text.startsWith('let vpage_data='),
//         // orElse: () => null,
//       );
//       // print('cdataScriptTag is $cdataScriptTag');
//       Map<String, String> dataMap = extractDataFromScript(cdataScriptTag);

//       // Print the extracted data map
//       print(dataMap);
//       Map params = {
//         'auto': 'https://porntop.com/embed.php?id=${dataMap['vid']}'
//       };
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
//           log('this is selector ${element.querySelectorAll('.video-holder > .player > .player-holder').first.outerHtml}');
//           return element.querySelectorAll('html');
//         case 'keywords':
//           return element
//               .querySelector('meta[name="keywords"]')
//               ?.attributes['content'];
//         default:
//           return '';
//       }
//     }
//   }

//   Map<String, String> extractDataFromScript(html.Element scriptTag) {
//     // Initialize an empty map to store the extracted data
//     Map<String, String> dataMap = {};

//     // Get the text content of the script tag
//     String jsContent = scriptTag.text;
//     // print('jsContent is ${jsContent.replaceAll('let vpage_data={', '')}');
//     // Define regular expressions to extract key-value pairs from the JavaScript content
//     RegExp regex = RegExp(r'vid:(\d+)');

//     Match? match = regex.firstMatch(jsContent);
//     if (match != null) {
//       String vid = match.group(1)!;
//       print('vid: $vid');
//       dataMap.addEntries({'vid': vid}.entries);
//     } else {
//       print('vid not found');
//     }
//     // Return the extracted data map
//     return dataMap;
//   }
// }

import 'dart:convert';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Porntop extends BaseScraper {
  Porntop(ContentSource source) : super(source, source.config!);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == config.watchingLinkSelector) {
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
        print(dataMap);
        Map params = {
          'auto': 'https://porntop.com/embed.php?id=${dataMap['vid']}'
        };
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
      print('vid: $vid');
      dataMap.addEntries({'vid': vid}.entries);
    } else {
      print('vid not found');
    }
    // Return the extracted data map
    return dataMap;
  }
}
