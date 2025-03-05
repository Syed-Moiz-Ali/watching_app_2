import 'dart:convert';
import 'dart:developer';

import 'package:html/dom.dart' as html;

class Manhwax {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.bsx >  a  > .limit >  img')
                  ?.attributes['src'] ??
              '';
        case 'id':
          return element.querySelector('.bsx >  a')?.attributes['href'] ?? '';
        case 'title':
          return element.querySelector('.bsx >  a')?.attributes['title'] ?? '';

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll(' .listupd > .bs');
        default:
          return '';
      }
    }
  }

  dynamic getDetail(dynamic element, String propertyName) {
    log('this getDtails');
    log('this ${(element) is (html.Element,)}');
    if (element is html.Element) {
      switch (propertyName) {
        case 'summary':
          log('this is summary');
          // Select all .wd-full elements
          final elements = element
              .querySelectorAll('.animefull > .bigcontent > .infox > .wd-full');
          // Get the last .wd-full element
          log('elements is $elements');
          final secondToLastIndex =
              elements.length >= 2 ? elements.length - 2 : null;
          final secondToLastElement =
              secondToLastIndex != null ? elements[secondToLastIndex] : null;
          if (secondToLastElement != null) {
            // Select all <p> tags within .entry-content
            final paragraphs =
                secondToLastElement.querySelectorAll('.entry-content > p');
            // Combine the text from all <p> tags
            final combinedText = paragraphs.map((p) => p.text).join(' ');
            return combinedText.isNotEmpty ? combinedText : 'empty';
          } else {
            return 'empty';
          }
        case 'chapterId':
          log('this is chapterId');
          final elements =
              element.querySelectorAll('.epcheck > .eplister ul > li');

          final lastElement = elements.isNotEmpty ? elements.first : null;
          return lastElement
                  ?.querySelector('.chbox > .eph-num > a')
                  ?.attributes['href']
                  ?.replaceAll("from", "replace") ??
              'empty';
        case 'chapterTitle':
          log('this is chapterTitle');
          final elements =
              element.querySelectorAll('.epcheck > .eplister ul > li');

          final lastElement = elements.isNotEmpty ? elements.first : null;
          return lastElement
                  ?.querySelector('.chbox > .eph-num > a > .chapternum')
                  ?.text
                  .replaceAll('Chapter ', '') ??
              'empty';
        // return
        // element
        //         .querySelector(
        //             '.epcheck > .eplister ul > li:first-of-type > .chbox > .eph-num > a > .chapternum')
        //         ?.text
        //         .replaceAll('Chapter ', '') ??
        //     'empty';
        default:
          return 'unknown property';
      }
    } else {
      log('element is not an html.Element');
      switch (propertyName) {
        case 'selector':
          log('this is selector ');
          return element
              .querySelectorAll('#content > .wrapper > .postbody > article');
        default:
          return '';
      }
    }
  }

  dynamic getChapter(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'chapterImage':
          // Find all <script> tags inside the #wrapper
          final scripts = element.querySelectorAll('script');
          for (var script in scripts) {
            final scriptContent = script.text;
            final startIndex = scriptContent.indexOf('/*<![CDATA[*/');
            final endIndex = scriptContent.indexOf('/*]]>*/');

            if (startIndex != -1 && endIndex != -1) {
              // Extract the JSON part
              final jsonContent = scriptContent
                  .substring(startIndex + 12, endIndex)
                  .trim()
                  .replaceAll('/ts_reader.run(', '')
                  .replaceAll(';', '')
                  .replaceAll(')', '');
              try {
                // Parse the JSON data
                final jsonData = json.decode(jsonContent);
                // Extract and return the list of image URLs
                final sources = jsonData['sources'] as List<dynamic>;
                final images = sources
                    .map((source) => source['images'] as List<dynamic>)
                    .expand((imageList) => imageList)
                    .toList();
                return images;
              } catch (e) {
                log('Error parsing JSON from script tag: $e');
                return [];
              }
            }
          }
          return [];

        default:
          return '';
      }
    } else {
      // if (element is html.Document) {
      //   log(element.querySelectorAll('#readerarea').first.outerHtml);
      // }
      switch (propertyName) {
        case 'selector':
          log('this is selector of getChapter');
          return element.querySelectorAll('#content > .wrapper');
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
