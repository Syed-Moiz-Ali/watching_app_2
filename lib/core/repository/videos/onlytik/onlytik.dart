// ignore_for_file: file_names

class Onlytik {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        return element['poster_url'] ?? element['thumbnail_url'];

      case 'id':
        return element['video_id'].toString();
      case 'title':
        return element['username'].toString();
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';
      case 'videoUrl':
        return element['url'];

      case 'selector':
        return element['data'];

      default:
        return '';
    }
  }
}
