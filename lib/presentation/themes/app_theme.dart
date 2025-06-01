import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
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
        titleTextStyle:
            TextStyle(color: AppColors.textColorLight, fontSize: 20),
      ),
      buttonTheme: ButtonThemeData(
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
        secondary: AppColors.primaryColor,
      ),
    );
  }
}
