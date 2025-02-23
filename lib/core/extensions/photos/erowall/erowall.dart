import 'package:html/dom.dart' as html;

class EroWall {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
              .querySelector(' a > img')
              ?.attributes['src']
              .toString()
              .replaceAll('thumb', 'original');
        case 'id':
          return element.querySelector(' a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector(' a >  img')?.attributes['alt'] ?? '';
        case 'duration':
          return '';
        case 'preview':
          return '';
        case 'quality':
          return '';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          // log('this is selctor ${element.querySelectorAll('main > .main-container  > .models-items ').first.outerHtml}');
          return element.querySelectorAll('.wrapper > .content > .wpmini ');
        default:
          return '';
      }
    }
  }
}
