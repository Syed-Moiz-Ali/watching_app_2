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
  Future<bool> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final platformUtils = PlatformUtils();
      bool isAndroid13Plus = await platformUtils.isAndroid13OrAbove();

      if (isAndroid13Plus) {
        // For Android 13+ (including 14, 15), request all necessary granular media permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
          Permission.storage,
          // Add these more specific permissions for file access
          Permission.manageExternalStorage,
          // Some devices might need this for download functionality
          Permission.mediaLibrary,
        ].request();

        // Check if any of the critical permissions were denied
        bool allGranted = true;
        String deniedPermissions = '';

        statuses.forEach((permission, status) {
          if (status != PermissionStatus.granted &&
              status != PermissionStatus.limited) {
            allGranted = false;
            deniedPermissions += '$permission, ';
          }
        });

        if (!allGranted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message:
                'The following permissions are required: $deniedPermissions',
          );
        }

        return true;
      } else {
        // For older Android versions (10-12)
        bool isAndroid10Plus = await platformUtils.isAndroid10OrAbove();

        if (isAndroid10Plus) {
          PermissionStatus status = await Permission.storage.request();
          if (status != PermissionStatus.granted) {
            throw PlatformException(
              code: 'PERMISSION_DENIED',
              message: 'Storage permission is required to download wallpapers',
            );
          }
        } else {
          // For Android 9 and below
          PermissionStatus status = await Permission.storage.request();
          if (status != PermissionStatus.granted) {
            throw PlatformException(
              code: 'PERMISSION_DENIED',
              message: 'Storage permission is required to download wallpapers',
            );
          }
        }

        return true;
      }
    } else if (Platform.isIOS) {
      // For iOS, request photo library permission
      PermissionStatus status = await Permission.photos.request();
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.limited) {
        throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Photo library access is required to save wallpapers',
        );
      }
      return true;
    }

    // For other platforms
    return true;
  }
}
