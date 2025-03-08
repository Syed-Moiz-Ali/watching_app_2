// ignore_for_file: file_names

class TikPorn {
  dynamic getProperty(dynamic element, String propertyName) {
    switch (propertyName) {
      case 'image':
        return element['poster_url'] ?? element['thumbnail_url'];

      case 'id':
        return element['video_id'].toString();
      case 'title':
        return element['video_text']['meta_title']['default']['text']
            .toString();
      case 'duration':
        return '';
      case 'preview':
        return '';
      case 'quality':
        return 'HD';
      case 'videoUrl':
        return element['mp4_url'] ??
            element['hls_url'] ??
            element['download_url'];

      case 'selector':
        return element['data'];

      default:
        return '';
    }
  }
}
