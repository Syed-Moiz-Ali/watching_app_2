import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/global/app_global.dart';
import 'package:watching_app_2/models/content_source.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

import '../../models/content_item.dart';
import '../../widgets/custom_image_widget.dart';

class MinimalistWallpaperDetail extends StatefulWidget {
  final ContentItem item;

  const MinimalistWallpaperDetail({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  _MinimalistWallpaperDetailState createState() =>
      _MinimalistWallpaperDetailState();
}

class _MinimalistWallpaperDetailState extends State<MinimalistWallpaperDetail>
    with TickerProviderStateMixin {
  // Core animation controllers
  late AnimationController _imageAnimationController;
  late AnimationController _interfaceController;
  late AnimationController _actionButtonController;

  // Animation sequences
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _imageOpacityAnimation;
  late Animation<double> _interfaceOpacityAnimation;
  late Animation<double> _actionsSlideAnimation;

  // State variables
  bool _interfaceVisible = true;
  bool _isDownloading = false;
  bool isWallpaperSetting = false;

  // Gesture values for parallax effect
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  final Dio dio = Dio();

  // Future<void> requestPermissions() async {
  //   if (Platform.isAndroid) {
  //     if (int.parse(Platform.version.split('.')[0]) >= 13) {
  //       // Android 13+ uses more granular media permissions
  //       if (await Permission.photos.request().isGranted) {
  //         return;
  //       }
  //     } else if (int.parse(Platform.version.split('.')[0]) >= 11) {
  //       // Android 11+ uses scoped storage
  //       if (await Permission.storage.request().isGranted) {
  //         return;
  //       }
  //     } else {
  //       // Android 10 and below use traditional storage permissions
  //       if (await Permission.storage.request().isGranted) {
  //         return;
  //       }
  //     }

  //     throw PlatformException(
  //       code: 'PERMISSION_DENIED',
  //       message: 'Storage permission is required to download wallpapers',
  //     );
  //   }
  // }

  Future<void> downloadWallpaper() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Request permissions first
      await requestPermissions();

      // Get the downloads directory using proper methods
      late String downloadPath;

      if (Platform.isAndroid) {
        // For Android 10+ (API 29+), we need to use MediaStore API approach
        if (await _isAndroid10OrAbove()) {
          // Use the Downloads folder with ContentResolver on Android 10+
          downloadPath = (await getExternalStorageDirectory())!.path;

          // Download the file to getExternalStorageDirectory first
          String tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          String tempFilePath = '$downloadPath/$tempFileName';

          await dio.download(
            widget.item.thumbnailUrl,
            tempFilePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                print('${(received / total * 100).toStringAsFixed(0)}%');
              }
            },
          );

          // Save to MediaStore/Gallery which user can access in Downloads
          final result = await ImageGallerySaver.saveFile(
            tempFilePath,
            name:
                '${widget.item.source.name}_${DateTime.now().millisecondsSinceEpoch}',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wallpaper saved to Downloads folder')),
          );
          return;
        } else {
          // For Android 9 and below, we can use the direct path
          // downloadPath = '/storage/emulated/0/Download';
          downloadPath = (await getExternalStorageDirectory())!.path;
        }
      } else {
        // For iOS or other platforms
        final directory = await getApplicationDocumentsDirectory();
        downloadPath = directory.path;
      }

      // Create the custom directory structure
      String customDirPath =
          '$downloadPath/${_getAppName()}/${widget.item.source.name}';
      Directory customDir = Directory(customDirPath);
      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }

      // Download the file to our custom path
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = '$customDirPath/$fileName';

      await dio.download(
        widget.item.thumbnailUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      log('message: $filePath');

      // Also save to gallery so user can find it easily
      final result = await ImageGallerySaver.saveFile(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallpaper saved to $filePath')),
      );
    } catch (e) {
      print('Error downloading wallpaper: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to download wallpaper: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

// Helper function to check Android version
  Future<bool> _isAndroid10OrAbove() async {
    if (Platform.isAndroid) {
      String release = await _getAndroidVersion();
      int version = int.tryParse(release) ?? 0;
      return version >= 10;
    }
    return false;
  }

  Future<String> _getAndroidVersion() async {
    try {
      return Platform.operatingSystemVersion.split(' ').last;
    } catch (e) {
      return '0';
    }
  }

// Add this function for proper permission handling
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Check Android version
      bool isAndroid10Plus = await _isAndroid10OrAbove();
      bool isAndroid13Plus = await _isAndroid13OrAbove();

      if (isAndroid13Plus) {
        // For Android 13+, request media permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.storage,
        ].request();

        if (statuses[Permission.photos] != PermissionStatus.granted ||
            statuses[Permission.storage] != PermissionStatus.granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Storage permission is required to download wallpapers',
          );
        }
      } else if (isAndroid10Plus) {
        // For Android 10-12, request storage permission
        if (await Permission.storage.request() != PermissionStatus.granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Storage permission is required to download wallpapers',
          );
        }
      } else {
        // For Android 9 and below
        if (await Permission.storage.request() != PermissionStatus.granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Storage permission is required to download wallpapers',
          );
        }
      }
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      String release = await _getAndroidVersion();
      int version = int.tryParse(release) ?? 0;
      return version >= 13;
    }
    return false;
  }

  String _getAppName() {
    return 'PornQueen'; // Use your app's name here
  }

  Future<void> _applyWallpaper(int location) async {
    setState(() {
      isWallpaperSetting = true;
    });

    try {
      // Request permissions first
      await requestPermissions();

      // Get the app's directory
      Directory? appDocDir = await getTemporaryDirectory();
      String appPath = appDocDir.path;

      // Use the same directory structure for consistency
      String customDirPath =
          '$appPath/downloads/${_getAppName()}/${widget.item.source.name}';
      Directory customDir = Directory(customDirPath);
      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }

      String fileName = '${DateTime.now().toIso8601String()}.jpg';
      String filePath = '$customDirPath/$fileName';

      // Download if not already downloaded
      File file = File(filePath);
      if (!await file.exists()) {
        await dio.download(
          widget.item.thumbnailUrl,
          filePath,
        );
      }
      // Set the wallpaper
      final result =
          await WallpaperManager.setWallpaperFromFile(filePath, location);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wallpaper set successfully')),
        );
      } else {
        throw Exception('Failed to set wallpaper');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting wallpaper: ${e.toString()}')),
      );
      setState(() {
        isWallpaperSetting = true;
      });
    } finally {
      setState(() {
        isWallpaperSetting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Subtle, elegant image animation
    _imageAnimationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat(reverse: true);

    _imageScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
    ]).animate(_imageAnimationController);

    _imageOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.97)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
    ]).animate(_imageAnimationController);

    // UI Interface fade animation
    _interfaceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _interfaceOpacityAnimation = CurvedAnimation(
      parent: _interfaceController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // Initially visible UI
    _interfaceController.value = 1.0;

    // Action buttons animation
    _actionButtonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _actionsSlideAnimation = CurvedAnimation(
      parent: _actionButtonController,
      curve: Curves.easeOutQuint,
    );
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    _interfaceController.dispose();
    _actionButtonController.dispose();
    super.dispose();
  }

  void _toggleInterface() {
    setState(() {
      _interfaceVisible = !_interfaceVisible;

      if (_interfaceVisible) {
        _interfaceController.forward();
      } else {
        _interfaceController.reverse();
      }
    });
  }

  void _updateParallaxEffect(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Create subtle parallax effect
    setState(() {
      _offsetX = (details.globalPosition.dx / screenWidth - 0.5) * 15;
      _offsetY = (details.globalPosition.dy / screenHeight - 0.5) * 15;
    });
  }

  void _resetParallax() {
    setState(() {
      _offsetX = 0.0;
      _offsetY = 0.0;
    });
  }

  void _downloadWallpaper() {
    downloadWallpaper();
  }

  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.HOME_SCREEN);
                      // _showMinimalistFeedback('Set as Home Screen');
                    },
                  ),
                  _buildOptionButton(
                    icon: Icons.lock_outlined,
                    label: 'Lock',
                    onTap: () {
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.LOCK_SCREEN);
                      // _showMinimalistFeedback('Set as Lock Screen');
                    },
                  ),
                  _buildOptionButton(
                    icon: Icons.smartphone_outlined,
                    label: 'Both',
                    onTap: () {
                      Navigator.pop(context);
                      _showMinimalistFeedback('Set to Both Screens');
                      _applyWallpaper(WallpaperManager.BOTH_SCREEN);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMinimalistFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: GestureDetector(
          onTap: _toggleInterface,
          onPanUpdate: _updateParallaxEffect,
          onPanEnd: (_) => _resetParallax(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Animated wallpaper with subtle parallax effect
              Hero(
                tag: 'wallpaper-${widget.item.thumbnailUrl}',
                child: AnimatedBuilder(
                  animation: _imageAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_offsetX, _offsetY),
                      child: Transform.scale(
                        scale: _imageScaleAnimation.value,
                        child: Opacity(
                          opacity: _imageOpacityAnimation.value,
                          child: CustomImageWidget(
                            imagePath: SMA.formatImage(
                              image: widget.item.thumbnailUrl,
                              baseUrl: widget.item.source.url,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Subtle gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),

              // Interface elements
              AnimatedBuilder(
                animation: _interfaceController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _interfaceOpacityAnimation.value,
                    child: Stack(
                      children: [
                        // Minimal top bar
                        Positioned(
                          top: MediaQuery.of(context).padding.top,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                // Minimalist back button
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 22,
                                  ),
                                  color: Colors.white,
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),

                        // Minimal action buttons
                        Positioned(
                          bottom: 50,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: _actionsSlideAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  50 * (1 - _actionsSlideAnimation.value),
                                ),
                                child: Opacity(
                                  opacity: _actionsSlideAnimation.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Set as wallpaper button
                                _buildActionButton(
                                  icon: Icons.wallpaper,
                                  label: 'Apply',
                                  primary: true,
                                  onTap: _showWallpaperOptions,
                                  isLoading: isWallpaperSetting,
                                ),
                                const SizedBox(width: 20),
                                // Download button
                                _buildActionButton(
                                  icon: Icons.download_outlined,
                                  label: 'Save',
                                  primary: false,
                                  onTap: _downloadWallpaper,
                                  isLoading: _isDownloading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool primary,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color:
                primary ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
