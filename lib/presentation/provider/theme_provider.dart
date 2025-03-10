import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/global/globals.dart'; // For SMA.pref

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  bool _isDarkTheme = false;

  // Getter for current ThemeMode
  ThemeMode get themeMode => _themeMode;

  // Getter for dark theme status
  bool get isDarkTheme => _isDarkTheme;

  // Constructor to initialize theme
  ThemeProvider() {
    initializeTheme();
  }

  // Set the theme and persist it
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _updateDarkThemeStatus();
    if (SMA.pref != null) {
      SMA.pref!.setBool('_isDarkTheme', _isDarkTheme);
    }
    notifyListeners();
  }

  // Toggle between light and dark themes
  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      // If system mode, toggle based on current brightness
      _themeMode = _isDarkTheme ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    _updateDarkThemeStatus();
    if (SMA.pref != null) {
      SMA.pref!.setBool('_isDarkTheme', _isDarkTheme);
    }
    notifyListeners();
  }

  // Initialize theme from preferences
  Future<void> initializeTheme() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (SMA.pref == null) {
        await SMA.initializePref();
      }
      var pref = SMA.pref!;
      bool storedDarkTheme = pref.getBool('_isDarkTheme') ?? false;

      // Set theme based on stored preference or system default
      _themeMode = storedDarkTheme ? ThemeMode.dark : ThemeMode.light;
      _updateDarkThemeStatus();
      notifyListeners();
    });
  }

  // Helper to update _isDarkTheme based on _themeMode
  void _updateDarkThemeStatus() {
    if (_themeMode == ThemeMode.system) {
      _isDarkTheme =
          PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    } else {
      _isDarkTheme = _themeMode == ThemeMode.dark;
    }
  }
}
