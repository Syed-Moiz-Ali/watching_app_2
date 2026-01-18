import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

class DarkTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      hintColor: AppColors.accentColor,
      scaffoldBackgroundColor: AppColors.backgroundColorDark,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      dialogTheme:  const DialogThemeData(
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
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: AppColors.primaryColor)),
      ),
      colorScheme: ColorScheme.fromSeed(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.onPrimaryDark,
        surface: AppColors.backgroundColorDark,
        onSurface: AppColors.onSurfaceDark,
        seedColor: AppColors.primaryColor,
        brightness: Brightness.dark,
        error: AppColors.errorColor,
        secondary: AppColors.primaryColor,
      ),
    );
  }
}
