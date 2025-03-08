// ignore_for_file: file_names

import 'package:html/dom.dart' as html;

class NSFWSwipe {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element.querySelector('div > video')?.attributes['poster'] ??
              '';
        case 'id':
          return '';
        case 'title':
          return element
                  .querySelector('div > .mute ')
                  ?.attributes['title']!
                  .replaceAll("Unmute", '') ??
              '';
        case 'duration':
          return '';
        case 'preview':
          return '';
        case 'quality':
          return 'HD';
        case 'time':
          return '';
        case 'videoUrl':
          return element.querySelector('div > video')?.attributes['data-hls'] ??
              '';
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(
              '.slick-list > .slick-track > div.slide.slick-slide[tabindex="-1"]');
        default:
          return '';
      }
    }
  }
}
