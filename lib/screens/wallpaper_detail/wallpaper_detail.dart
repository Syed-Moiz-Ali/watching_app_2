// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/global/app_global.dart';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:watching_app_2/services/download_service.dart';
import 'package:watching_app_2/services/wallpaper_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching_app_2/widgets/text_widget.dart';

import '../../models/content_item.dart';
import '../../widgets/custom_image_widget.dart';

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
  // Core animation controllers
  late AnimationController _imageAnimationController;
  late AnimationController _interfaceController;
  late AnimationController _actionButtonController;
  late AnimationController _parallaxController;
  late AnimationController _pulseAnimationController;
  DownloadService downloadService = DownloadService();
  WallpaperService wallpaperService = WallpaperService();

  // Animation sequences
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _imageOpacityAnimation;
  late Animation<double> _interfaceOpacityAnimation;
  late Animation<double> _actionsSlideAnimation;
  late Animation<double> _pulseAnimation;

  // State variables
  bool _interfaceVisible = true;
  bool _isDownloading = false;
  bool isWallpaperSetting = false;
  String _downloadProgress = "0%";
  bool _isFavorite = false;

  // Gesture values for parallax effect
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  final Dio dio = Dio();

  // Action animation values
  double _applyButtonScale = 1.0;
  double _saveButtonScale = 1.0;

  // Animation timing configuration
  final Duration _entranceAnimationDuration = const Duration(milliseconds: 800);
  final Duration _buttonAnimationDuration = const Duration(milliseconds: 300);
  final Duration _interfaceToggleDuration = const Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();

    // Advanced breathing effect for wallpaper
    _imageAnimationController = AnimationController(
      duration: const Duration(seconds: 90),
      vsync: this,
    )..repeat(reverse: true);

    _imageScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
    ]).animate(_imageAnimationController);

    _imageOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
    ]).animate(_imageAnimationController);

    // Smooth UI Interface fade animation
    _interfaceController = AnimationController(
      duration: _interfaceToggleDuration,
      vsync: this,
    );

    _interfaceOpacityAnimation = CurvedAnimation(
      parent: _interfaceController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Initially visible UI
    _interfaceController.value = 1.0;

    // Action buttons animation with sequential timing
    _actionButtonController = AnimationController(
      duration: _entranceAnimationDuration,
      vsync: this,
    )..forward();

    _actionsSlideAnimation = CurvedAnimation(
      parent: _actionButtonController,
      curve: Curves.elasticOut,
    );

    // Parallax controller for advanced effects
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse animation for interactive elements
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Auto-hide interface after 5 seconds of inactivity
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
    _parallaxController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _toggleInterface() {
    setState(() {
      _interfaceVisible = !_interfaceVisible;

      if (_interfaceVisible) {
        _interfaceController.forward();
        // Auto-hide interface after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _interfaceVisible) {
            _toggleInterface();
          }
        });
      } else {
        _interfaceController.reverse();
      }
    });
  }

  void _updateParallaxEffect(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Enhanced parallax effect with more natural movement
    setState(() {
      _offsetX = (details.globalPosition.dx / screenWidth - 0.5) * 20;
      _offsetY = (details.globalPosition.dy / screenHeight - 0.5) * 20;
    });

    // Ensure interface is visible during interaction
    if (!_interfaceVisible) {
      _toggleInterface();
    }
  }

  void _resetParallax() {
    // Smooth reset with animation
    _parallaxController.reset();
    _parallaxController.forward().then((_) {
      setState(() {
        _offsetX = 0.0;
        _offsetY = 0.0;
      });
    });
  }

  void _downloadWallpaper() async {
    setState(() {
      _isDownloading = true;
      _saveButtonScale = 0.9; // Button press effect
    });

    // Animate button back to normal size
    Future.delayed(_buttonAnimationDuration, () {
      if (mounted) {
        setState(() {
          _saveButtonScale = 1.0;
        });
      }
    });

    await downloadService.downloadWallpaper(widget.item,
        onProgress: (double progress) {
      setState(() {
        _downloadProgress = "$progress%";
      });
    }, onSuccess: (String filePath) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = "0%";
      });
      _showEnhancedFeedback(
        'Wallpaper saved to gallery',
        Icons.check_circle_outline,
        Colors.green,
      );
    }, onError: (String error) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = "0%";
      });
      _showEnhancedFeedback(
        'Error saving wallpaper',
        Icons.error_outline,
        Colors.red,
      );
    });
  }

  _applyWallpaper(int location) {
    setState(() {
      isWallpaperSetting = true;
      _applyButtonScale = 0.9; // Button press effect
    });

    // Animate button back to normal size
    Future.delayed(_buttonAnimationDuration, () {
      if (mounted) {
        setState(() {
          _applyButtonScale = 1.0;
        });
      }
    });

    wallpaperService.applyWallpaper(widget.item, location,
        onProgress: (progress) {
      setState(() {
        isWallpaperSetting = true;
      });
    }, onSuccess: (String message) {
      setState(() {
        isWallpaperSetting = false;
      });
      _showEnhancedFeedback(
        message,
        Icons.check_circle_outline,
        Colors.green,
      );
    }, onError: (String error) {
      setState(() {
        isWallpaperSetting = false;
      });
      _showEnhancedFeedback(
        error,
        Icons.error_outline,
        Colors.red,
      );
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    _showEnhancedFeedback(
      _isFavorite ? 'Added to favorites' : 'Removed from favorites',
      _isFavorite ? Icons.favorite : Icons.favorite_border,
      Colors.red,
    );
  }

  void _showWallpaperOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7),
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.95),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 35),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              TextWidget(
                text: "Set wallpaper as",
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 30),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEnhancedOptionButton(
                    icon: Icons.home_outlined,
                    label: 'Home Screen',
                    delay: 0,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.HOME_SCREEN);
                    },
                  ),
                  _buildEnhancedOptionButton(
                    icon: Icons.lock_outlined,
                    label: 'Lock Screen',
                    delay: 100,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.LOCK_SCREEN);
                    },
                  ),
                  _buildEnhancedOptionButton(
                    icon: Icons.smartphone_outlined,
                    label: 'Both Screens',
                    delay: 200,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.BOTH_SCREEN);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
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
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            TextWidget(
              text: label,
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  void _showEnhancedFeedback(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            TextWidget(
              text: message,
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 40,
          right: 40,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 8,
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
        body: GestureDetector(
          onTap: _toggleInterface,
          onPanUpdate: _updateParallaxEffect,
          onPanEnd: (_) => _resetParallax(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Enhanced background with blur elements
              buildBackgroundElements(),

              // Advanced animated wallpaper with parallax effect
              Hero(
                tag: 'wallpaper-${widget.item.thumbnailUrl}',
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _imageAnimationController,
                    _pulseAnimationController,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_offsetX, _offsetY),
                      child: Transform.scale(
                        scale: _imageScaleAnimation.value,
                        child: Opacity(
                          opacity: _imageOpacityAnimation.value.clamp(0.0, 1.0),
                          child: _buildEnhancedImage(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Advanced gradient overlay with dynamic lighting effects
              buildGradientOverlay(),

              // Enhanced interface with beautiful animations
              buildInterface(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBackgroundElements() {
    return Stack(
      children: [
        // Base black background
        Container(color: Colors.black),

        // Dynamic light source effect
        Positioned(
          top: -100,
          right: -100,
          child: AnimatedBuilder(
            animation: _imageAnimationController,
            builder: (context, child) {
              return Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue
                          .withOpacity(0.3 * _imageOpacityAnimation.value),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedImage() {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.2),
          ],
          stops: const [0.0, 0.7, 0.8, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.srcATop,
      child: CustomImageWidget(
        imagePath: SMA.formatImage(
          image: widget.item.thumbnailUrl,
          baseUrl: widget.item.source.url,
        ),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildGradientOverlay() {
    return AnimatedBuilder(
      animation: _imageAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget buildInterface() {
    return AnimatedBuilder(
      animation: _interfaceController,
      builder: (context, child) {
        return Opacity(
          opacity: _interfaceOpacityAnimation.value.clamp(0.0, 1.0),
          child: Stack(
            children: [
              // Top bar with enhanced design
              buildTopBar(),

              // Metadata and title (optional)
              buildMetadata(),

              // Advanced glassmorphic action buttons
              buildActionBar(),
            ],
          ),
        );
      },
    );
  }

  Widget buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Enhanced back button with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Spacer(),
            // Additional actions
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _toggleFavorite();
                      },
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 20,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showEnhancedFeedback(
                          'Sharing wallpaper...',
                          Icons.share_rounded,
                          Colors.blue,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMetadata() {
    // Optional metadata section with wallpaper info
    if (widget.item.title.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 200,
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
              opacity: _actionsSlideAnimation.value * 0.8.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.item.title.isNotEmpty)
                TextWidget(
                  text: widget.item.title,
                  color: Colors.white,
                  fontSize: 20.sp,
                  maxLine: 4,
                  fontWeight: FontWeight.w600,
                ),
              const SizedBox(height: 6),
              if (widget.item.source.name.isNotEmpty)
                TextWidget(
                  text: 'From ${widget.item.source.name}',
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActionBar() {
    return Positioned(
      bottom: 5.h,
      left: 0,
      right: 0,
      child: buildGlassmorphicButtonBar(
        buildActionButtonsBar(context),
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
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: primary
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primary
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primary
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            primary ? Colors.white : Colors.white70),
                      ),
                    )
                  : TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Icon(
                            icon,
                            color: primary ? Colors.white : Colors.white70,
                            size: 22,
                          ),
                        );
                      },
                    ),
              const SizedBox(width: 12),
              TextWidget(
                text: label,
                color: primary ? Colors.white : Colors.white70,
                fontSize: 16.sp,
                fontWeight: primary ? FontWeight.w600 : FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Positioned component with enhanced animations
  Widget buildActionButtonsBar(BuildContext context) {
    return AnimatedBuilder(
      animation: _actionsSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            70 * (1 - _actionsSlideAnimation.value),
          ),
          child: Opacity(
            opacity: _actionsSlideAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Apply button
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(-30 * (1 - value), 0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: _buildActionButton(
                icon: Icons.wallpaper,
                label: 'Apply',
                primary: true,
                onTap: _showWallpaperOptions,
                isLoading: isWallpaperSetting,
              ),
            ),
            const SizedBox(width: 20),
            // Animated Save button
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              // delay: const Duration(milliseconds: 100),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(30 * (1 - value), 0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: _buildActionButton(
                icon: Icons.download_outlined,
                label: 'Save',
                primary: false,
                onTap: _downloadWallpaper,
                isLoading: _isDownloading,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add this glassmorphism container that you can use to wrap the buttons for a premium effect
  Widget buildGlassmorphicButtonBar(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
