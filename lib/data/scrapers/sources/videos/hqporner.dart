import 'dart:convert';

import 'package:html/dom.dart';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class HQPorner extends BaseScraper {
  HQPorner(ContentSource source)
      : super(
          source,
          ScraperConfig(
              titleSelector: ElementSelector(
                selector: 'section > #span-case > .meta-data-title',
              ),
              thumbnailSelector: ElementSelector(
                  // selector: 'section > ',
                  // attribute: 'src', // Extract thumbnail from 'data-src'
                  customExtraction: (Element element) {
                var imageElement = element
                    .querySelector('section > a > div')!
                    .attributes['onmouseleave']!
                    .split(',')
                    .first
                    .replaceAll('defaultImage(', '')
                    .replaceAll('"', '');

                return Future.value(imageElement);
              }),
              contentUrlSelector: ElementSelector(
                selector: 'section > a',
                attribute: 'href', // Extract content URL from 'href' attribute
              ),
              qualitySelector: ElementSelector(
                selector:
                    '.inner-wrapper > .video-thumb > a > .video-time > .quality',
                // attribute: 'text', // Extract quality from text content
              ),
              timeSelector: ElementSelector(
                selector: 'a > .i_img >  .m_time',
                // attribute: 'text', // Extract time from text content
              ),
              durationSelector: ElementSelector(
                selector: 'section > #span-case > span',
                // attribute: 'text', // Extract duration from text content
              ),
              previewSelector: ElementSelector(
                selector: '',
                attribute:
                    'data-trailer_url', // Extract duration from text content
              ),
              watchingLinkSelector: ElementSelector(
                customExtraction: (element) {
                  Map watchingLinks = {};
                  var links = element.querySelector('script')?.text;
                  RegExp regExp = RegExp(r"url: '.*\?i=(//.*?/video/.*?)'");

                  // Find the first match in the script content
                  RegExpMatch? match = regExp.firstMatch(links!);
                  String? link = '';
                  if (match != null) {
                    link = 'https:${match.group(1)}';
                  } else {}
                  Map params = {'auto': link};
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
                  selector:
                      '.page-content > section > div > .row > [class="6u"]'),
              videoSelector: ElementSelector(
                  selector: '.page-content > section > div[class="12u"]'),
              similarContentSelector: ElementSelector(
                  selector:
                      'div[class="12u"] > section > div > .row >  [class="4u"]')),
        );
}
