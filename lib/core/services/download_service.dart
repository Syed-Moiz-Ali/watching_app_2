import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:watching_app_2/core/global/globals.dart';
import '../../shared/widgets/misc/text_widget.dart';
import '../utils/file_utils.dart';
import '../../data/models/content_item.dart';
import 'permission_service.dart';

/// Service for handling wallpaper downloads and saving to device storage.
class DownloadService {
  // Singleton pattern
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

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

  /// Downloads a wallpaper and saves it to device storage and gallery.
  ///
  /// [item] The content item containing wallpaper details.
  /// [onProgress] Optional callback for download progress updates.
  /// [onSuccess] Optional callback for successful download with file path.
  /// [onError] Optional callback for error handling.
  Future<void> downloadWallpaper(
    ContentItem item, {
    Function(double)? onProgress,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Request storage permissions
      await _permissionService.requestStoragePermissions();

      // Get file path for download
      final filePath = await _getDownloadFilePath(item);

      // Download the wallpaper
      await _downloadFile(item, filePath, onProgress);

      // Save to gallery
      await _saveToGallery(filePath, item.source.name);

      onSuccess?.call(filePath);
    } catch (e) {
      _handleError(e, onError);
    }
  }

  /// Retrieves the file path for downloading the wallpaper.
  ///
  /// [item] The content item containing wallpaper details.
  /// Returns the file path as a string.
  Future<String> _getDownloadFilePath(ContentItem item) async {
    final downloadPath = await _fileUtils.getTemporaryDirectoryPath();
    return _fileUtils.getWallpaperFilePath(
      basePath: downloadPath,
      sourceName: item.source.name,
    );
  }

  /// Downloads the wallpaper file from the provided URL.
  ///
  /// [item] The content item containing wallpaper details.
  /// [filePath] The destination path for the downloaded file.
  /// [onProgress] Optional callback for download progress updates.
  Future<void> _downloadFile(
    ContentItem item,
    String filePath,
    Function(double)? onProgress,
  ) async {
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

  /// Saves the downloaded file to the device gallery.
  ///
  /// [filePath] The path of the downloaded file.
  /// [sourceName] The name of the source for naming the file in the gallery.
  Future<void> _saveToGallery(String filePath, String sourceName) async {
    await ImageGallerySaver.saveFile(
      filePath,
      name: '${sourceName}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Displays a snackbar with the download result.
  ///
  /// [context] The BuildContext for showing the snackbar.
  /// [message] The message to display in the snackbar.
  void showDownloadResult(BuildContext context, String message) {
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
      print('DownloadService error: $errorMessage');
    }
  }
}
