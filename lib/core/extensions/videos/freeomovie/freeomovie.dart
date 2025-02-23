// import 'dart:developer';

import 'dart:developer';

import 'package:html/dom.dart' as html;

class FreeoMovie {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element.querySelector('a > img ')?.attributes['data-src'] ??
              '';
        case 'id':
          return element.querySelector(' a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('a > img')?.attributes['alt'] ?? '';
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
          return element.querySelectorAll('.Thumbnail_List > .thumi');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      Map params = {};
      int sourceCount = 1; // To keep track of the source number

      var links = element.querySelectorAll('#link-tabs > li');
      for (var element in links) {
        log("element is ${links.map((e) => e.innerHtml)}");
        var anchor = element.querySelector('a');
        if (anchor != null) {
          var href = anchor.attributes['href'];
          if (href != null && href.contains('filemoon')) {
            params = {'auto': href}; // First one will always be 'auto'
            break; // Break once we find the first 'filemoon' link
          } else {
            // For other links, start assigning 'source1', 'source2', etc.
            String sourceKey = 'source$sourceCount';
            params[sourceKey] =
                href ?? ''; // Store the href under the source key
            sourceCount++; // Increment the source count for the next iteration
          }
        }
      }

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
