// ignore_for_file: file_names

import 'package:html/dom.dart' as html;

class FikFap {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        return element['thumbnailStreamUrl'] ?? '';

      case 'id':
        return element['postId'].toString();
      case 'title':
        return element['label'].toString();
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';
      case 'videoUrl':
        return element['videoStreamUrl'] ?? '';

      case 'selector':
        return element;

      default:
        return '';
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      var links = element.querySelectorAll('.info > .item:last-child > a');

      for (var element in links) {
        var parts = element.text.replaceAll('MP4', '').split(',');
        if (parts.length > 1) {
          parts.removeLast();
        }
        var key = parts.isNotEmpty ? parts.join(',') : '';

        Map params = {
          key.toString().trim(): element.attributes['href'].toString()
        };
        watchingLink.addAll(params);
      }

      switch (propertyName) {
        case 'watchingLink':
          return watchingLink;

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.block-video');
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
