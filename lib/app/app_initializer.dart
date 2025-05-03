import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/shared/provider/local_auth_provider.dart';

import '../core/navigation/routes.dart';

class AppInitializer {
  static String _updateUrl = '';

  static Future<(String route, Map<String, dynamic>? args)>
      initializeApp() async {
    if (await _checkForUpdate()) {
      return (AppRoutes.update, {"updateUrl": _updateUrl});
    }

    final bool isSecureApp = await _getSecureAppFlag();
    return (isSecureApp ? AppRoutes.auth : AppRoutes.home, null);
  }

  static Future<bool> _checkForUpdate() async {
    final Uri uri = Uri.parse(
        'https://luststream-app.github.io/luststream_config/appConfig.json');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String appBuildNumber =
            data['browsexConfig']['buildNumber'].toString();
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String packageBuildNumber = packageInfo.buildNumber;
        _updateUrl = data['browsexConfig']['url'];
        return int.parse(packageBuildNumber) < int.parse(appBuildNumber);
      } else {
        return false;
      }
    } on SocketException {
      return false;
    } on http.ClientException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _getSecureAppFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCategories', ['videos']);
    return prefs.getBool('isProtectionEnabled') ?? false;
  }
}
