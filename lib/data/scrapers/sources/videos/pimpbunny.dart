import 'package:html/dom.dart';

import 'dart:convert';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class PimpBunny extends BaseScraper {
  PimpBunny(ContentSource source)
      : super(
          source,
          ScraperConfig(
              titleSelector: ElementSelector(
                  selector: '.pb-item   >  a > div >  img  ', attribute: 'alt'),
              thumbnailSelector: ElementSelector(
                  selector: '.pb-item   >  a > div >  img',
                  attribute: 'data-webp'),
              contentUrlSelector: ElementSelector(
                selector: '.pb-item   >  a  ',
                attribute: 'href', // Extract content URL from 'href' attribute
              ),
              durationSelector: ElementSelector(
                selector: '.pb-item   >  a > div > .pb-item-duration',
                // attribute: 'text', // Extract duration from text content
              ),
              previewSelector: ElementSelector(
                selector: '.pb-item   >  a > div >  img',
                attribute: 'data-preview', // Extract duration from text content
              ),
              watchingLinkSelector: ElementSelector(
                customExtraction: (element) {
                  Map watchingLinks = {};
                  // log('the link of this is ${element.querySelector('#video_html5_api')!.outerHtml}');

                  List<Element> scriptTags = element.querySelectorAll('script');

                  // Find the script tag containing '<![CDATA[' in its content
                  Element? cdataScriptTag = scriptTags.firstWhere(
                    (scriptTag) => scriptTag.text.contains('<![CDATA['),
                    // orElse: () => null,
                  );
                  String jsContent = cdataScriptTag.text;

                  // Define regular expressions to extract key-value pairs from the JavaScript content
                  RegExp videoUrlRegex = RegExp(r"video_id: '([^']+)'");

                  // Find the first match for video_url
                  RegExpMatch? match = videoUrlRegex.firstMatch(jsContent);

                  // Return the video_url if found, otherwise return null
                  if (match != null) {
                    var dataMap = match.group(1)!.replaceAll('function/0/', '');
                    Map params = {
                      'auto': 'https://pimpbunny.com/embed/$dataMap'
                    };
                    watchingLinks.addEntries(params.entries);
                  } else {}
                  // Return the encoded JSON string of watching links
                  return Future.value(json.encode(watchingLinks));
                },
              ),
              keywordsSelector: ElementSelector(
                selector: 'meta[name="keywords"]',
                attribute: 'content', // Extract duration from text content
              ),
              contentSelector:
                  ElementSelector(selector: '.pb-list-items > .row > .col'),
              videoSelector: ElementSelector(
                  selector: '.pb-video > .player > .player-holder'),
              similarContentSelector: ElementSelector(
                  selector:
                      '.pb-list-videos > #list_videos_similar_videos > .box > #list_videos_similar_videos_items > .row > .col')),
        );
}
