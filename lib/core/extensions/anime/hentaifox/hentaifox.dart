import 'dart:developer';

import 'package:html/dom.dart' as html;

class Hentaifox {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.v_item >  .video_cover >  img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('.v_item >  .video_title ')?.text ?? '';

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element
              .querySelectorAll('.overview > .sub_overview > .a_item');
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
              .querySelector('.left > .video_tags > .video_description > p')
              ?.text;

        case 'chapterId':
          log('ths is ggg ${element.querySelector('.right > .more_from_series')?.outerHtml}');
          final elements =
              element.querySelectorAll('.right > .more_from_series >.mfs_item');

          final lastElement = elements.isNotEmpty ? elements.first : null;
          return lastElement
                  ?.querySelector('.infos > .title > a')
                  ?.attributes['href'] ??
              '';
        case 'chapterTitle':
          final elements =
              element.querySelectorAll('.right > .more_from_series >.mfs_item');

          final lastElement = elements.isNotEmpty ? elements.first : null;
          String text = lastElement
                  ?.querySelector('.infos > .title > a')
                  ?.text
                  .replaceAll('Chapter ', '')
                  .trim() ??
              '0';
          RegExp regExp = RegExp(r'\d+');
          Match? match = regExp.firstMatch(text);
          return match?.group(0) ?? '1';

        default:
          return 'unknown property';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.video');
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
