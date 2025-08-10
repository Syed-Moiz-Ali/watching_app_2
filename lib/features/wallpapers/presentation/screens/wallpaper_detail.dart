// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'dart:ui';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:watching_app_2/core/services/download_service.dart';
import 'package:watching_app_2/core/services/wallpaper_service.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';

import '../../../../data/models/content_item.dart';
import '../../../../shared/screens/favorites/favorite_button.dart';
import '../../../../shared/widgets/misc/image.dart';

class MinimalistWallpaperDetail extends StatefulWidget {
  final ContentItem item;

  const MinimalistWallpaperDetail({
    super.key,
    required this.item,
  });

  @override
  _MinimalistWallpaperDetailState createState() =>
      _MinimalistWallpaperDetailState();
}

class _MinimalistWallpaperDetailState extends State<MinimalistWallpaperDetail>
    with TickerProviderStateMixin {
  // Enhanced animation controllers
  late AnimationController _imageAnimationController;
  late AnimationController _interfaceController;
  late AnimationController _actionButtonController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  // Services
  DownloadService downloadService = DownloadService();
  WallpaperService wallpaperService = WallpaperService();

  // Enhanced animation sequences
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _interfaceOpacityAnimation;
  late Animation<double> _actionsSlideAnimation;
  late Animation<Offset> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _blurAnimation;

  // State variables
  bool _interfaceVisible = true;
  bool _isDownloading = false;
  bool _isWallpaperSetting = false;
  double _downloadProgress = 0.0;

  // Enhanced theming
  final Color _accentColor = AppColors.primaryColor;
  final Color _surfaceColor = Colors.black.withOpacity(0.6);

  // Timing configuration
  final Duration _entranceAnimationDuration = const Duration(milliseconds: 800);
  final Duration _interfaceToggleDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupAutoHide();
  }

  void _initializeAnimations() {
    // Enhanced breathing effect for wallpaper
    _imageAnimationController = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    )..repeat(reverse: true);

    _imageScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _imageAnimationController,
      curve: Curves.easeInOutSine,
    ));

    // Floating animation for subtle UI movement
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.008),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.008),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_floatingController);

    // Pulse animation for active states
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Enhanced UI Interface animation
    _interfaceController = AnimationController(
      duration: _interfaceToggleDuration,
      vsync: this,
    );

    _interfaceOpacityAnimation = CurvedAnimation(
      parent: _interfaceController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Blur animation for background
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _interfaceController,
      curve: Curves.easeOutCubic,
    ));

    // Initially visible UI
    _interfaceController.value = 1.0;

    // Enhanced action buttons animation
    _actionButtonController = AnimationController(
      duration: _entranceAnimationDuration,
      vsync: this,
    )..forward();

    _actionsSlideAnimation = CurvedAnimation(
      parent: _actionButtonController,
      curve: Curves.easeOutBack,
    );
  }

  void _setupAutoHide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _interfaceVisible) {
        _toggleInterface();
      }
    });
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    _interfaceController.dispose();
    _actionButtonController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleInterface() {
    setState(() {
      _interfaceVisible = !_interfaceVisible;

      if (_interfaceVisible) {
        _interfaceController.forward();
        _setupAutoHide();
      } else {
        _interfaceController.reverse();
      }
    });
  }

  void _downloadWallpaper() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    _pulseController.repeat(reverse: true);

    await downloadService.downloadWallpaper(
      widget.item,
      onProgress: (double progress) {
        setState(() {
          _downloadProgress = progress;
        });
      },
      onSuccess: (String filePath) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 1.0;
        });
        _pulseController.stop();
        _showEnhancedFeedback(
          'Wallpaper saved to gallery',
          Icons.check_circle_rounded,
          Colors.green,
          success: true,
        );
      },
      onError: (String error) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
        _pulseController.stop();
        _showEnhancedFeedback(
          'Error saving wallpaper',
          Icons.error_rounded,
          Colors.red,
          success: false,
        );
      },
    );
  }

  void _applyWallpaper(int location) {
    setState(() {
      _isWallpaperSetting = true;
    });

    _pulseController.repeat(reverse: true);

    wallpaperService.applyWallpaper(
      widget.item,
      location,
      onProgress: (progress) {
        setState(() {
          _isWallpaperSetting = true;
        });
      },
      onSuccess: (String message) {
        setState(() {
          _isWallpaperSetting = false;
        });
        _pulseController.stop();
        _showEnhancedFeedback(
          message,
          Icons.wallpaper_rounded,
          _accentColor,
          success: true,
        );
      },
      onError: (String error) {
        setState(() {
          _isWallpaperSetting = false;
        });
        _pulseController.stop();
        _showEnhancedFeedback(
          error,
          Icons.error_rounded,
          Colors.red,
          success: false,
        );
      },
    );
  }

  void _showEnhancedWallpaperOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[900]!.withOpacity(0.95),
                Colors.black.withOpacity(0.98),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced drag indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[600]!,
                      Colors.grey[400]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Enhanced title with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.wallpaper_rounded,
                      color: _accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextWidget(
                    text: "Set wallpaper as",
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Enhanced options with better spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEnhancedOptionButton(
                    icon: Icons.home_rounded,
                    label: 'Home Screen',
                    color: Colors.blue,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.HOME_SCREEN);
                    },
                  ),
                  _buildEnhancedOptionButton(
                    icon: Icons.lock_rounded,
                    label: 'Lock Screen',
                    color: Colors.green,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.LOCK_SCREEN);
                    },
                  ),
                  _buildEnhancedOptionButton(
                    icon: Icons.smartphone_rounded,
                    label: 'Both Screens',
                    color: _accentColor,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.BOTH_SCREEN);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            TextWidget(
              text: label,
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showEnhancedFeedback(String message, IconData icon, Color color,
      {bool success = true}) {
    // log("qwertyuiowertyui");
    ScaffoldMessenger.of(SMA.navigationKey.currentContext!)
        .hideCurrentSnackBar();
    ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: message,
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.grey[900]!.withOpacity(0.95),
        duration: Duration(seconds: success ? 2 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 32,
          right: 32,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: InteractiveViewer(
          clipBehavior: Clip.none,
          child: GestureDetector(
            onTap: _toggleInterface,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Enhanced wallpaper image
                _buildEnhancedWallpaperImage(),

                // Dynamic gradient overlay
                _buildDynamicGradientOverlay(),

                // Enhanced UI Interface
                _buildEnhancedInterface(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedWallpaperImage() {
    return Hero(
      tag: 'wallpaper-${widget.item.thumbnailUrl}',
      child: AnimatedBuilder(
        animation:
            Listenable.merge([_imageAnimationController, _floatingController]),
        builder: (context, child) {
          return Transform.translate(
            offset: _floatingAnimation.value * 15,
            child: Transform.scale(
              scale: _imageScaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ImageWidget(
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
    );
  }

  Widget _buildDynamicGradientOverlay() {
    return AnimatedBuilder(
      animation: _interfaceController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(
                    0.3 + (0.2 * _interfaceOpacityAnimation.value)),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(
                    0.5 + (0.3 * _interfaceOpacityAnimation.value)),
              ],
              stops: const [0.0, 0.25, 0.65, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedInterface() {
    return AnimatedBuilder(
      animation: Listenable.merge([_interfaceController, _floatingController]),
      builder: (context, child) {
        return Opacity(
          opacity: _interfaceOpacityAnimation.value,
          child: Transform.translate(
            offset: _floatingAnimation.value * 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Enhanced top bar
                _buildEnhancedTopBar(),

                // Enhanced metadata
                if (widget.item.title.isNotEmpty) _buildEnhancedMetadata(),

                // Enhanced action bar
                _buildEnhancedActionBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildEnhancedIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),

            const Spacer(),

            // Enhanced title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wallpaper_rounded,
                    color: _accentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  TextWidget(
                    text: 'Wallpaper',
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Action buttons group
            Row(
              children: [
                // Favorite button
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: FavoriteButton(
                    item: widget.item,
                    contentType: ContentTypes.IMAGE,
                    isGrid: true,
                  ),
                ),

                const SizedBox(width: 8),

                // Share button
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildEnhancedIconButton(
                    icon: Icons.share_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showEnhancedFeedback(
                        'Sharing wallpaper...',
                        Icons.share_rounded,
                        _accentColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withOpacity(0.2),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMetadata() {
    return Positioned(
      bottom: 160,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _actionsSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              40 * (1 - _actionsSlideAnimation.value),
            ),
            child: Opacity(
              opacity: _actionsSlideAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: widget.item.title,
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      maxLine: 2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: _accentColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
              if (widget.item.source.name.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.source_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    TextWidget(
                      text: 'From ${widget.item.source.name}',
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hd_rounded,
                            color: Colors.green,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          TextWidget(
                            text: 'HD',
                            color: Colors.green,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedActionBar() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _actionsSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              60 * (1 - _actionsSlideAnimation.value),
            ),
            child: Opacity(
              opacity: _actionsSlideAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildEnhancedActionButton(
                  icon: Icons.wallpaper_rounded,
                  label: 'Apply',
                  isPrimary: true,
                  isLoading: _isWallpaperSetting,
                  onTap: _showEnhancedWallpaperOptions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedActionButton(
                  icon: Icons.download_rounded,
                  label: _isDownloading
                      ? '${(_downloadProgress * 100).toInt()}%'
                      : 'Save',
                  isPrimary: false,
                  isLoading: _isDownloading,
                  progress: _downloadProgress,
                  onTap: _downloadWallpaper,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isLoading,
    double progress = 0.0,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: isLoading ? _pulseAnimation.value : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor:
                  (isPrimary ? Colors.white : _accentColor).withOpacity(0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: isPrimary
                      ? LinearGradient(
                          colors: [_accentColor, _accentColor.withOpacity(0.8)],
                        )
                      : null,
                  color: isPrimary ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isPrimary
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Progress indicator background
                    if (isLoading && progress > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              stops: [progress, progress],
                              colors: [
                                (isPrimary ? Colors.white : _accentColor)
                                    .withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Button content
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: progress > 0 ? progress : null,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isPrimary ? Colors.white : _accentColor,
                              ),
                            ),
                          )
                        else
                          Icon(
                            icon,
                            color: isPrimary
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                        const SizedBox(width: 10),
                        TextWidget(
                          text: label,
                          color: isPrimary
                              ? Colors.white
                              : Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
