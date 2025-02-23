import 'package:html/dom.dart' as html;

class Manhwa18 {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.bsx >  .thumb > a   >  img')
                  ?.attributes['data-src'] ??
              '';
        case 'id':
          return element
                  .querySelector('.bsx >  .thumb > a')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector('.bsx >  .thumb > a')
                  ?.attributes['title'] ??
              '';

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.manga-lists > .manga-item');
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
              .querySelector('meta[name="description"]')
              ?.attributes['content'];

        case 'chapterId':
          final elements = element.querySelectorAll(
              '.content-manga-left > .panel-manga-chapter > .row-content-chapter > li');

          final lastElement = elements.isNotEmpty ? elements.first : null;
          return lastElement?.querySelector('a')?.attributes['href'] ?? '0';
        case 'chapterTitle':
          final elements = element.querySelectorAll(
              '.panel-manga-chapter > .row-content-chapter > li');

          final lastElement = elements.isNotEmpty ? elements.first : null;
          return lastElement
                  ?.querySelector('a')
                  ?.text
                  .replaceAll('Chapter ', '')
                  .trim() ??
              '0';

        default:
          return 'unknown property';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('html');
        default:
          return '';
      }
    }
  }

  dynamic getChapter(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'chapterImage':
          return element.attributes['data-src'];

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.read-manga > .read-content img');
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
