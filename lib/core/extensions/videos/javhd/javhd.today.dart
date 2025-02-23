// import '../../helper/get_from_element.dart';
import 'package:html/dom.dart' as html;

class Javhd {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.video > a > .video-thumb >  img  ')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element.querySelector('.video > a')?.attributes['href'] ?? '';
        case 'title':
          return element
                  .querySelector('.video > a > .video-thumb >  img  ')
                  ?.attributes['alt'] ??
              '';
        case 'duration':
          return '';
        case 'preview':
          return '';
        case 'quality':
          return 'HD';
        case 'time':
          return '';
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(' .videos > li');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};

      var links =
          element.querySelectorAll(' .button_style > .button_choice_server');
      var link = links.firstWhere(
        (element) => element.attributes['onclick']!.contains('streamwish'),
        orElse: () => links.first,
      );
      Map params = {
        'auto': link.attributes['onclick']!
            .replaceAll("playEmbed('", '')
            .replaceAll("')", '')
      };
      watchingLink.addEntries(params.entries);

      switch (propertyName) {
        case 'watchingLink':
          return watchingLink;

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('#video');
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
