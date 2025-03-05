import 'dart:developer';

import 'package:html/dom.dart' as html;

class NetflixMirror {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element.querySelector('  a   >  img')?.attributes['src'] ?? '';
        case 'id':
          return element.querySelector('a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('a')?.attributes['title'] ?? '';

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(
              ' .panel-content-genres > .content-genres-item');
        default:
          return '';
      }
    }
  }

  dynamic getDetail(dynamic element, String propertyName) {
    log('this getDtails');
    log('this ${(element) is (html.Element,)}');
    if (element is html.Element) {
      switch (propertyName) {
        case 'summary':
          log('this is summary');
          final elements = element
              .querySelector(
                  ' .panel-story-info > .panel-story-info-description')!
              .text;
          log('elements is $elements');

          return elements;
        case 'chapterId':
          log('this is chapterId');
          final elements = element.querySelectorAll(
              '.panel-story-chapter-list > .row-content-chapter > li');
          final lastElement = elements.isNotEmpty ? elements.first : null;
          log('elements is ${lastElement?.querySelector('a')?.attributes['href']}');
          return lastElement?.querySelector('a')?.attributes['href'] ?? 'empty';
        case 'chapterTitle':
          log('this is chapterTitle');
          final elements = element.querySelectorAll(
              '.panel-story-chapter-list > .row-content-chapter > li');
          final lastElement = elements.isNotEmpty ? elements.first : null;
          log('the last ID is ${lastElement?.attributes['id']!.replaceAll(RegExp(r'(\d+(\.\d+)?)'), '').replaceAll('num', '').replaceAll('-', '').replaceAll('num-', '')}');
          return lastElement?.attributes['id']!
                  .replaceAll('num', '')
                  .replaceAll('-', '')
                  .replaceAll('num-', '') ??
              '0';
        default:
          return 'unknown property';
      }
    } else {
      log('element is not an html.Element');
      switch (propertyName) {
        case 'selector':
          log('this is selector ');
          return element.querySelectorAll('.container-main-left ');
        default:
          return '';
      }
    }
  }

  dynamic getChapter(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'chapterImage':
          final imgs =
              element.querySelectorAll('.container-chapter-reader > img');
          var images = [];

          for (var img in imgs) {
            images.add(img.attributes['src']);
          }
          return images;

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          log('this is selector of getChapter');
          return element.querySelectorAll('.body-site');
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
