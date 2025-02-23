import 'dart:developer';

import 'package:html/dom.dart' as html;

class PmateHnter {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          var srcset =
              element.querySelector('figure > a > img')?.attributes['srcset'];
          log('srcset is ${srcset!.trim()}');
          var imageUrl = '';
          // if (srcset != null) {
          // Split the srcset attribute by comma to get individual sources
          var sources = srcset.trim().split(', ');
          if (sources.isNotEmpty) {
            // Get the first source
            var firstSource = sources.first;
            // Split the first source by space to get the URL and size
            var parts = firstSource.split(' ');
            log('parts is $parts');
            if (parts.length >= 2) {
              // The URL is the first part
              imageUrl = parts[0];
            }
          } else {
            imageUrl =
                element.querySelector('figure > a > img')?.attributes['src'] ??
                    '';
          }
          // }
          // log('image is $imageUrl');
          return imageUrl.trim();
        case 'id':
          return element.querySelector('figure > a')?.attributes['href'] ?? '';
        case 'title':
          return element
                  .querySelector('figure > a >  img')
                  ?.attributes['alt'] ??
              '';
        case 'duration':
          return '';
        case 'preview':
          return '';
        case 'quality':
          return '';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          // log('this is selector' +
          //     element
          //         .querySelectorAll('#content > .list-gallery > li')
          //         ?.first
          //         .outerHtml);
          return element.querySelectorAll('#content > .list-gallery > li');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
      var links = element
          .querySelector('.responsive-player > iframe')
          ?.attributes['src'];
      Map params = {'auto': links};
      watchingLink.addEntries(params.entries);

      // final streamDataJson = match.group(1)?.replaceAll("'", '"') ?? '';
      // final streamUrls = Map<String, dynamic>.from(streamDataJson);
      // final keywords = match2!.group(1) ?? '';
      switch (propertyName) {
        case 'watchingLink':

          // return Episode(streamUrls: streamUrls, keywords: keywords);

          return watchingLink;
        // case 'keywords':
        //   return keywords;
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('#main');
        case 'keywords':
          return element
              .querySelector('meta[name="keywords"]')
              ?.attributes['content'];
        default:
          return '';
      }
    }
  }
}
