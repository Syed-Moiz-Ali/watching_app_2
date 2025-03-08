import 'package:html/dom.dart' as html;

class TabooHome {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.video-block > .thumb >  img')
                  ?.attributes['data-src'] ??
              '';
        case 'id':
          return element
                  .querySelector('.video-block > .infos')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector(' .video-block > .infos ')
                  ?.attributes['title'] ??
              '';
        case 'duration':
          return element
                  .querySelector('.video-block > .thumb > .duration')
                  ?.text
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
          return element.querySelectorAll(' .row > .col-xl-2');
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

  // dynamic getCategories(dynamic element, String propertyName) {
  //   if (element is html.Element) {
  //     switch (propertyName) {
  //       case 'image':
  //         return element.querySelector('.img > img')?.attributes['src'] ?? '';
  //       case 'id':
  //         return element.attributes['href'] ?? '';
  //       case 'title':
  //         return element.querySelector('.title')?.text ?? '';

  //       default:
  //         return '';
  //     }
  //   } else {
  //     switch (propertyName) {
  //       case 'selector':
  //         return element.querySelectorAll(
  //             '#list_categories_categories_list_items > .item');
  //       default:
  //         return '';
  //     }
  //   }
  // }
}
