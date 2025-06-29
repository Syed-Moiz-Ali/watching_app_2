import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import '../../shared/widgets/misc/text_widget.dart';
import '../global/globals.dart';
import '../utils/file_utils.dart';
import '../../data/models/content_item.dart';
import 'permission_service.dart';

/// Service for handling wallpaper operations including downloading and applying wallpapers.
class WallpaperService {
  // Singleton pattern
  static final WallpaperService _instance = WallpaperService._internal();
  factory WallpaperService() => _instance;
  WallpaperService._internal();

  // Dependencies
  final Dio _dio = Dio();
  final FileUtils _fileUtils = FileUtils();
  final PermissionService _permissionService = PermissionService();

  // Constants
  static const _snackBarDuration = Duration(seconds: 2);
  static const _snackBarOpacity = 0.7;
  static const _snackBarBorderRadius = 20.0;
  static const _snackBarBottomMarginFactor = 0.1;
  static const _snackBarHorizontalMargin = 50.0;

  /// Applies a wallpaper to the device from a given content item.
  ///
  /// [item] The content item containing wallpaper details.
  /// [location] The screen to apply the wallpaper to (HOME_SCREEN, LOCK_SCREEN, or BOTH_SCREENS).
  /// [onProgress] Optional callback for download progress updates.
  /// [onSuccess] Optional callback for successful wallpaper application.
  /// [onError] Optional callback for error handling.
  /// Returns true if the wallpaper was set successfully, false otherwise.
  Future<bool> applyWallpaper(
    ContentItem item,
    int location, {
    Function(double)? onProgress,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Request storage permissions
      await _permissionService.requestStoragePermissions();

      // Get file path for wallpaper
      final filePath = await _getWallpaperFilePath(item);

      // Download wallpaper if it doesn't exist
      await _downloadWallpaperIfNeeded(
        item: item,
        filePath: filePath,
        onProgress: onProgress,
      );

      // Apply the wallpaper
      final success =
          await WallpaperManager.setWallpaperFromFile(filePath, location);

      if (success) {
        onSuccess?.call('Wallpaper set successfully');
      } else {
        onError?.call('Failed to set wallpaper');
      }

      return success;
    } catch (e) {
      _handleError(e, onError);
      return false;
    }
  }

  /// Retrieves the file path for storing the wallpaper.
  ///
  /// [item] The content item containing wallpaper details.
  /// Returns the file path as a string.
  Future<String> _getWallpaperFilePath(ContentItem item) async {
    final appPath = await _fileUtils.getTemporaryDirectoryPath();
    return _fileUtils.getWallpaperFilePath(
      basePath: appPath,
      sourceName: item.source.name,
    );
  }

  /// Downloads the wallpaper if it doesn't already exist.
  ///
  /// [item] The content item containing wallpaper details.
  /// [filePath] The destination path for the wallpaper file.
  /// [onProgress] Optional callback for download progress updates.
  /// Returns the File object for the wallpaper.
  Future<File> _downloadWallpaperIfNeeded({
    required ContentItem item,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      await _dio.download(
        SMA.formatImage(image: item.thumbnailUrl, baseUrl: item.source.url),
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
    }
    return file;
  }

  /// Displays a snackbar with the result of the wallpaper operation.
  ///
  /// [context] The BuildContext for showing the snackbar.
  /// [message] The message to display in the snackbar.
  void showWallpaperResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.black.withOpacity(_snackBarOpacity),
        duration: _snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_snackBarBorderRadius),
        ),
        margin: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).size.height * _snackBarBottomMarginFactor,
          left: _snackBarHorizontalMargin,
          right: _snackBarHorizontalMargin,
        ),
      ),
    );
  }

  /// Handles errors by invoking the error callback and logging in debug mode.
  ///
  /// [error] The error that occurred.
  /// [onError] Optional callback to handle the error message.
  void _handleError(Object error, Function(String)? onError) {
    final errorMessage = error.toString();
    onError?.call(errorMessage);
    if (kDebugMode) {
      print('WallpaperService error: $errorMessage');
    }
  }
}
