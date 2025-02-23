import 'package:html/dom.dart' as html;

class InterntChicks {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('header > a > img ')
                  ?.attributes['data-src'] ??
              '';
        case 'id':
          return element.querySelector('header > a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('header > .entry-title > a ')?.text ??
              '';
        case 'duration':
          return '';
        case 'preview':
          return '';
        case 'quality':
          return 'HD';
        case 'time':
          return element
              .querySelector('header > .entry-meta > .entry-time')
              ?.text
              .trim();
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('#genesis-content >  article');
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
        (element) => element.attributes['onclick']!.contains('filemoon'),
        orElse: () => links.first,
      );
      Map params = {
        'auto': link.attributes['onclick']!
            .replaceAll("playEmbed('", '')
            .replaceAll("'); hideVideoCover();", '')
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
          return element.querySelectorAll('#genesis-content ');
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
