// ignore_for_file: file_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as html;

class AnyPorn {
  dynamic getProperty(dynamic element, String propertyName) {
    if (element is html.Element) {
      switch (propertyName) {
        case 'image':
          return element
                  .querySelector('.thmbclck > .img > a >  img')
                  ?.attributes['data-original'] ??
              '';
        case 'id':
          return element
                  .querySelector('.thmbclck > .img > a')
                  ?.attributes['href'] ??
              '';
        case 'title':
          return element
                  .querySelector('.thmbclck > .img > a >  img')
                  ?.attributes['alt'] ??
              '';
        case 'duration':
          return element
                  .querySelector('.thmbclck > .wrap >.added > em')
                  ?.attributes['data-duration'] ??
              '';
        case 'preview':
          return element
                  .querySelector('.thmbclck > .img > a >  img')
                  ?.attributes['data-preview'] ??
              '';
        case 'quality':
          return element.querySelector('.is-hd') != null
              ? element.querySelector('.is-hd')!.text
              : 'HD';
        case 'time':
          return '';
        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element
              .querySelectorAll('.box > .list-videos > .margin-fix > .item');
        default:
          return '';
      }
    }
  }

  dynamic getVideos(dynamic element, String propertyName) {
    if (element is html.Element) {
      Map streamUrl = {};
      var watchingLink = element.querySelectorAll('script')[1].innerHtml;
      // print('watchingLink is $watchingLink');
      final match = RegExp(r'const sources = ({.*?});', dotAll: true)
          .firstMatch(watchingLink);

      final jsonString = match!
          .group(1)!
          .replaceAll("'", '"')
          .replaceAll("{", '')
          .replaceAll("}", '')
          .replaceAll('https:', '')
          .trim();
      var list = jsonString.split(':');
      print('the list is ${list.length}');
      // final streamDataJson = json.decode(jsonString);
      // final streamUrls = Map<String, dynamic>.from(streamDataJson);

      // Now 'streamUrls' contains the sources and their URLs
      // You can use this map as needed
      for (int i = 0; i <= list.length; i++) {
        // Check if the index is odd
        if (i % 2 != 0) {
          // Add key-value pair to the map
          streamUrl[list[i].toString()] = list[i + 1].toString();
        }
      }
      if (kDebugMode) {
        print('streamUrl is $streamUrl');
      }
      switch (propertyName) {
        case 'watchingLink':
          return '';

        default:
          return '';
      }
    } else {
      switch (propertyName) {
        case 'selector':
          return element.querySelectorAll('.player-holder > .player-wrap');
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
