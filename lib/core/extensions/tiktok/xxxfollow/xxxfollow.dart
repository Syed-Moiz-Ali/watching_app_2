// ignore_for_file: file_names

class XXXFollow {
  dynamic getProperty(dynamic element, String propertyName) {
    // log('element is ${element["post"]}');
    switch (propertyName) {
      case 'image':
        if (element['post'] != null) {
          return element['post']['media'][0]['thumb_url'] ??
              element['post']['media'][0]['thumb_webp_url'];
        } else {
          return '';
        }
      case 'id':
        if (element['post'] != null) {
          return element['post']['id'].toString();
        } else {
          return '';
        }
      case 'title':
        if (element['post'] != null) {
          return element['post']['text'] ?? element['post']['slug'];
        } else {
          '';
        }
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';
      case 'videoUrl':
        if (element['post'] != null) {
          return element['post']['media'][0]['url'] ??
              element['post']['media'][0]['sb_url'] ??
              '';
        } else {
          return '';
        }

      case 'selector':
        return element['list'];

      default:
        return '';
    }
  }
}
