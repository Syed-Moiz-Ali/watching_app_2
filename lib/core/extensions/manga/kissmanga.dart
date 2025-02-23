import 'package:html/dom.dart' as html;

class Kissmanga {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.col-md-2 > .c-image-hover > a >  img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element
                  .querySelector('.col-md-2 > .c-image-hover > a')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector('.col-md-2 > .c-image-hover > a')
                  ?.attributes['title'] ??
              '';

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(
              '.c-page__content > .tab-content-wrap > .c-tabs-item');
        default:
          return '';
      }
    }
  }

  dynamic getDetail(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'summary':
          return element
                  .querySelector(
                      '.c-page > .c-page__content > .description-summary >  .summary__content > p')
                  ?.text ??
              '';
        case 'chapterId':
          return element
                  .querySelector(
                      '.c-page > .c-page__content >.col-md-2 > .page-content-listing > .listing-chapters_wrap > ul > li > a')
                  ?.attributes['href'] ??
              '';
        case 'chapterTitle':
          return element
                  .querySelector(
                      '.c-page > .c-page__content >.col-md-2 > .page-content-listing > .listing-chapters_wrap > ul > li > a')
                  ?.text ??
              '';

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.main-col-inner');
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
