// import 'package:html/dom.dart' as html;

// class Eroticmv {
//   dynamic getProperty(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       switch (propertyName) {
//         case 'image':
//           var srcset = element
//               .querySelector(
//                   '.post-item-wrap > .blog-pic >.blog-pic-wrap > a >   img')
//               ?.attributes['srcset'];
//           var imageUrl = '';
//           if (srcset != null) {
//             var sources = srcset.split(', ');
//             if (sources.isNotEmpty) {
//               var firstSource = sources.first;
//               var parts = firstSource.split(' ');
//               if (parts.length >= 2) {
//                 imageUrl = parts[0];
//               }
//             }
//           } else {
//             imageUrl = element
//                     .querySelector(
//                         '.post-item-wrap > .blog-pic >.blog-pic-wrap > a >   img')
//                     ?.attributes['src'] ??
//                 '';
//           }
//           // log('image is $imageUrl');
//           return imageUrl.trim();
//         // return element
//         //         .querySelector('.post-item-wrap > .blog-pic >.blog-pic-wrap > a >   img')
//         //         ?.attributes['data-src'] ??
//         //     '';
//         case 'id':
//           return element
//                   .querySelector(
//                       '.post-item-wrap > .blog-pic >.blog-pic-wrap > a')
//                   ?.attributes['href'] ??
//               '';
//         case 'title':
//           return element
//                   .querySelector(
//                       '.post-item-wrap > .blog-pic >.blog-pic-wrap > a')
//                   ?.attributes['title'] ??
//               '';
//         case 'duration':
//           return '';
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
//               '#main-content > .blog-wrapper > .blog-items  > article');
//         default:
//           return '';
//       }
//     }
//   }

//   dynamic getVideos(dynamic element, String propertyName) {
//     if (element is html.Element) {
//       Map watchingLink = {};

//       List<html.Element> scriptTags = element.querySelectorAll('script');

//       // Find the script tag containing '<![CDATA[' in its content
//       html.Element? cdataScriptTag = scriptTags.firstWhere(
//         (scriptTag) => scriptTag.text.contains('playlist'),
//         // orElse: () => null,
//       );

//       // // Extract data from the script tag
//       extractDataFromScript(cdataScriptTag);

//       // // Print the extracted data map
//       Map params = {'auto': watchingLink};
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
//           return element.querySelectorAll('html');
//         case 'keywords':
//           return element
//               .querySelector('meta[name="keywords"]')
//               ?.attributes['content'];
//         case 'metaVideoUrl':
//           var links = element
//               .querySelector('meta[property="og:video:url"]')
//               ?.attributes['content'];
//           Map params = {'auto': links};

//           return params;
//         default:
//           return '';
//       }
//     }
//   }

//   String? extractDataFromScript(html.Element scriptTag) {
//     // Initialize an empty map to store the extracted data

//     // Get the text content of the script tag
//     String jsContent = scriptTag.text;

//     // Define regular expressions to extract key-value pairs from the JavaScript content
//     RegExp videoUrlRegex = RegExp(r"window.playlistUrl: '([^']+)'");

//     // Find the first match for video_url
//     RegExpMatch? match = videoUrlRegex.firstMatch(jsContent);

//     // Return the video_url if found, otherwise return null
//     if (match != null) {
//       return match.group(1)!;
//     } else {
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:html/dom.dart';

import '../../../../core/global/globals.dart';
import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Eroticmv extends BaseScraper {
  Eroticmv(ContentSource source)
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

        List<Element> scriptTags = element!.querySelectorAll('script');

        // Find the script tag containing '<![CDATA[' in its content
        Element? cdataScriptTag = scriptTags.firstWhere(
          (scriptTag) => scriptTag.text.contains('playlist'),
          // orElse: () => null,
        );

        // // Extract data from the script tag
        extractDataFromScript(cdataScriptTag);

        // // Print the extracted data map
        Map params = {'auto': watchingLink};
        watchingLink.addEntries(params.entries);
        return Future.value(json.encode(watchingLink));
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    } else if (selector == source.config!.thumbnailSelector) {
      try {
        var srcset = element!
            .querySelector(
                '.post-item-wrap > .blog-pic >.blog-pic-wrap > a >   img')
            ?.attributes['srcset'];
        var imageUrl = '';
        if (srcset != null) {
          var sources = srcset.split(', ');
          if (sources.isNotEmpty) {
            var firstSource = sources.first;
            var parts = firstSource.split(' ');
            if (parts.length >= 2) {
              imageUrl = parts[0];
            }
          }
        } else {
          imageUrl = element
                  .querySelector(
                      '.post-item-wrap > .blog-pic >.blog-pic-wrap > a >   img')
                  ?.attributes['src'] ??
              '';
        }
        // log('image is $imageUrl');
        return Future.value(imageUrl.trim());
      } catch (e) {
        SMA.logger.logError('Error extracting watching link: $e');
        return '';
      }
    }
    return null;
  }

  String? extractDataFromScript(Element scriptTag) {
    // Initialize an empty map to store the extracted data

    // Get the text content of the script tag
    String jsContent = scriptTag.text;

    // Define regular expressions to extract key-value pairs from the JavaScript content
    RegExp videoUrlRegex = RegExp(r"window.playlistUrl: '([^']+)'");

    // Find the first match for video_url
    RegExpMatch? match = videoUrlRegex.firstMatch(jsContent);

    // Return the video_url if found, otherwise return null
    if (match != null) {
      return match.group(1)!;
    } else {
      return null;
    }
  }
}
