// ignore_for_file: file_names

import 'package:html/dom.dart' as html;

class Categorie {
  dynamic getCategories(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector(
                      'div > a > .b-thumb-item__img > picture >  img ')
                  ?.attributes['data-src'] ??
              '';
        case 'id':
          return element.querySelector('div > a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('div > a')?.attributes['title'] ?? '';

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
}
