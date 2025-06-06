// ignore_for_file: file_names

// import 'dart:developer';

// import 'package:html/dom.dart' as html;

// class Eporner {
//   dynamic getProperty(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       switch (propertyName) {
//         case 'image':
//           log('image is ${element.querySelector('.mbimg > .mbcontent > a  > img')?.outerHtml}');
//           return element
//                   .querySelector('.mbimg > .mbcontent > a  > img')
//                   ?.attributes['data-src'] ??
//               "";
//         case 'id':
//           return element
//                   .querySelector('.mbimg > .mbcontent > a')
//                   ?.attributes['href'] ??
//               '';
//         case 'title':
//           return element
//                   .querySelector('.mbimg > .mbcontent > a  > img')
//                   ?.attributes['alt'] ??
//               '';
//         case 'duration':
//           return element.querySelector('.mbunder > .mbstats >.mbtim')?.text ??
//               '';
//         case 'preview':
//           return '';
//         case 'quality':
//           return element
//                   .querySelector('.mbimg > .mbcontent  > .mvhdico >span')
//                   ?.text ??
//               'HD';
//         case 'time':
//           return "${element.querySelector('.mbunder > .mbstats >.mbtim')?.text} ";
//         default:
//           return '';
//       }
//     } else {
//       switch (propertyName) {
//         case 'selector':
//           return element.querySelectorAll('#vidresults > .mb');
//         default:
//           return '';
//       }
//     }
//   }

//   dynamic getVideos(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       Map watchingLink = {};
//       // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
//       var links = extractVideoUrlOrAltUrlFromScript(element);

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
//           return element.querySelectorAll('main');
//         case 'keywords':
//           return element
//               .querySelector('meta[name="keywords"]')
//               ?.attributes['content'];
//         default:
//           return '';
//       }
//     }
//   }

//   dynamic extractVideoUrlOrAltUrlFromScript(html.Element element) {
//     // Get all script tags
//     final scriptTags = element.getElementsByTagName('script');

//     // Iterate over all script tags
//     for (var script in scriptTags) {
//       final scriptContent = script.innerHtml;

//       // Check if the script contains 'embedUrl' or 'contentUrl'
//       if (scriptContent.contains('"embedUrl"') ||
//           scriptContent.contains('"contentUrl"')) {
//         log('scriptContent is $scriptContent');

//         // Define regex patterns to capture 'embedUrl' and 'contentUrl'
//         final videoUrlPattern =
//             RegExp(r'"embedUrl"\s*:\s*"(.*?)"', dotAll: true);
//         final videoAltUrlPattern =
//             RegExp(r'"contentUrl"\s*:\s*"(.*?)"', dotAll: true);

//         // Try to extract video_url
//         final videoUrlMatch = videoUrlPattern.firstMatch(scriptContent);
//         log('videoUrlMatch is $videoUrlMatch');
//         if (videoUrlMatch != null) {
//           final videoUrl = videoUrlMatch.group(1);
//           log('videoUrl is $videoUrl');
//           return videoUrl; // Return embedUrl if found
//         }

//         // If embedUrl is not found, try to extract contentUrl
//         final videoAltUrlMatch = videoAltUrlPattern.firstMatch(scriptContent);
//         log('videoAltUrlMatch is $videoAltUrlMatch');
//         if (videoAltUrlMatch != null) {
//           final videoAltUrl = videoAltUrlMatch.group(1);
//           log('videoAltUrl is $videoAltUrl');
//           return videoAltUrl; // Return contentUrl if embedUrl is not found
//         }
//       }
//     }

//     // If neither video_url nor video_alt_url is found, return null or handle accordingly
//     return null;
//   }
// }

import 'dart:convert';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Eporner extends BaseScraper {
  Eporner(super.source);

  @override
  Future<String?> extractCustomValue(ElementSelector selector,
      {Element? element, Document? document}) async {
    // log("this is scraper class in this and selector is ${selector == config.watchingLinkSelector && document != null}");
    if (selector == source.config!.watchingLinkSelector) {
      try {
        Map watchingLink = {};
        // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
        var links = extractVideoUrlOrAltUrlFromScript(element);

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

  dynamic extractVideoUrlOrAltUrlFromScript(Element? element) {
    // Get all script tags
    final scriptTags = element!.getElementsByTagName('script');

    // Iterate over all script tags
    for (var script in scriptTags) {
      final scriptContent = script.innerHtml;

      // Check if the script contains 'embedUrl' or 'contentUrl'
      if (scriptContent.contains('"embedUrl"') ||
          scriptContent.contains('"contentUrl"')) {
        // Define regex patterns to capture 'embedUrl' and 'contentUrl'
        final videoUrlPattern =
            RegExp(r'"embedUrl"\s*:\s*"(.*?)"', dotAll: true);
        final videoAltUrlPattern =
            RegExp(r'"contentUrl"\s*:\s*"(.*?)"', dotAll: true);

        // Try to extract video_url
        final videoUrlMatch = videoUrlPattern.firstMatch(scriptContent);
        if (videoUrlMatch != null) {
          final videoUrl = videoUrlMatch.group(1);
          return videoUrl; // Return embedUrl if found
        }

        // If embedUrl is not found, try to extract contentUrl
        final videoAltUrlMatch = videoAltUrlPattern.firstMatch(scriptContent);
        if (videoAltUrlMatch != null) {
          final videoAltUrl = videoAltUrlMatch.group(1);
          return videoAltUrl; // Return contentUrl if embedUrl is not found
        }
      }
    }

    // If neither video_url nor video_alt_url is found, return null or handle accordingly
    return null;
  }
}
