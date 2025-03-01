// ignore_for_file: file_names

import 'dart:convert';

import 'package:html/dom.dart';

import '../../../../models/content_source.dart';
import '../../../../models/scraper_config.dart';
import '../../../../services/scrapers/base_scraper.dart';

class GoodPorn extends BaseScraper {
  GoodPorn(ContentSource source)
      : super(
          source,
          ScraperConfig(
              titleSelector: ElementSelector(
                selector: 'a',
                attribute: 'title', // Extract title from 'title' attribute
              ),
              thumbnailSelector: ElementSelector(
                selector: 'a > .img > img',
                attribute: 'data-original', // Extract thumbnail from 'data-src'
              ),
              contentUrlSelector: ElementSelector(
                selector: 'a',
                attribute: 'href', // Extract content URL from 'href' attribute
              ),
              qualitySelector: ElementSelector(
                selector: '.is-hd',
                // attribute: 'text', // Extract quality from text content
              ),
              timeSelector: ElementSelector(
                selector: 'a > .wrap >.duration',
                // attribute: 'text', // Extract time from text content
              ),
              durationSelector: ElementSelector(
                selector: 'a > .wrap >.duration',
                // attribute: 'text', // Extract duration from text content
              ),
              previewSelector: ElementSelector(
                selector: 'a > .img > img',
                attribute: 'data-preview', // Extract duration from text content
              ),
              watchingLinkSelector: ElementSelector(
                customExtraction: (element) {
                  Map watchingLinks = {};
                  var links = element.querySelector(
                      '.video-holder > .player > .player-holder');

                  List<Element> scriptTags = links!.querySelectorAll('script');

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
                  var newMatch = match?.group(1)!.replaceAll('function/0/', '');

                  Map params = {'auto': '${source.url}/embed/$newMatch'};
                  watchingLinks.addEntries(params.entries);

                  // Return the encoded JSON string of watching links
                  return Future.value(json.encode(watchingLinks));
                },
              ),
              keywordsSelector: ElementSelector(
                selector: 'meta[name="keywords"]',
                attribute: 'content', // Extract duration from text content
              ),
              contentSelector: ElementSelector(
                  selector: '.box > .list-videos > .margin-fix > .item'),
              videoSelector: ElementSelector(selector: '.content'),
              similarContentSelector: ElementSelector(
                  selector:
                      '.related-videos > .box > .list-videos > .margin-fix > .item ')),
        );
}
