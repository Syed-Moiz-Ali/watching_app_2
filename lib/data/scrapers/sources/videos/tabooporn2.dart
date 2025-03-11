import 'dart:convert';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class Tabooporn2 extends BaseScraper {
  Tabooporn2(ContentSource source)
      : super(
          source,
          ScraperConfig(
              titleSelector: ElementSelector(
                selector: 'article > div > a',
                attribute: 'title', // Extract title from 'title' attribute
              ),
              thumbnailSelector: ElementSelector(
                  // customExtraction: (element) {
                  //   var srcset = element
                  //       .querySelector(
                  //           'article > div > a > .g1-frame-inner > img')
                  //       ?.attributes['srcset'];
                  //   var imageUrl = '';
                  //   if (srcset != null) {
                  //     // Split the srcset attribute by comma to get individual sources
                  //     var sources = srcset.split(', ');
                  //     if (sources.isNotEmpty) {
                  //       // Get the first source
                  //       var firstSource = sources.first;
                  //       // Split the first source by space to get the URL and size
                  //       var parts = firstSource.split(' ');
                  //       if (parts.length >= 2) {
                  //         // The URL is the first part
                  //         imageUrl = parts[0];
                  //       }
                  //     }
                  //   } else {
                  //     imageUrl = element
                  //             .querySelector(
                  //                 'article > div > a > .g1-frame-inner > img')
                  //             ?.attributes['data-src'] ??
                  //         '';
                  //   }
                  //   // log('image is $imageUrl');
                  //   return Future.value(imageUrl.trim());
                  // },
                  ),
              contentUrlSelector: ElementSelector(
                selector: 'article > div > a ',
                attribute: 'href', // Extract content URL from 'href' attribute
              ),
              qualitySelector: ElementSelector(
                selector: 'a > .i_img >.hd_mark',
                // attribute: 'text', // Extract quality from text content
              ),
              timeSelector: ElementSelector(
                selector: 'a > .i_img >  .m_time',
                // attribute: 'text', // Extract time from text content
              ),
              durationSelector: ElementSelector(
                selector: 'a > .i_img >  .m_time',
                // attribute: 'text', // Extract duration from text content
              ),
              previewSelector: ElementSelector(
                selector: 'a > .i_img',
                attribute:
                    'data-trailer_url', // Extract duration from text content
              ),
              // watchingLinkSelector: ElementSelector(
              //   customExtraction: (element) {
              //     Map watchingLinks = {};
              //     var links = element
              //         .querySelector('video > source')
              //         ?.attributes['src'];
              //     Map params = {'auto': links};
              //     watchingLinks.addEntries(params.entries);
              //     // Return the encoded JSON string of watching links
              //     return Future.value(json.encode(watchingLinks));
              //   },
              // ),
              keywordsSelector: ElementSelector(
                selector: 'meta[name="keywords"]',
                attribute: 'content', // Extract duration from text content
              ),
              contentSelector: ElementSelector(
                  selector: '.g1-collection-items > .g1-collection-item'),
              videoSelector: ElementSelector(selector: '.g1-content-narrow'),
              similarContentSelector: ElementSelector(
                  selector:
                      '.g1-more-from > .g1-collection > .g1-collection-viewport > .g1-collection-item')),
        );
}
