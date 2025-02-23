import 'dart:developer';

import 'package:html/dom.dart' as html;

class Mangoporn {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          // print('image is ${element.querySelector('a >  img')!.outerHtml}');
          return element.querySelector('.poster  >  img')?.attributes['src'] ??
              '';
        case 'id':
          return element.querySelector('.poster  > a ')?.attributes['href'] ??
              '';
        case 'title':
          return element.querySelector('.poster  >  img')?.attributes['alt'] ??
              '';
        case 'duration':
          return element
                  .querySelector('.poster  >  .durations  >.duration')
                  ?.text
                  .trim() ??
              '';
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
          return element
              .querySelectorAll('.module > .content > .items > .item');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};

      var links = element.querySelectorAll('.hosts-buttons-wpx');

      for (var link in links) {
        var href = link.querySelector('a')?.attributes['href'];
        if (href != null) {
          if (href.contains('lulu')) {
            watchingLink['auto'] = href;
            break; // Exit loop when 'lulu' link is found
          } else if (href.contains('filemoon')) {
            watchingLink['auto'] = href;
            break; // Exit loop when 'filemoon' link is found
          } else if (href.contains('vidguard')) {
            watchingLink['auto'] = href;
            break; // Exit loop when 'filemoon' link is found
          } else if (href.contains('swiftload')) {
            watchingLink['auto'] = href;
            break; // Exit loop when 'filemoon' link is found
          } else if (href.contains('doodplay')) {
            watchingLink['auto'] = href;
            break; // Exit loop when 'doodplay' link is found
          }
          // Add other keywords here as necessary
        }
      }

// If no links match the keywords, you can set a default link (optional).
      if (!watchingLink.containsKey('auto')) {
        watchingLink['auto'] =
            links.first.querySelector('a')?.attributes['href'];
      }
      //  for (var element in links) {
      //   var key = element.attributes['title'];

      //   Map params = {
      //     key.toString().trim(): element.attributes['href'].toString()
      //   };
      //   watchingLink.addAll(params);
      // }
      // Map params = {'auto': links};
      // watchingLink.addEntries(params.entries);

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
          log('selector ${element.querySelectorAll('#playeroptionsul')}');
          return element.querySelectorAll('#playeroptionsul');
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
