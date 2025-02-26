import 'package:flutter/material.dart';

import '../core/global/app_global.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? theme;
  setTheme(ThemeMode val) {
    theme = val;
    setIsDarkTheme(val == ThemeMode.dark);
    notifyListeners();
  }

  bool isDarkTheme = false;
  setIsDarkTheme(bool val) {
    isDarkTheme = val;
    notifyListeners();
  }

  Future<void> initializeTheme() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (SMA.pref == null) {
        await SMA.initializePref();
      }
      var pref = SMA.pref!;
      bool getDarkTheme = pref.getBool('_isDarkTheme') ?? false;

      setTheme(getDarkTheme ? ThemeMode.dark : ThemeMode.light);
      setIsDarkTheme(getDarkTheme);
    });
  }
}
