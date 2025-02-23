import 'package:html/dom.dart' as html;

class XPictures {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('a > picture > img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element.attributes['href'] ?? '';
        case 'title':
          return element
                  .querySelector('a > picture > img')
                  ?.attributes['alt'] ??
              '';
        case 'duration':
          return "";
        case 'preview':
          return '';
        case 'quality':
          return "";
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element
              .querySelectorAll('.container-fluid > div > .grid  > a');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
      var links = element
          .querySelector('.responsive-player > iframe')
          ?.attributes['src'];
      Map params = {'auto': links};
      watchingLink.addEntries(params.entries);

      // final streamDataJson = match.group(1)?.replaceAll("'", '"') ?? '';
      // final streamUrls = Map<String, dynamic>.from(streamDataJson);
      // final keywords = match2!.group(1) ?? '';
      switch (propertyName) {
        case 'watchingLink':

          // return Episode(streamUrls: streamUrls, keywords: keywords);

          return watchingLink;
        // case 'keywords':
        //   return keywords;
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('#main');
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
