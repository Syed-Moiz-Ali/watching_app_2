import 'package:html/dom.dart' as html;

// import '../../helper/get_from_element.dart';

class Kompoz2 {
  dynamic getProperty(dynamic element, String propertyName) {
    // print('propertyName is $propertyName');
    // print('element is $element');
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.preview-ins > a > .preview-img  > img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element
                  .querySelector('.preview-ins > a')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector('.preview-ins > a > .preview-img  > img')
                  ?.attributes['alt'] ??
              '';
        case 'duration':
          return element
                  .querySelector('.preview-ins >  .meta-dur-date  > ul')
                  ?.text ??
              '';
        case 'preview':
          return '';
        case 'quality':
          return element.querySelector('.is-hd') != null
              ? element.querySelector('.is-hd')!.text
              : 'HD';
        case 'time':
          return element
                  .querySelector('.preview-ins > .meta-like-views > ul')
                  ?.text ??
              '';
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.previews-block> .preview');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      var links = element.querySelector('video > source')?.attributes['src'];

      Map params = {'auto': links};
      watchingLink.addEntries(params.entries);

      switch (propertyName) {
        case 'watchingLink':
          return watchingLink;

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.mediabox');
        case 'keywords':
          return element
              .querySelector('meta[name="keywords"]')
              ?.attributes['content'];
        case 'metaVideoUrl':
          var links = element
              .querySelector('meta[property="og:video:url"]')
              ?.attributes['content'];
          Map params = {'auto': links};

          return params;
        default:
          return '';
      }
    }
  }
}
