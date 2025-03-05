// ignore_for_file: file_names

import 'dart:developer';

import 'package:html/dom.dart' as html;

class TubePornClassic {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector(' a > .thumb__img >  img')
                  ?.attributes['data-src0'] ??
              '';
        case 'id':
          return element.querySelector('a ')?.attributes['href'] ?? '';
        case 'title':
          return element
                  .querySelector('a > .thumb__img >  img')
                  ?.attributes['title'] ??
              '';
        case 'duration':
          return element
                  .querySelector('a > .thumb__img > .thumb__duration')
                  ?.text
                  .trim() ??
              '';
        case 'preview':
          return element
                  .querySelector('.box > a > .thumb-img >  img')
                  ?.attributes['data-preview'] ??
              '';
        case 'quality':
          return 'HD';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          log('selector is ${element.outerHtml}');
          return element.querySelectorAll(
              ' .content > .wrapper > .wrapper__block >.thumbs > .thumb');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      var links = element;

      // for (var element in links) {
      //   print('links is ${element.outerHtml}');
      // }

      Map params = {'auto': links.attributes['src']};
      watchingLink.addAll(params);

      switch (propertyName) {
        case 'watchingLink':
          return watchingLink;

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('#player-container');
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
