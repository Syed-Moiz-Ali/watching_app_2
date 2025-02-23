// ignore_for_file: file_names

import 'package:html/dom.dart' as html;

class DbNaked {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        String imageUrl = getPrioritizedUrl(element['thumbs']);
        return imageUrl;

      case 'id':
        return element['id'].toString();
      case 'title':
        return element['title'].toString();
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';

      case 'selector':
        return element['scenes'];

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

  String getPrioritizedUrl(Map<String, dynamic> thumbs) {
    if (thumbs['lg'] != null) {
      return thumbs['lg'];
    }

    List<String> otherKeys = ['md', 'sm', 'xs', 'w300', 'h205', 'xxl'];
    for (String key in otherKeys) {
      if (thumbs[key] != null) {
        return thumbs[key];
      }
    }

    return 'default_image_url'; // Replace with your default URL
  }
}
