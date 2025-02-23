import 'package:html/dom.dart' as html;

class CollectionOfBestPorn {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector(
                      '.inner-wrapper > .video-thumb > a > .image > img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element
                  .querySelector('.inner-wrapper > .video-thumb > a')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector(
                      '.inner-wrapper > .video-thumb > a > .image > img')
                  ?.attributes['title'] ??
              '';
        case 'duration':
          return element
                  .querySelector(
                      '.inner-wrapper > .video-thumb > a > .video-time > .time')
                  ?.text ??
              '';
        case 'preview':
          return '';
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
          return element.querySelectorAll('.video-list > .video-item');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      var links = element.querySelectorAll('div > video > source ');

      for (var element in links) {
        var key = '${element.attributes['res']}p';

        Map params = {
          key.toString().trim(): element.attributes['src'].toString()
        };
        watchingLink.addAll(params);
      }

      switch (propertyName) {
        case 'watchingLink':
          return watchingLink;

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.main-video');
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
