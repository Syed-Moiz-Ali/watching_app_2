// ignore_for_file: file_names

class Avrebo {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        return element['thumb'] ?? '';

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
      case 'videoUrl':
        return element['video_url'] ?? '';

      case 'selector':
        return element['data']['list'];

      default:
        return '';
    }
  }
}
