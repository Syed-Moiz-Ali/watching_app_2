// ignore_for_file: file_names

class PornPics {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        return element['t_url'] ?? '';

      case 'id':
        return element['gid'].toString();
      case 'title':
        return element['desc'].toString();
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';

      case 'selector':
        return element;

      default:
        return '';
    }
  }
}
