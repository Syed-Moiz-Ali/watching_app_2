import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/platform_utils.dart';

class PermissionService {
  // Singleton pattern
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request appropriate storage permissions based on the Android version
  Future<void> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final platformUtils = PlatformUtils();
      bool isAndroid13Plus = await platformUtils.isAndroid13OrAbove();
      bool isAndroid10Plus = await platformUtils.isAndroid10OrAbove();

      if (isAndroid13Plus) {
        // For Android 13+, request media permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.storage,
        ].request();

        if (statuses[Permission.photos] != PermissionStatus.granted ||
            statuses[Permission.storage] != PermissionStatus.granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Storage permission is required to download wallpapers',
          );
        }
      } else if (isAndroid10Plus) {
        // For Android 10-12, request storage permission
        if (await Permission.storage.request() != PermissionStatus.granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Storage permission is required to download wallpapers',
          );
        }
      } else {
        // For Android 9 and below
        if (await Permission.storage.request() != PermissionStatus.granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Storage permission is required to download wallpapers',
          );
        }
      }
    }
    // For iOS or other platforms, permissions might differ
    // Add implementation as needed
  }
}
