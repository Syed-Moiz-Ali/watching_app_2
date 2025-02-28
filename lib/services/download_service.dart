import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../utils/file_utils.dart';
import '../../models/content_item.dart';
import '../services/permission_service.dart';

class DownloadService {
  // Singleton pattern
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio dio = Dio();
  final FileUtils fileUtils = FileUtils();
  final PermissionService permissionService = PermissionService();

  /// Download wallpaper and save it to device storage
  Future<void> downloadWallpaper(ContentItem item,
      {Function(double)? onProgress,
      Function(String)? onSuccess,
      Function(String)? onError}) async {
    try {
      // Request permissions first
      await permissionService.requestStoragePermissions();

      // Get download path
      String downloadPath = await fileUtils.getTemporaryDirectoryPath();

      // Generate file path
      String filePath = await fileUtils.getWallpaperFilePath(
        basePath: downloadPath,
        sourceName: item.source.name,
      );

      // Download the file
      await dio.download(
        item.thumbnailUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      // Also save to gallery so user can find it easily
      await ImageGallerySaver.saveFile(
        filePath,
        name: '${item.source.name}_${DateTime.now().millisecondsSinceEpoch}',
      );

      onSuccess?.call(filePath);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Show a snackbar with download result
  void showDownloadResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
