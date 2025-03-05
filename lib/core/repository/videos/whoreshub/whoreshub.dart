// ignore_for_file: avoid_print

import 'package:html/dom.dart' as html;

class WhoreHub {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.box > a > .thumb-img >  img')
                  ?.attributes['data-src'] ??
              '';
        case 'id':
          return element.querySelector('.box > a ')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('.box > a')?.attributes['title'] ?? '';
        case 'duration':
          return element
                  .querySelector('.box > a > .thumb-img > .duration')
                  ?.text
                  .trim() ??
              '';
        case 'preview':
          return element
                  .querySelector('.box > a > .thumb-img >  img')
                  ?.attributes['data-preview'] ??
              '';
        case 'quality':
          return element.querySelector(
                      '.box > a > .thumb-img > .duration > .is-hd') !=
                  null
              ? element
                  .querySelector('.box > a > .thumb-img > .duration > .is-hd')!
                  .text
              : 'HD';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(
              '.content > .section > .container> .block-thumbs >.thumbs > .thumb');
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
      print('cdataScriptTag is $cdataScriptTag');

      // Extract data from the script tag
      Map<String, String> dataMap = extractDataFromScript(cdataScriptTag);

      // Print the extracted data map
      print(dataMap);
      Map params = {
        'auto': 'https://www.whoreshub.com/embed/${dataMap['video_id']}'
      };
      watchingLink.addEntries(params.entries);

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
          return element.querySelectorAll('main');
        case 'keywords':
          return element
              .querySelector('meta[name="keywords"]')
              ?.attributes['content'];
        default:
          return '';
      }
    }
  }

  Map<String, String> extractDataFromScript(html.Element scriptTag) {
    // Initialize an empty map to store the extracted data
    Map<String, String> dataMap = {};

    // Get the text content of the script tag
    String jsContent = scriptTag.text;

    // Define regular expressions to extract key-value pairs from the JavaScript content
    RegExp keyValuePairRegex = RegExp(r"(\w+): '([^']+)'");

    // Extract key-value pairs using regular expressions
    keyValuePairRegex.allMatches(jsContent).forEach((match) {
      // Extract key and value from each match
      String key = match.group(1)!;
      String value = match.group(2)!;

      // Add key-value pair to the data map
      dataMap[key] = value;
    });

    // Return the extracted data map
    return dataMap;
  }
}
