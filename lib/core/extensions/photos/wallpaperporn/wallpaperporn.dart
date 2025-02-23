import 'package:html/dom.dart' as html;

class WallpaperPorn {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
              .querySelector(' a > img')
              ?.attributes['src']
              .toString()
              .replaceAll('thumbnail/md', '1920x1080')
              .replaceAll('thumbnail/lg', '1920x1080');
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
          return element.querySelectorAll('.row > .col-sm-6  ');
        default:
          return '';
      }
    }
  }
}
