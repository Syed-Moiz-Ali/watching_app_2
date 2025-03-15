import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor =
      Color(0xFFb91c1c); // Dark grey (nearly black) for primary actions
  // static const Color primaryColor =
  //     Color(0xFF0A0A0A); // Dark grey (nearly black) for primary actions
  static const Color primaryDark =
      Color(0xFF424242); // Lighter grey for dark mode primary
  static const Color secondaryColor =
      Color(0xFFb91c1c); // Light blue for secondary elements
  static const Color secondaryDark =
      Color(0xFFb91c1c); // Slightly darker blue for dark mode secondary

  // Neutral Colors
  static const Color backgroundColorLight =
      Color(0xFFFFFFFF); // Pure white for light background
  static const Color backgroundColorDark =
      Color(0xFF121212); // Deep grey for dark background
  static const Color surfaceLight =
      Color(0xFFF5F5F5); // Off-white for cards in light mode
  static const Color surfaceDark =
      Color(0xFF1E1E1E); // Dark grey for cards in dark mode

  // Text Colors
  static const Color textColorLight =
      Color(0xFF000000); // Black for light mode text
  static const Color textColorDark =
      Color(0xFFFFFFFF); // White for dark mode text
  static const Color textSecondaryLight =
      Color(0xFF757575); // Grey for secondary text in light mode
  static const Color textSecondaryDark =
      Color(0xFFB0BEC5); // Light grey for secondary text in dark mode

  // On Colors
  static const Color onPrimaryLight =
      Color(0xFFFFFFFF); // White text on primary
  static const Color onPrimaryDark =
      Color(0xFFFFFFFF); // White text on primaryDark (adjusted for contrast)
  static const Color onSecondaryLight =
      Color(0xFF000000); // Black text on secondary
  static const Color onSecondaryDark =
      Color(0xFF000000); // Black text on secondaryDark
  static const Color onSurfaceLight =
      Color(0xFF000000); // Black text on surface
  static const Color onSurfaceDark = Color(0xFFFFFFFF); // White text on surface

  // Other Colors
  static const Color accentColor =
      Color(0xFFBB86FC); // Purple accent for highlights
  static const Color errorColor = Color(0xFFE57373); // Soft red for errors
  static const Color disabledColor =
      Color(0xFFB4B3B3); // Grey for disabled elements
  static const Color transparent = Colors.transparent;
  static const Color greyColor = Color(0xFF757575); // Grey for borders/dividers

  // Gradient
  static const LinearGradient gradient = LinearGradient(
    colors: [
      Color(0xFF81D4FA), // Secondary color
      Color(0xFF0A0A0A), // Primary color
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow
  static BoxShadow shadow = BoxShadow(
    color: const Color(0xFF000000).withOpacity(0.1),
    blurRadius: 25,
    spreadRadius: 0,
  );
}
