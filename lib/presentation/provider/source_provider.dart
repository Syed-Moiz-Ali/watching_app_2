import 'package:flutter/material.dart';

class SourceProvider extends ChangeNotifier {
  bool closeVideoPlayer = false;
  setCloseVideoPlayer(bool val) {
    closeVideoPlayer = val;
    notifyListeners();
  }

  String? selectedQuery = '';
  updateState() {
    notifyListeners();
  }
}
