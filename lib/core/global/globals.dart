import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/content_item.dart';
import '../constants/colors.dart';
import '../services/logger.dart';
import '../services/service_locator.dart';

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

  static LoggingService logger = locator<LoggingService>();
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

  static baseTextStyle(
      {double? fontSize = 16.0,
      Color? color = AppColors.backgroundColorDark,
      FontWeight? fontWeight = FontWeight.w500,
      TextDecoration? decoration = TextDecoration.none,
      double? letterSpacing = 0.0,
      List<Shadow>? shadows}) {
    TextStyle baseStyle = GoogleFonts.urbanist(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      decoration: decoration,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
    return baseStyle;
  }
}
