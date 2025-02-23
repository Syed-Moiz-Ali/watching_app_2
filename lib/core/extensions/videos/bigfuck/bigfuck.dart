import 'package:html/dom.dart' as html;

class BigFuck {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.b-thumb-item__inner  > a >  img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element
                  .querySelector(' .b-thumb-item__inner  > a')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector('.b-thumb-item__inner  > .b-thumb-item__title')
                  ?.text ??
              '';
        case 'duration':
          return element
                  .querySelector('.b-thumb-item__inner  > a > .thumb-badge')
                  ?.text
                  .replaceAll('HD', '')
                  .trim() ??
              '';
        case 'preview':
          return element
                  .querySelector('.b-thumb-item__inner  > a ')
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
          return element.querySelectorAll('#galleries > .b-thumb-item');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
      var links = element.querySelector('#video > source')?.attributes['src'];
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
          return element.querySelectorAll('main');
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
