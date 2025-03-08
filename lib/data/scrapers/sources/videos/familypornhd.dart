// import 'dart:developer';

import 'package:html/dom.dart' as html;

class FamilyPornHd {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('article > .entry-featured-media  > a > img ')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element
                  .querySelector('article > .entry-featured-media  > a')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector('article > .entry-featured-media  > a')
                  ?.attributes['title'] ??
              '';
        case 'duration':
          return '';
        case 'preview':
          return '';
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
          return element.querySelectorAll(
              '.g1-collection-viewport > .g1-collection-items > .g1-collection-item');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      Map params = {};

      var links = element.querySelectorAll(' #link-tabs > li');
      for (var element in links) {
        var anchor = element.querySelector('a');
        if (anchor != null) {
          var href = anchor.attributes['href'];
          if (href != null && href.contains('filemoon')) {
            params = {'auto': href};
            break;
          } else {
            if (!watchingLink.containsKey('auto')) {
              params = {'auto': href ?? ''};
            }
          }
        }
      }
      // Map params = {'auto': element};
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
          // log('the selector is ${element.querySelectorAll('.link-tabs-container ')}');
          return element.querySelectorAll('.link-tabs-container ');
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
