import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MangaDetailConstants {
  static const systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  );

  static const double appBarHeight = 300.0;
  static const double scrollThreshold = 200.0;
  static const Duration fadeAnimationDuration = Duration(milliseconds: 800);
  static const Duration crossFadeDuration = Duration(milliseconds: 300);
  static const double buttonHeight = 48.0;
  static const double sectionSpacing = 20.0;
  static const double sectionSpacingLarge = 30.0;
  static const double chipSpacing = 8.0;
  static const double statSpacing = 12.0;
  static const double buttonSpacing = 12.0;
  static const double listSpacing = 8.0;
  static const double textSpacing = 8.0;

  static const EdgeInsets contentPadding = EdgeInsets.all(20.0);
  static const EdgeInsets buttonMargin = EdgeInsets.all(8);
  static const EdgeInsets tilePadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 4);
  static const EdgeInsets statPadding = EdgeInsets.all(16);
}
