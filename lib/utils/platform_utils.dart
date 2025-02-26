import 'dart:io';

class PlatformUtils {
  // Singleton pattern
  static final PlatformUtils _instance = PlatformUtils._internal();
  factory PlatformUtils() => _instance;
  PlatformUtils._internal();

  /// Check if device is running Android 10 or above
  Future<bool> isAndroid10OrAbove() async {
    if (Platform.isAndroid) {
      String release = await getAndroidVersion();
      int version = int.tryParse(release) ?? 0;
      return version >= 10;
    }
    return false;
  }

  /// Check if device is running Android 13 or above
  Future<bool> isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      String release = await getAndroidVersion();
      int version = int.tryParse(release) ?? 0;
      return version >= 13;
    }
    return false;
  }

  /// Get Android version as a string
  Future<String> getAndroidVersion() async {
    try {
      return Platform.operatingSystemVersion.split(' ').last;
    } catch (e) {
      return '0';
    }
  }
}
