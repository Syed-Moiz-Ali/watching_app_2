import 'dart:convert';
import 'dart:developer';

import '../../../models/content_source.dart';
import '../../../models/scraper_config.dart';
import '../../base_scraper.dart';

class SxyPrn extends BaseScraper {
  SxyPrn(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(
              selector: '.js-pop',
              attribute: 'aria-label', // Extract title from 'title' attribute
            ),
            thumbnailSelector: ElementSelector(
              selector: '.js-pop > .vid_container >   .post_vid_thumb > img',
              attribute: 'data-src', // Extract thumbnail from 'data-src'
            ),
            contentUrlSelector: ElementSelector(
              selector: '.js-pop',
              attribute: 'href', // Extract content URL from 'href' attribute
            ),
            qualitySelector: ElementSelector(
              selector:
                  '.js-pop  > .vid_container >   .post_vid_thumb > .shd_small',
            ),
            timeSelector: ElementSelector(
              selector: '.post_control >.post_time > .post_control_time',
            ),
            durationSelector: ElementSelector(
              selector:
                  '.js-pop  > .vid_container >   .post_vid_thumb >.duration_small',
            ),
            previewSelector: ElementSelector(
              selector:
                  '.js-pop  > .vid_container >   .post_vid_thumb >  video',
              attribute: 'src',
            ),
            // watchingLinkSelector: ElementSelector(
            //     customExtraction: (element) {
            //       Map watchingLink = {};
            //       var scripts = element
            //           .querySelectorAll('#vid_container_id')
            //           .first
            //           .outerHtml;
            //       log('scripts is $scripts');
            //       // watchingLink.addEntries(params.entries);
            //       return Future.value(json.encode(watchingLink));
            //     },
            //     // selector:
            //     //     '#vid_container_id > .yps_player_wrap_wrap > .yps_player_wrap > video',
            //     attribute: 'src'),
            keywordsSelector: ElementSelector(
              selector: 'meta[name="keywords"]',
              attribute: 'content',
            ),
            similarContentSelector: ElementSelector(
              selector: '.user_uploads > .video-list > .video-item',
            ),
            videoSelector: ElementSelector(
              selector: '#wrapper_div',
            ),
            contentSelector: ElementSelector(
              selector: '#content_div > .main_content > div > .post_el_small',
            ),
          ),
        );
}
