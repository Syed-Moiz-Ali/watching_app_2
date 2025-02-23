import 'dart:developer';

import 'package:html/dom.dart' as html;

class LuxureTv {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          var imageUrl =
              element.querySelector('a > img')?.attributes['data-src'] ?? '';
          // log('image is $imageUrl');
          return imageUrl.trim();
        // return element
        //         .querySelector('article > div > a > .g1-frame-inner > img')
        //         ?.attributes['src'] ??
        //     '';
        case 'id':
          return element.querySelector(' a ')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector(' a  ')?.attributes['title'] ?? '';
        case 'duration':
          return '';
        case 'preview':
          return '';
        case 'quality':
          return 'HD';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          log('luxertv selector is ${element.toString()}');
          return element.querySelectorAll(
              '#main-wrapper > #main >  #left > .contents > .content');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      log('the link of this is ${element.querySelector('video > source')!.outerHtml}');
      var links = element.querySelector('video > source')?.attributes['src'];
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
          // log('the selector is ${element.querySelectorAll('.g1-content-narrow').first.outerHtml}');
          return element.querySelectorAll('.g1-content-narrow');
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
