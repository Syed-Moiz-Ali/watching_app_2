// ignore_for_file: file_names

class Fiqfuq {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        return element['image_url'] ??
            element['image_original'] ??
            element['video_orignal'] ??
            '';

      case 'id':
        return element['id'].toString();
      case 'title':
        return element['description'].toString();
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';
      case 'videoUrl':
        return element['image_url'] ??
            element['image_original'] ??
            element['video_orignal'] ??
            '';

      case 'selector':
        return element['data'];

      default:
        return '';
    }
  }
}
