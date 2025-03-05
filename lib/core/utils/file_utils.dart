import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  // Singleton pattern
  static final FileUtils _instance = FileUtils._internal();
  factory FileUtils() => _instance;
  FileUtils._internal();

  /// App name for file organization
  final String appName =
      'PornQueen'; // Should be configurable from a central place

  /// Get download directory path based on platform
  Future<String> getDownloadDirectoryPath() async {
    final platformUtils = PlatformUtils();

    if (Platform.isAndroid) {
      if (await platformUtils.isAndroid10OrAbove()) {
        // For Android 10+, use the app's external storage directory
        return (await getExternalStorageDirectory())!.path;
      } else {
        // For Android 9 and below
        return (await getExternalStorageDirectory())!.path;
      }
    } else {
      // For iOS or other platforms
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  /// Get temporary directory path
  Future<String> getTemporaryDirectoryPath() async {
    Directory appDocDir = await getTemporaryDirectory();
    return appDocDir.path;
  }

  /// Create a directory if it doesn't exist
  Future<Directory> createDirectoryIfNotExists(String path) async {
    Directory directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Generate wallpaper file path for specific source
  Future<String> getWallpaperFilePath({
    required String basePath,
    required String sourceName,
    String extension = 'jpg',
  }) async {
    // Create custom directory structure
    String customDirPath = '$basePath/$appName/$sourceName';
    await createDirectoryIfNotExists(customDirPath);

    // Generate unique filename
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    return '$customDirPath/$fileName';
  }
}

class PlatformUtils {
  // Singleton pattern
  static final PlatformUtils _instance = PlatformUtils._internal();
  factory PlatformUtils() => _instance;
  PlatformUtils._internal();

  /// Check if device is running Android 10 or above
  Future<bool> isAndroid10OrAbove() async {
    if (Platform.isAndroid) {
      String release = await getAndroidVersion();
      int version = int.tryParse(release) ?? 0;
      return version >= 10;
    }
    return false;
  }

  /// Get Android version as a string
  Future<String> getAndroidVersion() async {
    try {
      return Platform.operatingSystemVersion.split(' ').last;
    } catch (e) {
      return '0';
    }
  }
}
