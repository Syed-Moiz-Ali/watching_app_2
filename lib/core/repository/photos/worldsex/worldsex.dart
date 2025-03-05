import 'package:html/dom.dart' as html;

class WorldSex {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':

          // log('image is $imageUrl');
          return element.querySelector(' a > img')?.attributes['src'];
        case 'id':
          return element.querySelector('a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector(' a  > img')?.attributes['title'] ?? '';
        case 'duration':
          return "";
        case 'preview':
          return '';
        case 'quality':
          return "";
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(
              '#pictures  > .pictures-page  > .picture-itemnew ');
        default:
          return '';
      }
    }
  }
}
