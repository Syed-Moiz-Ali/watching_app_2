import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';

class LocalAuthProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isProtectionEnabled = false;
  bool _isAuthenticating = false;
  bool _isAuthenticated = false;

  bool get isProtectionEnabled => _isProtectionEnabled;
  bool get isAuthenticating => _isAuthenticating;
  bool get isAuthenticated => _isAuthenticated;

  // Load saved preferences
  Future<void> loadPreferences() async {
    debugPrint('LocalAuthProvider: Entering loadPreferences');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _isProtectionEnabled = prefs.getBool('isProtectionEnabled') ?? false;
      debugPrint(
          'LocalAuthProvider: Loaded isProtectionEnabled: $_isProtectionEnabled');
      notifyListeners();
    } catch (e) {
      debugPrint('LocalAuthProvider: Error loading preferences: $e');
    }
    debugPrint('LocalAuthProvider: Exiting loadPreferences');
  }

  // Save protection preference
  Future<void> toggleProtection(bool value) async {
    debugPrint(
        'LocalAuthProvider: Entering toggleProtection with value: $value');
    try {
      _isProtectionEnabled = value;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isProtectionEnabled', value);
      debugPrint('LocalAuthProvider: Saved isProtectionEnabled: $value');
      notifyListeners();
    } catch (e) {
      debugPrint('LocalAuthProvider: Error saving preferences: $e');
    }
    debugPrint('LocalAuthProvider: Exiting toggleProtection');
  }

  // Check if device supports biometrics
  Future<bool> checkBiometricSupport() async {
    debugPrint('LocalAuthProvider: Entering checkBiometricSupport');
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
      debugPrint(
          'LocalAuthProvider: Biometric support available: $canCheckBiometrics');
    } on PlatformException catch (e) {
      debugPrint('LocalAuthProvider: Error checking biometrics: $e');
    }
    debugPrint(
        'LocalAuthProvider: Exiting checkBiometricSupport with result: $canCheckBiometrics');
    return canCheckBiometrics;
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    debugPrint('LocalAuthProvider: Entering getAvailableBiometrics');
    List<BiometricType> availableBiometrics = [];
    try {
      availableBiometrics = await _localAuth.getAvailableBiometrics();
      debugPrint(
          'LocalAuthProvider: Available biometrics: $availableBiometrics');
    } on PlatformException catch (e) {
      debugPrint('LocalAuthProvider: Error getting available biometrics: $e');
    }
    debugPrint(
        'LocalAuthProvider: Exiting getAvailableBiometrics with ${availableBiometrics.length} types');
    return availableBiometrics;
  }

  // Authenticate with biometrics
  Future<bool> authenticate() async {
    debugPrint('LocalAuthProvider: Entering authenticate');
    bool authenticated = false;

    if (!await checkBiometricSupport()) {
      debugPrint(
          'LocalAuthProvider: Biometric support not available, returning false');
      return false;
    }

    try {
      _isAuthenticating = true;
      debugPrint('LocalAuthProvider: Set isAuthenticating to true');
      notifyListeners();

      authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      _isAuthenticated = authenticated;
      debugPrint('LocalAuthProvider: Authentication result: $authenticated');
      if (authenticated == true) {
        await Future.delayed(const Duration(seconds: 1));
        NH.nameNavigateTo(AppRoutes.home);
      }
    } on PlatformException catch (e) {
      debugPrint('LocalAuthProvider: Error authenticating: $e');
    } finally {
      _isAuthenticating = false;
      debugPrint(
          'LocalAuthProvider: Set isAuthenticating to false in finally block');
      notifyListeners();
    }

    debugPrint(
        'LocalAuthProvider: Exiting authenticate with result: $authenticated');
    return authenticated;
  }

  // Stop authentication if in progress
  Future<void> cancelAuthentication() async {
    debugPrint('LocalAuthProvider: Entering cancelAuthentication');
    try {
      if (_isAuthenticating) {
        await _localAuth.stopAuthentication();
        _isAuthenticating = false;
        debugPrint('LocalAuthProvider: Authentication cancelled');
        notifyListeners();
      } else {
        debugPrint(
            'LocalAuthProvider: No authentication in progress to cancel');
      }
    } catch (e) {
      debugPrint('LocalAuthProvider: Error cancelling authentication: $e');
    }
    debugPrint('LocalAuthProvider: Exiting cancelAuthentication');
  }

  // Reset authentication state
  void resetAuthentication() {
    debugPrint('LocalAuthProvider: Entering resetAuthentication');
    _isAuthenticated = false;
    debugPrint('LocalAuthProvider: Reset isAuthenticated to false');
    notifyListeners();
    debugPrint('LocalAuthProvider: Exiting resetAuthentication');
  }
}
