// ignore_for_file: file_names

class RedGifs {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        return element['urls']['poster'] ??
            element['urls']['thumbnail'] ??
            element['urls']['vthumbnail'];

      case 'id':
        return element['id'].toString();
      case 'title':
        return element['userName'].toString();
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';
      case 'videoUrl':
        return element['urls']['hd'] ?? element['urls']['sd'] ?? '';

      case 'selector':
        return element['gifs'];

      default:
        return '';
    }
  }
}
