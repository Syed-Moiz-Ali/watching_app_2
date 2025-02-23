import 'dart:developer';

import 'package:html/dom.dart' as html;

class DefineBabe {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element.querySelector(' a > img')?.attributes['src'];
        case 'id':
          return element.querySelector(' a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector(' a >  img')?.attributes['alt'] ?? '';
        case 'duration':
          return '';
        case 'preview':
          return '';
        case 'quality':
          return '';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          // log('this is selctor ${element.querySelectorAll('main > .main-container  > .models-items ').first.outerHtml}');
          return element.querySelectorAll(
              'main > .main-container  > section > .models-items > .models-items__col');
        default:
          return '';
      }
    }
  }
}

class DefineBabeVideo {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element.querySelector(' a > img')?.attributes['src'];
        case 'id':
          return element.querySelector(' a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector(' .models-footer >  .mb-1')?.text ?? '';
        case 'duration':
          return element
                  .querySelector(
                      ' .models-footer >  .d-flex > .d-flex > .video')
                  ?.nodes
                  .where((node) => node.nodeType == html.Node.TEXT_NODE)
                  .map((node) => node.text!.trim())
                  .join(' ')
                  .trim() ??
              '';
        case 'preview':
          var preview =
              'https://pv.definebabe.com/${element.querySelector(' a > .thumb-video-info')?.attributes['data-mediabook']}_pv.mp4';
          return preview;
        case 'quality':
          return '';
        case 'time':
          return "";
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          // log('this is selctor ${element.querySelectorAll('main > .main-container  > .models-items ').first.outerHtml}');
          return element.querySelectorAll(
              'main > .main-container  > section > .models-videos > .models-videos__col');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map watchingLink = {};
      // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');
      var links = extractVideoUrlOrAltUrlFromScript(element);

      Map params = {'auto': links};
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

  dynamic extractVideoUrlOrAltUrlFromScript(html.Element element) {
    // Get all script tags
    final scriptTags = element.getElementsByTagName('script');

    // Iterate over all script tags
    for (var script in scriptTags) {
      final scriptContent = script.innerHtml;

      // Check if the script contains 'flashvars' (as per your script structure)
      if (scriptContent.contains('flashvars')) {
        log('scriptContent is $scriptContent');
        // Define regex patterns to capture 'video_url' and 'video_alt_url'
        final videoUrlPattern =
            RegExp(r"video_url\s*:\s*'(.*?)'", dotAll: true);
        final videoAltUrlPattern =
            RegExp(r"video_alt_url\s*:\s*'(.*?)'", dotAll: true);

        // Try to extract video_url
        final videoUrlMatch = videoUrlPattern.firstMatch(scriptContent);
        if (videoUrlMatch != null) {
          final videoUrl = videoUrlMatch.group(1);
          log('videoUrl is $videoUrl');
          return videoUrl; // Return video_url if found
        }

        // If video_url is not found, try to extract video_alt_url
        final videoAltUrlMatch = videoAltUrlPattern.firstMatch(scriptContent);
        if (videoAltUrlMatch != null) {
          final videoAltUrl = videoAltUrlMatch.group(1);
          return videoAltUrl; // Return video_alt_url if video_url is not found
        }
      }
    }

    // If neither video_url nor video_alt_url is found, return null or handle accordingly
    return null;
  }
}
