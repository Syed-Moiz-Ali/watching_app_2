import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import '../../shared/widgets/misc/text_widget.dart';
import '../global/globals.dart';
import '../utils/file_utils.dart';
import '../../data/models/content_item.dart';
import 'permission_service.dart';

class WallpaperService {
  // Singleton pattern
  static final WallpaperService _instance = WallpaperService._internal();
  factory WallpaperService() => _instance;
  WallpaperService._internal();

  final Dio dio = Dio();
  final FileUtils fileUtils = FileUtils();
  final PermissionService permissionService = PermissionService();

  /// Apply wallpaper to device
  Future<bool> applyWallpaper(ContentItem item,
      int location, // WallpaperManager.HOME_SCREEN, LOCK_SCREEN, or BOTH_SCREEN
      {Function(double)? onProgress,
      Function(String)? onSuccess,
      Function(String)? onError}) async {
    try {
      // Request permissions first
      await permissionService.requestStoragePermissions();

      // Get temporary path for storing the wallpaper
      String appPath = await fileUtils.getTemporaryDirectoryPath();

      // Generate file path for the wallpaper
      String filePath = await fileUtils.getWallpaperFilePath(
        basePath: appPath,
        sourceName: item.source.name,
      );

      // Download if not already downloaded
      File file = File(filePath);
      if (!await file.exists()) {
        await dio.download(
          SMA.formatImage(image: item.thumbnailUrl, baseUrl: item.source.url),
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              onProgress?.call(progress);
            }
          },
        );
      }

      // Set the wallpaper
      onSuccess?.call('Wallpaper set successfully');

      return await WallpaperManager.setWallpaperFromFile(filePath, location);
    } catch (e) {
      onError?.call(e.toString());
      return false;
    }
  }

  /// Show a snackbar with wallpaper application result
  void showWallpaperResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 50,
          right: 50,
        ),
      ),
    );
  }
}
