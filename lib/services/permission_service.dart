import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:watching_app_2/core/global/app_global.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  Future<bool> requestStoragePermissions() async {
    int retryCount = 0; // Track the number of retry attempts

    while (retryCount < 2) {
      if (Platform.isAndroid) {
        // Request permissions for Android
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
          Permission.storage,
          Permission.manageExternalStorage,
          Permission.accessMediaLocation,
          Permission.mediaLibrary,
        ].request();

        // Check if any permission was denied
        bool allGranted = true;
        String deniedPermissions = '';
        statuses.forEach((permission, status) {
          if (status != PermissionStatus.granted &&
              status != PermissionStatus.limited) {
            allGranted = false;
            deniedPermissions += '$permission, ';
          }
        });

        if (allGranted) {
          return true; // All permissions granted
        } else {
          if (retryCount == 1) {
            // After two tries, ask the user to open settings
            return await _showSettingsDialog(deniedPermissions);
          }
          retryCount++;
        }
      } else if (Platform.isIOS) {
        // iOS specific permission
        PermissionStatus status = await Permission.photos.request();
        if (status == PermissionStatus.granted ||
            status == PermissionStatus.limited) {
          return true;
        } else {
          if (retryCount == 1) {
            return await _showSettingsDialog('Photo library access');
          }
          retryCount++;
        }
      }

      // If we haven't granted permission yet, delay before retrying
      await Future.delayed(const Duration(seconds: 2));
    }

    // If permission is not granted after 2 retries, show the open settings dialog
    return false;
  }

  Future<bool> _showSettingsDialog(String deniedPermissions) async {
    bool openSettings = await showDialog(
          context: SMA.navigationKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: Text(
                'The following permissions are required: $deniedPermissions. Please grant them in settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context, false); // User chooses not to go to settings
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, true); // User wants to open settings
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        ) ??
        false;

    return openSettings;
  }
}
