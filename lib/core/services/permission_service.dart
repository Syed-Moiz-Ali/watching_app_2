// permission_service.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:watching_app_2/core/global/globals.dart';
import '../../shared/widgets/misc/text_widget.dart';

/// Enhanced permission service with better UX and comprehensive permission handling
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  static const int _maxRetryAttempts = 2;
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Request storage permissions with comprehensive handling
  Future<PermissionResult> requestStoragePermissions() async {
    try {
      if (Platform.isAndroid) {
        return await _handleAndroidPermissions();
      } else if (Platform.isIOS) {
        return await _handleIOSPermissions();
      } else {
        return PermissionResult.granted(
            'Permissions not required on this platform');
      }
    } catch (e) {
      return PermissionResult.error(
          'Failed to request permissions: ${e.toString()}');
    }
  }

  /// Handle Android permissions with API level considerations
  Future<PermissionResult> _handleAndroidPermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Determine required permissions based on Android version
    final List<Permission> requiredPermissions =
        _getRequiredAndroidPermissions(sdkInt);

    // Check current status
    final Map<Permission, PermissionStatus> currentStatuses = {};
    for (final permission in requiredPermissions) {
      currentStatuses[permission] = await permission.status;
    }

    // Filter permissions that need to be requested
    final List<Permission> permissionsToRequest = requiredPermissions
        .where((permission) =>
            currentStatuses[permission] == PermissionStatus.denied ||
            currentStatuses[permission] == PermissionStatus.restricted)
        .toList();

    if (permissionsToRequest.isEmpty) {
      return PermissionResult.granted(
          'All required permissions are already granted');
    }

    // Request permissions with retry logic
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      final result = await _requestPermissionsWithFeedback(
        permissionsToRequest,
        attempt,
        sdkInt,
      );

      if (result.isGranted) {
        return result;
      }

      if (attempt < _maxRetryAttempts) {
        // Show explanation before retry
        final shouldRetry = await _showPermissionExplanation(
          _getPermissionExplanation(permissionsToRequest, sdkInt),
          attempt,
        );

        if (!shouldRetry) {
          return PermissionResult.denied(
            'Permissions are required for wallpaper functionality',
            shouldShowSettings: true,
          );
        }

        await Future.delayed(_retryDelay);
      }
    }

    // Final attempt failed, offer settings
    return PermissionResult.denied(
      'Required permissions were not granted. Please enable them in Settings.',
      shouldShowSettings: true,
    );
  }

  /// Handle iOS permissions
  Future<PermissionResult> _handleIOSPermissions() async {
    final Permission photosPermission = Permission.photos;
    final PermissionStatus currentStatus = await photosPermission.status;

    if (currentStatus == PermissionStatus.granted ||
        currentStatus == PermissionStatus.limited) {
      return PermissionResult.granted('Photo library access granted');
    }

    // Request permission with explanation
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      if (attempt > 1) {
        final shouldRetry = await _showPermissionExplanation(
          'We need access to your photo library to save wallpapers. This allows you to set beautiful wallpapers on your device.',
          attempt,
        );

        if (!shouldRetry) {
          return PermissionResult.denied(
            'Photo library access is required',
            shouldShowSettings: true,
          );
        }
      }

      final PermissionStatus status = await photosPermission.request();

      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        return PermissionResult.granted('Photo library access granted');
      }

      if (status == PermissionStatus.permanentlyDenied) {
        return PermissionResult.denied(
          'Photo library access permanently denied. Please enable in Settings.',
          shouldShowSettings: true,
        );
      }
    }

    return PermissionResult.denied(
      'Photo library access is required for wallpaper functionality',
      shouldShowSettings: true,
    );
  }

  /// Get required Android permissions based on API level
  List<Permission> _getRequiredAndroidPermissions(int sdkInt) {
    final List<Permission> permissions = [];

    if (sdkInt >= 33) {
      // Android 13+ (API 33+) - Granular media permissions
      permissions.addAll([
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ]);
    } else if (sdkInt >= 30) {
      // Android 11+ (API 30+) - Scoped storage with manage external storage
      permissions.addAll([
        Permission.storage,
        Permission.manageExternalStorage,
      ]);
    } else {
      // Android 10 and below - Traditional storage permission
      permissions.add(Permission.storage);
    }

    // Additional permissions that might be helpful
    if (sdkInt >= 29) {
      permissions.add(Permission.accessMediaLocation);
    }

    return permissions;
  }

  /// Request permissions with user feedback
  Future<PermissionResult> _requestPermissionsWithFeedback(
    List<Permission> permissions,
    int attempt,
    int sdkInt,
  ) async {
    try {
      final Map<Permission, PermissionStatus> statuses =
          await permissions.request();

      final List<Permission> deniedPermissions = [];
      final List<Permission> permanentlyDeniedPermissions = [];

      statuses.forEach((permission, status) {
        if (status == PermissionStatus.denied) {
          deniedPermissions.add(permission);
        } else if (status == PermissionStatus.permanentlyDenied) {
          permanentlyDeniedPermissions.add(permission);
        }
      });

      if (permanentlyDeniedPermissions.isNotEmpty) {
        return PermissionResult.denied(
          'Some permissions are permanently denied: ${_formatPermissionNames(permanentlyDeniedPermissions)}',
          shouldShowSettings: true,
        );
      }

      if (deniedPermissions.isEmpty) {
        return PermissionResult.granted('All permissions granted successfully');
      }

      return PermissionResult.denied(
        'Required permissions denied: ${_formatPermissionNames(deniedPermissions)}',
      );
    } catch (e) {
      return PermissionResult.error(
          'Error requesting permissions: ${e.toString()}');
    }
  }

  /// Show permission explanation dialog
  Future<bool> _showPermissionExplanation(
      String explanation, int attempt) async {
    final BuildContext? context = SMA.navigationKey.currentContext;
    if (context == null) return false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Theme.of(dialogContext).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const TextWidget(
                    text: 'Permissions Required',
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(text: explanation),
                  if (attempt > 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextWidget(
                              text: 'Attempt $attempt of $_maxRetryAttempts',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const TextWidget(text: 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const TextWidget(
                    text: 'Grant Permissions',
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show settings dialog with enhanced UX
  Future<bool> showSettingsDialog(String message) async {
    final BuildContext? context = SMA.navigationKey.currentContext;
    if (context == null) return false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(dialogContext).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const TextWidget(
                    text: 'Open Settings',
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(text: message),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            const TextWidget(
                              text: 'How to enable permissions:',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (Platform.isAndroid) ...[
                          const TextWidget(
                            text: '1. Tap "Open Settings" below',
                            fontSize: 11,
                          ),
                          const TextWidget(
                            text: '2. Find and tap "Permissions"',
                            fontSize: 11,
                          ),
                          const TextWidget(
                            text: '3. Enable required permissions',
                            fontSize: 11,
                          ),
                          const TextWidget(
                            text: '4. Return to the app',
                            fontSize: 11,
                          ),
                        ] else ...[
                          const TextWidget(
                            text: '1. Tap "Open Settings" below',
                            fontSize: 11,
                          ),
                          const TextWidget(
                            text: '2. Find your app in the list',
                            fontSize: 11,
                          ),
                          const TextWidget(
                            text: '3. Enable "Photos" permission',
                            fontSize: 11,
                          ),
                          const TextWidget(
                            text: '4. Return to the app',
                            fontSize: 11,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const TextWidget(text: 'Not Now'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(true);
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.open_in_new,
                      size: 16, color: Colors.white),
                  label: const TextWidget(
                    text: 'Open Settings',
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Get permission explanation based on requested permissions
  String _getPermissionExplanation(List<Permission> permissions, int sdkInt) {
    final Set<String> reasons = {};

    for (final permission in permissions) {
      switch (permission) {
        case Permission.photos:
          reasons.add('access your photos to save wallpapers');
          break;
        case Permission.storage:
        case Permission.manageExternalStorage:
          reasons.add('save wallpapers to your device storage');
          break;
        case Permission.videos:
          reasons.add('access video wallpapers');
          break;
        case Permission.audio:
          reasons.add('handle media files with audio');
          break;
        case Permission.accessMediaLocation:
          reasons.add('organize wallpapers by location');
          break;
        case Permission.mediaLibrary:
          reasons.add('access your media library');
          break;
      }
    }

    final String baseMessage =
        'To provide the best wallpaper experience, we need permission to ';
    final String reasonsText = reasons.join(', ');

    return '$baseMessage$reasonsText. Your privacy is important to us - we only access files related to wallpapers.';
  }

  /// Format permission names for user display
  String _formatPermissionNames(List<Permission> permissions) {
    return permissions
        .map((permission) => _getPermissionDisplayName(permission))
        .join(', ');
  }

  /// Get user-friendly permission name
  String _getPermissionDisplayName(Permission permission) {
    switch (permission) {
      case Permission.photos:
        return 'Photos';
      case Permission.storage:
        return 'Storage';
      case Permission.manageExternalStorage:
        return 'File Management';
      case Permission.videos:
        return 'Videos';
      case Permission.audio:
        return 'Audio';
      case Permission.accessMediaLocation:
        return 'Media Location';
      case Permission.mediaLibrary:
        return 'Media Library';
      default:
        return permission.toString().split('.').last;
    }
  }

  /// Check specific permission status
  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  /// Check if all required permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final requiredPermissions =
            _getRequiredAndroidPermissions(androidInfo.version.sdkInt);

        for (final permission in requiredPermissions) {
          final status = await permission.status;
          if (status != PermissionStatus.granted &&
              status != PermissionStatus.limited) {
            return false;
          }
        }
        return true;
      } else if (Platform.isIOS) {
        final status = await Permission.photos.status;
        return status == PermissionStatus.granted ||
            status == PermissionStatus.limited;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get detailed permission status report
  Future<PermissionStatusReport> getPermissionStatusReport() async {
    final Map<Permission, PermissionStatus> statuses = {};
    final List<String> issues = [];

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final requiredPermissions =
            _getRequiredAndroidPermissions(androidInfo.version.sdkInt);

        for (final permission in requiredPermissions) {
          final status = await permission.status;
          statuses[permission] = status;

          if (status == PermissionStatus.denied) {
            issues.add(
                '${_getPermissionDisplayName(permission)} permission is denied');
          } else if (status == PermissionStatus.permanentlyDenied) {
            issues.add(
                '${_getPermissionDisplayName(permission)} permission is permanently denied');
          }
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photos.status;
        statuses[Permission.photos] = status;

        if (status == PermissionStatus.denied) {
          issues.add('Photos permission is denied');
        } else if (status == PermissionStatus.permanentlyDenied) {
          issues.add('Photos permission is permanently denied');
        }
      }

      return PermissionStatusReport(
        statuses: statuses,
        issues: issues,
        allGranted: issues.isEmpty,
      );
    } catch (e) {
      return PermissionStatusReport(
        statuses: {},
        issues: ['Error checking permissions: ${e.toString()}'],
        allGranted: false,
      );
    }
  }

  /// Request specific permission
  Future<PermissionResult> requestSpecificPermission(
      Permission permission) async {
    try {
      final currentStatus = await permission.status;

      if (currentStatus == PermissionStatus.granted ||
          currentStatus == PermissionStatus.limited) {
        return PermissionResult.granted('Permission already granted');
      }

      if (currentStatus == PermissionStatus.permanentlyDenied) {
        return PermissionResult.denied(
          '${_getPermissionDisplayName(permission)} permission is permanently denied',
          shouldShowSettings: true,
        );
      }

      final status = await permission.request();

      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        return PermissionResult.granted('Permission granted successfully');
      } else if (status == PermissionStatus.permanentlyDenied) {
        return PermissionResult.denied(
          '${_getPermissionDisplayName(permission)} permission permanently denied',
          shouldShowSettings: true,
        );
      } else {
        return PermissionResult.denied('Permission denied');
      }
    } catch (e) {
      return PermissionResult.error(
          'Error requesting permission: ${e.toString()}');
    }
  }
}

// Data Classes
class PermissionResult {
  final bool isGranted;
  final String message;
  final bool shouldShowSettings;
  final PermissionResultType type;

  const PermissionResult._({
    required this.isGranted,
    required this.message,
    required this.shouldShowSettings,
    required this.type,
  });

  factory PermissionResult.granted(String message) {
    return PermissionResult._(
      isGranted: true,
      message: message,
      shouldShowSettings: false,
      type: PermissionResultType.granted,
    );
  }

  factory PermissionResult.denied(String message,
      {bool shouldShowSettings = false}) {
    return PermissionResult._(
      isGranted: false,
      message: message,
      shouldShowSettings: shouldShowSettings,
      type: PermissionResultType.denied,
    );
  }

  factory PermissionResult.error(String message) {
    return PermissionResult._(
      isGranted: false,
      message: message,
      shouldShowSettings: false,
      type: PermissionResultType.error,
    );
  }
}

enum PermissionResultType {
  granted,
  denied,
  error;
}

class PermissionStatusReport {
  final Map<Permission, PermissionStatus> statuses;
  final List<String> issues;
  final bool allGranted;

  const PermissionStatusReport({
    required this.statuses,
    required this.issues,
    required this.allGranted,
  });

  bool hasPermission(Permission permission) {
    final status = statuses[permission];
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  List<Permission> get deniedPermissions {
    return statuses.entries
        .where((entry) => entry.value == PermissionStatus.denied)
        .map((entry) => entry.key)
        .toList();
  }

  List<Permission> get permanentlyDeniedPermissions {
    return statuses.entries
        .where((entry) => entry.value == PermissionStatus.permanentlyDenied)
        .map((entry) => entry.key)
        .toList();
  }
}
