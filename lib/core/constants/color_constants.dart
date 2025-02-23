// lib/config/constants.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  // static Color primaryColor = const Color(0xFF07B663);
  static const Color primaryColor =
      Color(0xFF0A0A0A); // Light blue for primary actions
  static const Color secondaryColor =
      Color(0xFF81D4FA); // Lighter blue for secondary elements

  // Neutral Colors
  static const Color backgroundColorLight = Color(0xFFFFFFFF);
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color textColorLight = Color(0xFF000000);
  static const Color textColorDark = Color(0xFFFFFFFF);

  // On colors
  static const Color onPrimaryLight =
      Color(0xFFFFFFFF); // White text on primary
  static const Color onPrimaryDark = Color(0xFF000000); // Black text on primary
  static const Color onSurfaceLight =
      Color(0xFF000000); // Black text on surface
  static const Color onSurfaceDark = Color(0xFFFFFFFF); // White text on surface

  // Other Colors
  static const Color accentColor = Color(0xFFBB86FC);
  static const Color errorColor = Colors.red;
  static const Color disabledColor = Color(0xFFB4B3B3);
  static const Color transparent = Colors.transparent;
  static const Color greyColor = Color(0xFF757575);
  static const LinearGradient gradient = LinearGradient(colors: [
    Color(0XFF0128EC),
    Color(0XFF001EB6),
  ]);
  static BoxShadow shadow = BoxShadow(
      color: const Color(0XFF000000).withOpacity(.1),
      blurRadius: 25,
      spreadRadius: 0);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    hintColor: AppColors.accentColor,
    scaffoldBackgroundColor: AppColors.backgroundColorLight,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColorLight),
      bodyMedium: TextStyle(color: AppColors.textColorLight),
    ),
    dialogBackgroundColor: AppColors.backgroundColorLight,
    dialogTheme: const DialogTheme(
      backgroundColor: AppColors.backgroundColorLight,
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.textColorLight),
      toolbarTextStyle:
          TextStyle(color: AppColors.textColorLight, fontSize: 20),
      titleTextStyle: TextStyle(color: AppColors.textColorLight, fontSize: 20),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    cardTheme: CardTheme(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.onPrimaryLight,
      surface: AppColors.backgroundColorLight,
      onSurface: AppColors.onSurfaceLight,
      seedColor: AppColors.primaryColor,
      brightness: Brightness.light,
      error: AppColors.errorColor,
      secondary: AppColors.secondaryColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    hintColor: AppColors.accentColor,
    scaffoldBackgroundColor: AppColors.backgroundColorDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColorDark),
      bodyMedium: TextStyle(color: AppColors.textColorDark),
    ),
    dialogBackgroundColor: AppColors.backgroundColorDark,
    dialogTheme: const DialogTheme(
      backgroundColor: AppColors.backgroundColorDark,
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.textColorDark),
      toolbarTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
      titleTextStyle: TextStyle(color: AppColors.textColorDark, fontSize: 20),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    cardTheme: CardTheme(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: AppColors.primaryColor)),
    ),
    colorScheme: ColorScheme.fromSeed(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.onPrimaryDark,
      surface: AppColors.backgroundColorDark,
      onSurface: AppColors.onSurfaceDark,
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
      error: AppColors.errorColor,
      secondary: AppColors.secondaryColor,
    ),
  );
}
