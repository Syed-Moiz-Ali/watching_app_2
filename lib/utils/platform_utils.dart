import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PlatformUtils {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<bool> isAndroid10OrAbove() async {
    if (!Platform.isAndroid) return false;

    AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 29; // Android 10 is API level 29
  }

  Future<bool> isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;

    AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 33; // Android 13 is API level 33
  }

  // Add methods for Android 14 and 15
  Future<bool> isAndroid14OrAbove() async {
    if (!Platform.isAndroid) return false;

    AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 34; // Android 14 is API level 34
  }

  Future<bool> isAndroid15OrAbove() async {
    if (!Platform.isAndroid) return false;

    AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 35; // Android 15 is API level 35
  }
}
