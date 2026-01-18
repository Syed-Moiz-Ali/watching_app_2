import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      hintColor: AppColors.accentColor,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      scaffoldBackgroundColor: AppColors.backgroundColorLight,
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.backgroundColorLight,
      ),
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textColorLight),
        toolbarTextStyle: TextStyle(
          color: AppColors.textColorLight,
          fontSize: 20,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textColorLight,
          fontSize: 20,
        ),
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
        secondary: AppColors.primaryColor,
      ),
    );
  }
}
