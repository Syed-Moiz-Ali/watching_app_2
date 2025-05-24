import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/global/globals.dart';

class MangaReaderConstants {
  // static const Color accentColor = Color(0xFF00D4B8);
  // static const Color activeControlColor = Color(0xFF7B61FF);
  // static const Color nightOverlayColor = Color(0xFF1A1A2E);
  // static const Color subtitleColor = Color(0xFFAAAAAA);
  // static const Color progressBackgroundColor = Color(0xFF2C2F33);

  static const String nightTheme = 'Night';

  static const double maxScale = 4.0;
  static const double minScale = 1.0;
  static const double borderRadius = 8.0;
  static const double spacing = 12.0;
  static const double controlHubRightMargin = 20.0;
  static const double controlHubBottomMargin = 100.0;

  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Duration fadeDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  static const Duration scrollTransitionDuration = Duration(milliseconds: 600);

  static const EdgeInsets topBarPadding = EdgeInsets.fromLTRB(16, 48, 16, 12);
  static const EdgeInsets bottomBarPadding =
      EdgeInsets.symmetric(vertical: 16, horizontal: 20);
  static const EdgeInsets sheetPadding = EdgeInsets.all(20);

  static const BorderRadius topBarBorderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(16),
  );

  static const BorderRadius bottomBarBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  );

  static const BorderRadius sheetBorderRadius =
      BorderRadius.vertical(top: Radius.circular(20));

  static const List<BoxShadow> boxShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFF00D4B8), Color(0xFF7B61FF)],
  );

  static const SliderThemeData sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.primaryColor,
    inactiveTrackColor: AppColors.greyColor,
    thumbColor: AppColors.backgroundColorDark,
    overlayColor: Color(0xFF00D4B8),
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
    trackHeight: 4,
  );

  static TextStyle titleStyle = SMA.baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitleStyle = SMA.baseTextStyle(
    fontSize: 12,
  );

  static TextStyle pageNumberStyle = SMA.baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle pageCountStyle = SMA.baseTextStyle(
    fontSize: 14,
  );

  static TextStyle sectionTitleStyle = SMA.baseTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle dialogTitleStyle = SMA.baseTextStyle(
    fontSize: 18,
  );

  static TextStyle textStyle = SMA.baseTextStyle(
    fontSize: 14,
  );

  static TextStyle actionTextStyle = SMA.baseTextStyle(
    color: AppColors.primaryColor,
  );

  static TextStyle cancelTextStyle = SMA.baseTextStyle(
    color: Colors.grey,
  );

  static const ButtonStyle segmentedButtonStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(AppColors.greyColor),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
    // selectedForegroundColor: WidgetStatePropertyAll(Colors.white),
    // selectedBackgroundColor: WidgetStatePropertyAll(accentColor),
  );

  static const List<DeviceOrientation> allowedOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  // static const Color controlButtonBackgroundColor = Color(0xFF2C2F33);
}
