import 'package:html/dom.dart' as html;

class Baddies {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.bx-item   >  a > div >  img')
                  ?.attributes['data-webp'] ??
              '';
        case 'id':
          return element
                  .querySelector('.bx-item   >  a ')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector('.bx-item   >  a > div >  img ')
                  ?.attributes['alt'] ??
              '';
        case 'duration':
          return element
                  .querySelector('.bx-item   >  a > div > .bx-item-duration')
                  ?.text
                  .trim() ??
              '';
        case 'preview':
          return element
                  .querySelector('.bx-item   >  a > div >  img')
                  ?.attributes['data-preview'] ??
              '';
        case 'quality':
          return 'HD';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(' .bx-list-items > .row > .col');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');

      List<html.Element> scriptTags = element.querySelectorAll('script');

      // Find the script tag containing '<![CDATA[' in its content
      html.Element? cdataScriptTag = scriptTags.firstWhere(
        (scriptTag) => scriptTag.text.contains('<![CDATA['),
        // orElse: () => null,
      );

      // Extract data from the script tag
      String? dataMap = extractDataFromScript(cdataScriptTag);

      // Print the extracted data map
      Map params = {'auto': 'https://baddies.xxx/embed/$dataMap'};
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
          return element
              .querySelectorAll('.bx-video > .player > .player-holder');
        case 'keywords':
          return element
              .querySelector('meta[name="keywords"]')
              ?.attributes['content'];
        default:
          return '';
      }
    }
  }

  String? extractDataFromScript(html.Element scriptTag) {
    // Initialize an empty map to store the extracted data

    // Get the text content of the script tag
    String jsContent = scriptTag.text;

    // Define regular expressions to extract key-value pairs from the JavaScript content
    RegExp videoUrlRegex = RegExp(r"video_id: '([^']+)'");

    // Find the first match for video_url
    RegExpMatch? match = videoUrlRegex.firstMatch(jsContent);

    // Return the video_url if found, otherwise return null
    if (match != null) {
      return match.group(1)!.replaceAll('function/0/', '');
    } else {
      return null;
    }
  }
}
