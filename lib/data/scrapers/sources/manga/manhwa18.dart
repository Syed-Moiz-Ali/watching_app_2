import 'dart:convert';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Manwha18 extends BaseScraper {
  Manwha18(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: '.bsx >  .thumb > a',
              attribute: 'title', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              selector: ".bsx >  .thumb > a   >  img",
              attribute: "data-src",
            ),
            contentUrlSelector: ElementSelector(
              selector: '.bsx >  .thumb > a',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            contentSelector: ElementSelector(
              selector: '.manga-lists > .manga-item',
            ),
            detailSelector: ElementSelector(selector: 'html'),
            discriptionSelector: ElementSelector(
                selector: 'meta[name="description"]', attribute: "content"),
            chapterIdSelector: ElementSelector(
              customExtraction: (element) {
                final elements = element.querySelectorAll(
                    '.content-manga-left > .panel-manga-chapter > .row-content-chapter > li');

                final lastElement = elements.isNotEmpty ? elements.first : null;
                return Future.value(
                    lastElement?.querySelector('a')?.attributes['href'] ?? '0');
              },
            ),
            chapterCountSelector: ElementSelector(
              customExtraction: (element) {
                final elements = element.querySelectorAll(
                    '.content-manga-left > .panel-manga-chapter > .row-content-chapter > li');

                final lastElement = elements.isNotEmpty ? elements.first : null;
                return Future.value(
                    lastElement?.querySelector('a')?.text ?? '0');
              },
            ),
            statusSelector: ElementSelector(
                customExtraction: (element) {
                  var items = element
                      .querySelectorAll('.post-status > .post-content_item');
                  if (items.isNotEmpty) {
                    return Future.value(items.last
                        .querySelector('.summary-content')!
                        .text); // Select last child manually
                  } else {
                    return Future.value('');
                  }
                },
                selector:
                    '.post-status > .post-content_item:last-child > .summary-content '),
            genreSelector: ElementSelector(customExtraction: (element) {
              var items = element
                  .querySelectorAll('.post-content > .post-content_item');
              if (items.length >= 2) {
                var genres = items[items.length - 2]
                    .querySelectorAll('.summary-content > .genres-content > a');
                return Future.value(
                    genres.map((e) => e.text.trim()).join(', '));
              }
              return Future.value('');
            }),
            chapterDataSelector:
                ElementSelector(selector: '.read-manga > .read-content'),
            chapterImageSelector: ElementSelector(
                customExtraction: (element) {
                  List imageList = [];
                  var images = element.querySelectorAll('img');
                  for (var image in images) {
                    imageList.add({
                      'image': image.attributes['data-src'],
                      "isReaded": false
                    });
                  }
                  return Future.value(json.encode(imageList));
                },
                selector: 'img',
                attribute: 'data-src'),

            // similarContentSelector: ElementSelector(
            //   selector: '.user_uploads > .video-list > .video-item',
            // ),
          ),
        );
}
