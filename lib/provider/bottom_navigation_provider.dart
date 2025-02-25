import 'package:flutter/material.dart';

class BottomNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _hasNotification = false;

  int get currentIndex => _currentIndex;
  bool get hasNotification => _hasNotification;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setNotification(bool value) {
    _hasNotification = value;
    notifyListeners();
  }
}
