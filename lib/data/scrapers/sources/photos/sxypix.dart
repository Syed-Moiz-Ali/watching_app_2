class Sxypix {
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
        return element['fileurl'] ??
            element['av1fileurl'] ??
            element['h265fileurl'];

      case 'selector':
        return element['data'];

      default:
        return '';
    }
  }
}
