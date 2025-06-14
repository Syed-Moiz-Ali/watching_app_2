import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigProvider extends ChangeNotifier {
  final String _updateConfigUrl =
      'https://luststream-app.github.io/luststream_config/appConfig.json';
  bool _isProtectionEnabled = false;
  String? _errorMessage;
  String? _errorDetails; // Added to store error details

  String get updateConfigUrl => _updateConfigUrl;
  bool get isProtectionEnabled => _isProtectionEnabled;
  String? get errorMessage => _errorMessage;
  String? get errorDetails => _errorDetails; // Getter for errorDetails

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isProtectionEnabled = prefs.getBool('isProtectionEnabled') ?? false;
      await prefs.setStringList('selectedCategories', ['videos']);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Config initialization error: $e');
      }
      _errorMessage = 'Failed to initialize configuration.';
      _errorDetails = e.toString();
      notifyListeners();
    }
  }

  void setError(String message, {String? details}) {
    _errorMessage = message;
    _errorDetails = details;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorDetails = null;
    notifyListeners();
  }
}
