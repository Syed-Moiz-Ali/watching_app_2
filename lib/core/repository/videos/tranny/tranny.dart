import 'package:html/dom.dart' as html;

class Tranny {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('a > .post-thumbnail  > img')
                  ?.attributes['src'] ??
              element
                  .querySelector('a > .post-thumbnail > .inner-border > img')
                  ?.attributes['data-src'] ??
              '';
        case 'id':
          return element.querySelector('a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('a > .entry-header > span')?.text ?? '';
        case 'duration':
          return element
                  .querySelector('a > .post-thumbnail > .duration')
                  ?.text
                  .replaceAll('HD', '')
                  .trim() ??
              '';
        case 'preview':
          return '';
        case 'quality':
          return element.querySelector(
                      'div > .video_thumb_wrap  > a > .duration >.tm_video_duration > .video_quality') !=
                  null
              ? element
                  .querySelector(
                      'div > .video_thumb_wrap  > a > .duration >.tm_video_duration > .video_quality')!
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
          return element.querySelectorAll('#main > div > article');
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
              .querySelector('.video-player > meta[itemprop="contentURL"]')
              ?.attributes['content'] ??
          element
              .querySelector('.video-player > meta[itemprop="embedURL"]')
              ?.attributes['content'];
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
