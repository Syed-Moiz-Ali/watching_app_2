// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/misc/text_widget.dart';
import '../utils/file_utils.dart';
import '../../data/models/content_item.dart';
import '../global/globals.dart';
import 'permission_service.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  /// ✅ MUST MATCH MainActivity.kt
  static const MethodChannel _channel =
      MethodChannel('wallpaper_channel');

  final Dio _dio = Dio();
  final FileUtils _fileUtils = FileUtils();
  final PermissionService _permissionService = PermissionService();

  static const _snackBarDuration = Duration(seconds: 2);
  static const _snackBarOpacity = 0.7;
  static const _snackBarBorderRadius = 20.0;
  static const _snackBarBottomMarginFactor = 0.1;
  static const _snackBarHorizontalMargin = 50.0;

  Future<void> downloadWallpaper(
    ContentItem item, {
    Function(double)? onProgress,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      await _permissionService.requestStoragePermissions();

      final filePath = await _getDownloadFilePath(item);

      /// ✅ Avoid re-downloading if already exists
      if (!await File(filePath).exists()) {
        await _downloadFile(item, filePath, onProgress);
      }

      final bool saved = await _channel.invokeMethod(
        'saveToGallery',
        {
          'path': filePath,
          'name': item.source.name,
        },
      );

      if (saved) {
        onSuccess?.call(filePath);
      } else {
        onError?.call('Failed to save image');
      }
    } on PlatformException catch (e) {
      onError?.call(e.message ?? 'Platform error');
      if (kDebugMode) {
        debugPrint('PlatformException: ${e.code} ${e.message}');
      }
    } catch (e) {
      _handleError(e, onError);
    }
  }

  Future<String> _getDownloadFilePath(ContentItem item) async {
    final tempPath = await _fileUtils.getTemporaryDirectoryPath();
    return _fileUtils.getWallpaperFilePath(
      basePath: tempPath,
      sourceName: item.source.name,
    );
  }

  Future<void> _downloadFile(
    ContentItem item,
    String filePath,
    Function(double)? onProgress,
  ) async {
    await _dio.download(
      SMA.formatImage(
        image: item.thumbnailUrl,
        baseUrl: item.source.url,
      ),
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );
  }

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
              MediaQuery.of(context).size.height *
                  _snackBarBottomMarginFactor,
          left: _snackBarHorizontalMargin,
          right: _snackBarHorizontalMargin,
        ),
      ),
    );
  }

  void _handleError(Object error, Function(String)? onError) {
    final errorMessage = error.toString();
    onError?.call(errorMessage);
    if (kDebugMode) {
      debugPrint('DownloadService error: $errorMessage');
    }
  }
}
