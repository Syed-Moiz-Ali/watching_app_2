// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/misc/text_widget.dart';
import '../global/globals.dart';
import '../utils/file_utils.dart';
import '../../data/models/content_item.dart';
import 'permission_service.dart';

class WallpaperService {
  static final WallpaperService _instance = WallpaperService._internal();
  factory WallpaperService() => _instance;
  WallpaperService._internal();

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

  /// location:
  /// 1 = HOME
  /// 2 = LOCK
  /// 3 = BOTH
  Future<bool> applyWallpaper(
    ContentItem item,
  WallpaperLocation location, {
    Function(double)? onProgress,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      await _permissionService.requestStoragePermissions();

      final filePath = await _getWallpaperFilePath(item);

      await _downloadWallpaperIfNeeded(
        item: item,
        filePath: filePath,
        onProgress: onProgress,
      );

      final bool success = await _channel.invokeMethod(
        'setWallpaper',
        {
          'path': filePath,
          'location': location,
        },
      );

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

  Future<String> _getWallpaperFilePath(ContentItem item) async {
    final appPath = await _fileUtils.getTemporaryDirectoryPath();
    return _fileUtils.getWallpaperFilePath(
      basePath: appPath,
      sourceName: item.source.name,
    );
  }

  Future<File> _downloadWallpaperIfNeeded({
    required ContentItem item,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      await _dio.download(
        SMA.formatImage(
          image: item.thumbnailUrl,
          baseUrl: item.source.url,
        ),
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

  void _handleError(Object error, Function(String)? onError) {
    final errorMessage = error.toString();
    onError?.call(errorMessage);
    if (kDebugMode) {
      debugPrint('WallpaperService error: $errorMessage');
    }
  }
}




enum WallpaperLocation {
  home,
  lock,
  both,
}

extension WallpaperLocationExt on WallpaperLocation {
  /// Native Android mapping
  int get value {
    switch (this) {
      case WallpaperLocation.home:
        return 1;
      case WallpaperLocation.lock:
        return 2;
      case WallpaperLocation.both:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case WallpaperLocation.home:
        return 'Home Screen';
      case WallpaperLocation.lock:
        return 'Lock Screen';
      case WallpaperLocation.both:
        return 'Home & Lock Screen';
    }
  }
}
