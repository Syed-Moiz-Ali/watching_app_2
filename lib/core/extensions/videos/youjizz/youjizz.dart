import 'package:html/dom.dart' as html;

class YouJizz {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.video-item > .frame-wrapper > a >  img')
                  ?.attributes['data-orignal'] ??
              '';
        case 'id':
          return element
                  .querySelector('.video-item > .frame-wrapper > a ')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector(' .video-item > .video-title > a ')
                  ?.text ??
              '';
        case 'duration':
          return element
                  .querySelector(
                      '.video-item  > .video-content-wrapper  > .time')
                  ?.text
                  .trim() ??
              '';
        case 'preview':
          return element
                  .querySelector('.video-item > .frame-wrapper > a ')
                  ?.attributes['data-clip'] ??
              '';
        case 'quality':
          return element.querySelector(
                      '.video-item > .frame-wrapper > a >.i-hd') !=
                  null
              ? element
                  .querySelector('.video-item > .frame-wrapper > a >.i-hd')!
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
          return element.querySelectorAll(' .clearfix > .video-thumb');
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
          return element.querySelectorAll('.video-wrapper');
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
