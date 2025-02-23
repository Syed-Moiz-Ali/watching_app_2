import 'dart:developer';

import 'package:html/dom.dart' as html;

class BDSM {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('a >  .thumb > img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element.querySelector('  a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('a  > .video-title > span')?.text ?? '';
        case 'duration':
          return element
                  .querySelector('a >  .thumb > .btime')
                  ?.text
                  .replaceAll('HD', '')
                  .trim() ??
              '';
        case 'preview':
          log('video tag ${element.querySelector('a >  video')?.outerHtml}');
          return element
                  .querySelector('a >  .thumb > img')
                  ?.attributes['data-preview'] ??
              '';
        case 'quality':
          return element.querySelector(
                      '.inner-wrapper > .video-thumb > a > .video-time > .quality') !=
                  null
              ? element
                  .querySelector(
                      '.inner-wrapper > .video-thumb > a > .video-time > .quality')!
                  .text
              : 'HD';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(
              '.wrap  > #content > .thumbs > .thumbs-container > .th');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
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
          log('selector tag ${element.querySelectorAll('#videoContainer')?.first.outerHtml}');
          return element.querySelectorAll('#videoContainer');
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
