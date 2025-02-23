import 'dart:developer';

import 'package:html/dom.dart' as html;

class Sxyprn {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          log('image Component is ${element.querySelector('.js-pop > .vid_container >   .post_vid_thumb ')?.outerHtml}');
          return element
                  .querySelector(
                      '.js-pop > .vid_container >   .post_vid_thumb > img')
                  ?.attributes['data-src'] ??
              'NA';
        case 'id':
          return element.querySelector('.js-pop')?.attributes['href'] ?? 'NA';
        case 'title':
          return element.querySelector('.js-pop')?.attributes['aria-label'] ??
              'NA';
        case 'duration':
          return element
                  .querySelector(
                      '.js-pop  > .vid_container >   .post_vid_thumb >.duration_small')
                  ?.text ??
              'NA';
        case 'preview':
          return element
                  .querySelector(
                      '.js-pop  > .vid_container >   .post_vid_thumb >  video')
                  ?.attributes['src'] ??
              'NA';
        case 'quality':
          return element
                  .querySelector(
                      '.js-pop  > .vid_container >   .post_vid_thumb > .shd_small')
                  ?.text ??
              'NA';
        case 'time':
          return element
                  .querySelector(
                      '.post_control >.post_time > .post_control_time')
                  ?.text ??
              'NA';
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          // log(element
          //     .querySelectorAll(
          //         '#content_div > .main_content > div > .post_el_small')
          //     .first
          //     .outerHtml);
          return element.querySelectorAll(
              '#content_div > .main_content > div > .post_el_small');
        default:
          return '';
      }
    }
  }
}
