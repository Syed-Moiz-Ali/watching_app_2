// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
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
  // Core animation controllers
  late AnimationController _imageAnimationController;
  late AnimationController _interfaceController;
  late AnimationController _actionButtonController;
  DownloadService downloadService = DownloadService();
  WallpaperService wallpaperService = WallpaperService();

  // Animation sequences
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _interfaceOpacityAnimation;
  late Animation<double> _actionsSlideAnimation;

  // State variables
  bool _interfaceVisible = true;
  bool _isDownloading = false;
  bool _isWallpaperSetting = false;

  // Theming constants
  final Color _accentColor = AppColors.primaryColor;

  // Animation timing configuration
  final Duration _entranceAnimationDuration = const Duration(milliseconds: 600);
  final Duration _interfaceToggleDuration = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();

    // Subtle breathing effect for wallpaper
    _imageAnimationController = AnimationController(
      duration: const Duration(seconds: 100),
      vsync: this,
    )..repeat(reverse: true);

    _imageScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

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
      curve: Curves.easeOutCubic,
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

  void _downloadWallpaper() async {
    setState(() {
      _isDownloading = true;
    });

    await downloadService.downloadWallpaper(widget.item,
        onProgress: (double progress) {
      // Progress handling if needed
    }, onSuccess: (String filePath) {
      setState(() {
        _isDownloading = false;
      });
      _showFeedback(
        'Wallpaper saved to gallery',
        Icons.check_circle_outlined,
        _accentColor,
      );
    }, onError: (String error) {
      setState(() {
        _isDownloading = false;
      });
      _showFeedback(
        'Error saving wallpaper',
        Icons.error_outline_rounded,
        Colors.redAccent,
      );
    });
  }

  void _applyWallpaper(int location) {
    setState(() {
      _isWallpaperSetting = true;
    });

    wallpaperService.applyWallpaper(widget.item, location,
        onProgress: (progress) {
      setState(() {
        _isWallpaperSetting = true;
      });
    }, onSuccess: (String message) {
      setState(() {
        _isWallpaperSetting = false;
      });
      _showFeedback(
        message,
        Icons.check_circle_outlined,
        _accentColor,
      );
    }, onError: (String error) {
      setState(() {
        _isWallpaperSetting = false;
      });
      _showFeedback(
        error,
        Icons.error_outline_rounded,
        Colors.redAccent,
      );
    });
  }

  void _showWallpaperOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              TextWidget(
                text: "Set wallpaper as",
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
              const SizedBox(height: 32),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    icon: Icons.home_outlined,
                    label: 'Home Screen',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.HOME_SCREEN);
                    },
                  ),
                  _buildOptionButton(
                    icon: Icons.lock_outlined,
                    label: 'Lock Screen',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.LOCK_SCREEN);
                    },
                  ),
                  _buildOptionButton(
                    icon: Icons.smartphone_outlined,
                    label: 'Both Screens',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperManager.BOTH_SCREEN);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
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
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            TextWidget(
              text: label,
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedback(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            TextWidget(
              text: message,
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.08,
          left: 48,
          right: 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper image with subtle animation
              _buildWallpaperImage(),

              // Gradient overlay for better text readability
              _buildGradientOverlay(),

              // UI Interface elements
              _buildInterface(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWallpaperImage() {
    return Hero(
      tag: 'wallpaper-${widget.item.thumbnailUrl}',
      child: AnimatedBuilder(
        animation: _imageAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _imageScaleAnimation.value,
            child: ImageWidget(
              imagePath: SMA.formatImage(
                image: widget.item.thumbnailUrl,
                baseUrl: widget.item.source.url,
              ),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.0, 0.2, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildInterface() {
    return AnimatedBuilder(
      animation: _interfaceController,
      builder: (context, child) {
        return Opacity(
          opacity: _interfaceOpacityAnimation.value,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Top app bar
              _buildTopBar(),

              // Wallpaper metadata (if available)
              if (widget.item.title.isNotEmpty) _buildMetadata(),

              // Bottom action buttons
              _buildActionBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Back button
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(-16 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
            const Spacer(),
            // Favorite button
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(16 * (1 - value), 0),
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
              // _buildIconButton(
              //   icon: _isFavorite
              //       ? Icons.favorite_rounded
              //       : Icons.favorite_border_rounded,
              //   color: _isFavorite ? Colors.redAccent : Colors.white,
              //   onTap: _toggleFavorite,
              // ),
            ),
            const SizedBox(width: 12),
            // Share button
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(16 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildIconButton(
                icon: Icons.share_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showFeedback(
                    'Sharing wallpaper...',
                    Icons.share_rounded,
                    Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildMetadata() {
    return Positioned(
      bottom: 140,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _actionsSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              30 * (1 - _actionsSlideAnimation.value),
            ),
            child: Opacity(
              opacity: _actionsSlideAnimation.value,
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: widget.item.title,
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              maxLine: 2,
            ),
            if (widget.item.source.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextWidget(
                  text: 'From ${widget.item.source.name}',
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Positioned(
      bottom: 40,
      left: 16,
      right: 16,
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
            Expanded(
              child: _buildActionButton(
                icon: Icons.wallpaper_rounded,
                label: 'Apply',
                isPrimary: true,
                isLoading: _isWallpaperSetting,
                onTap: _showWallpaperOptions,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.download_rounded,
                label: 'Save',
                isPrimary: false,
                isLoading: _isDownloading,
                onTap: _downloadWallpaper,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary ? _accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary ? _accentColor : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary ? Colors.white : Colors.white70,
                    ),
                  ),
                )
              else
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : Colors.white70,
                  size: 18,
                ),
              const SizedBox(width: 8),
              TextWidget(
                text: label,
                color: isPrimary ? Colors.white : Colors.white70,
                fontSize: 15.sp,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
