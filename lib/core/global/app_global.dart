import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/content_item.dart';

class SMA {
  static GlobalKey<NavigatorState> navigationKey = GlobalKey();
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static var theme = Theme.of(navigationKey.currentContext!);
  static SharedPreferences? pref;
  static Size size = Size(
      MediaQuery.of(navigationKey.currentContext!).size.width,
      MediaQuery.of(navigationKey.currentContext!).size.height);
  static initializePref() async {
    pref = await SharedPreferences.getInstance();
  }

  static String formatImage({
    required String baseUrl,
    required String image,
  }) {
    if (image.startsWith('//')) {
      return 'https:$image';
    } else if (image.startsWith('/')) {
      return baseUrl + image.substring(1);
    } else {
      return image;
    }
  }

  static bool filterData(List<ContentItem> items) {
    return items
        .where(
            (e) => [e.title, e.thumbnailUrl, e.contentUrl, e.time].contains(''))
        .isNotEmpty;
  }
}
