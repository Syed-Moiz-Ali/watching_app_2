import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/navigation/routes.dart';

class AppInitializer {
  static String _updateUrl = '';

  /// Initializes the app and determines the initial route and arguments.
  static Future<(String route, Map<String, dynamic>? args)>
      initializeApp() async {
    // Check for app update first
    if (!await _isUpdateAvailable()) {
      return (AppRoutes.update, {"updateUrl": _updateUrl});
    }

    // Check if app protection is enabled
    final bool isProtectionEnabled = await _isProtectionEnabled();

    // Check if age is verified
    final bool isAgeVerified = await _isAgeVerified();

    // Decide initial route based on flags
    if (isProtectionEnabled) {
      return (AppRoutes.auth, null);
    } else if (!isAgeVerified) {
      return (AppRoutes.age, null);
    } else {
      return (AppRoutes.home, null);
    }
  }

  /// Checks if an app update is available.
  static Future<bool> _isUpdateAvailable() async {
    const String configUrl =
        'https://luststream-app.github.io/luststream_config/appConfig.json';
    try {
      final response = await http.get(Uri.parse(configUrl));
      if (response.statusCode != 200) return false;

      final data = json.decode(response.body);
      final String latestBuild =
          data['browsexConfig']['buildNumber'].toString();
      final String updateUrl = data['browsexConfig']['url'];

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentBuild = packageInfo.buildNumber;

      _updateUrl = updateUrl;

      return int.tryParse(currentBuild) != null &&
          int.tryParse(latestBuild) != null &&
          int.parse(currentBuild) < int.parse(latestBuild);
    } on SocketException catch (_) {
      // No internet connection
      return false;
    } on http.ClientException catch (_) {
      // HTTP error
      return false;
    } catch (_) {
      // Any other error
      return false;
    }
  }

  /// Checks if app protection is enabled.
  static Future<bool> _isProtectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure default categories are set for new users
    prefs.setStringList('selectedCategories', ['videos']);
    return prefs.getBool('isProtectionEnabled') ?? false;
  }

  /// Checks if the user has verified their age.
  static Future<bool> _isAgeVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('age_verified') ?? false;
  }
}
