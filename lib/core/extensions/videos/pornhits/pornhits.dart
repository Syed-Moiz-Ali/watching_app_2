import 'dart:convert';
import 'dart:developer';

import 'package:html/dom.dart';

import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../services/scrapers/base_scraper.dart';

class PornHits extends BaseScraper {
  PornHits(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(customExtraction: (Element element) {
              var titleElement = element.querySelector('.item-info > a');
              var title = titleElement?.attributes['title'] ??
                  element
                      .querySelector('.item-info > a >  strong')
                      ?.text
                      .trim() ??
                  '';
              return Future.value(title);
            }),
            thumbnailSelector: ElementSelector(
              selector: 'a > .img > img',
              attribute: 'data-original', // Extract thumbnail from 'data-src'
            ),
            contentUrlSelector: ElementSelector(
              selector: 'a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            durationSelector: ElementSelector(
              selector: 'a > .img > .duration',
              // attribute: 'text', // Extract duration from text content
            ),
            viewsSelector: ElementSelector(
              selector: ' .item-info > .wrap > .views',
              // attribute: 'text', // Extract duration from text content
            ),
            previewSelector: ElementSelector(
              selector: 'a > .img > img',
              attribute:
                  'data-trailer_url', // Extract duration from text content
            ),
            watchingLinkSelector: ElementSelector(
              customExtraction: (element) {
                Map watchingLinks = {};
                if (source.name == 'porhits') {
                  log("this is videoLink and ${element.querySelector('.player-wrap')!.innerHtml.toString()}");
                  var links =
                      element.querySelectorAll('.info > .item:last-child > a');

                  for (var element in links) {
                    var parts = element.text.replaceAll('MP4', '').split(',');
                    if (parts.length > 1) {
                      parts.removeLast();
                    }
                    var key = parts.isNotEmpty ? parts.join(',') : '';

                    Map params = {
                      key.toString().trim():
                          element.attributes['href'].toString()
                    };
                    watchingLinks.addAll(params);
                  }
                } else {
                  var scriptTags = element.querySelectorAll('script');
                  for (var script in scriptTags) {
                    var content = script.text;
                    if (content.contains('var schemaJson =')) {
                      var jsonStr = content
                          .split('var schemaJson =')[1]
                          .split(';')[0]
                          .trim();

                      // Manually extract the JSON part before the `duration` function
                      // We will remove anything after the `"duration":` key
                      var jsonWithoutDuration =
                          jsonStr.split('"duration":')[0].trim();
                      if (!jsonWithoutDuration.startsWith('{')) {
                        jsonWithoutDuration = '{$jsonWithoutDuration';
                      }
                      if (!jsonWithoutDuration.endsWith('}')) {
                        jsonWithoutDuration = '$jsonWithoutDuration}';
                      }
                      jsonWithoutDuration =
                          jsonWithoutDuration.replaceAll(RegExp(r',\s*}'), '}');

                      log('jsonWithoutDuration is $jsonWithoutDuration');
                      // Now you can safely parse the JSON without the duration function
                      try {
                        var jsonData = json.decode(jsonWithoutDuration);
                        log("jsonData is $jsonData");
                        if (jsonData['embedUrl'] != null) {
                          watchingLinks['default'] = jsonData['embedUrl'];
                          break;
                        }
                      } catch (e) {
                        log('Error parsing JSON: $e');
                      }
                    }
                  }
                }
                // Return the encoded JSON string of watching links
                return Future.value(json.encode(watchingLinks));
              },
            ),
            keywordsSelector: ElementSelector(
              selector: 'meta[name="keywords"]',
              attribute: 'content', // Extract duration from text content
            ),
            contentSelector: ElementSelector(
                selector:
                    '.main-container > .box > .list-videos > .margin-fix > .item'),
            videoSelector: ElementSelector(selector: '.container'),
          ),
        );
}
