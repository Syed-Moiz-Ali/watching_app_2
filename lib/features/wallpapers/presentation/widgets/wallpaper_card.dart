import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';
import '../../../../data/database/local_database.dart';
import '../../../../data/models/content_item.dart';
import '../../../../shared/screens/favorites/favorite_button.dart';
import '../../../../shared/widgets/misc/text_widget.dart';

class WallpaperCard extends StatefulWidget {
  final ContentItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isFavorite;
  final bool showActions;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final String? contentType;

  const WallpaperCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.onFavorite,
    this.onShare,
    this.isFavorite = false,
    this.showActions = true,
    this.aspectRatio = 0.75,
    this.borderRadius,
    this.contentType = ContentTypes.IMAGE,
  });

  @override
  State<WallpaperCard> createState() => _WallpaperCardState();
}

class _WallpaperCardState extends State<WallpaperCard>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isLoading = true;
  bool _isError = false;
  bool _isHovered = false;
  bool _showActions = false;
  String? _dominantColor;

  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _preloadImage();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 25.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.1),
      end: AppColors.primaryColor.withOpacity(0.4),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    if (widget.isFavorite) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _preloadImage() {
    final imageUrl = _getImageUrl();
    final imageProvider = NetworkImage(imageUrl);

    imageProvider.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) {
              if (mounted) {
                setState(() => _isLoading = false);
                _extractDominantColor(info.image);
              }
            },
            onError: (exception, stackTrace) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isError = true;
                });
              }
            },
          ),
        );
  }

  String _getImageUrl() {
    return widget.item.source.cdn != null &&
            widget.item.source.cdn.toString().isNotEmpty
        ? '${widget.item.source.cdn}${widget.item.thumbnailUrl}'.trim()
        : SMA.formatImage(
            image: widget.item.thumbnailUrl.toString().trim(),
            baseUrl: widget.item.source.url,
          );
  }

  Future<void> _extractDominantColor(ui.Image image) async {
    setState(() {
      _dominantColor = '#FF6B6B';
    });
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTapDown() {
    HapticFeedback.selectionClick();
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _toggleActions() {
    setState(() => _showActions = !_showActions);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          widget.onLongPress?.call();
          if (widget.showActions) _toggleActions();
        },
        child: Container(
          margin: EdgeInsets.all(1.5.w),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _pressController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.96 : _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              boxShadow: [
                // Primary shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value * 0.3),
                  spreadRadius: -2,
                ),
                // Glow effect
                BoxShadow(
                  color: AppColors.primaryColor
                      .withOpacity(0.2 * _glowAnimation.value),
                  blurRadius: _elevationAnimation.value * 1.5,
                  offset: Offset(0, _elevationAnimation.value * 0.2),
                  spreadRadius: 0,
                ),
                // Ambient shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: _elevationAnimation.value * 2,
                  offset: Offset(0, _elevationAnimation.value * 0.5),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: _buildCardContent(),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        border: Border.all(
          color: _borderColorAnimation.value ?? Colors.white.withOpacity(0.1),
          width: _isHovered ? 1.5 : 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            _buildBackground(),

            // Gradient overlays
            if (widget.contentType != ContentTypes.IMAGE)
              _buildGradientOverlay(),

            // Hover glow effect
            _buildHoverGlowEffect(),

            // Content
            if (widget.contentType != ContentTypes.IMAGE) _buildContent(),

            // Action buttons
            if (widget.showActions) _buildEnhancedActionButtons(),

            // Quality badge
            // if (widget.contentType == ContentTypes.IMAGE)
            //   _buildEnhancedQualityBadge(),

            // Premium badge for special content
            _buildPremiumBadge(),

            // Loading overlay
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (_isLoading) return _buildEnhancedShimmerEffect();
    if (_isError) return _buildEnhancedErrorWidget();

    return Hero(
      tag: 'wallpaper_${widget.item.scrapedAt.microsecondsSinceEpoch}',
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageWidget(
            imagePath: _getImageUrl(),
            fit: BoxFit.cover,
          ),
          // Subtle image enhancement overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.02),
                ],
              ),
            ),
          ),
        ],
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
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildHoverGlowEffect() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  AppColors.primaryColor
                      .withOpacity(0.1 * _glowAnimation.value),
                  AppColors.primaryColor
                      .withOpacity(0.05 * _glowAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.item.title.isNotEmpty) _buildEnhancedTitle(),
            // const SizedBox(height: 2),
            // _buildMetadataRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTitle() {
    return TextWidget(
      text: widget.item.title,
      color: Colors.white,
      fontSize: 15.sp,
      fontWeight: FontWeight.w700,
      maxLine: 2,
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(
        begin: 0.3,
        delay: 300.ms,
        duration: 500.ms,
        curve: Curves.easeOutCubic);
  }

  Widget _buildMetadataRow() {
    return Row(
      children: [
        _buildMetadataChip(
          icon: Icons.photo_size_select_actual,
          text: 'HD',
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 8),
        _buildMetadataChip(
          icon: Icons.favorite_outline,
          text: '2.1K',
          color: Colors.red,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified,
                color: Colors.green,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                'Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButtons() {
    return Positioned(
      top: 18,
      left: 18,
      child: Column(
        children: [
          FavoriteButton(
            item: widget.item,
            contentType: widget.contentType ?? ContentTypes.IMAGE,
            isGrid: true,
          ),
          const SizedBox(height: 10),
          _buildPremiumActionButton(
            icon: Icons.share_outlined,
            onTap: widget.onShare,
            color: Colors.blue,
          ),
          const SizedBox(height: 10),
          _buildPremiumActionButton(
            icon: Icons.download_outlined,
            onTap: () => _handleDownload(),
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          _buildPremiumActionButton(
            icon: Icons.info_outline,
            onTap: () => _showInfo(),
            color: Colors.orange,
          ),
        ],
      ),
    )
        .animate(target: _showActions ? 1 : 0)
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .slideX(begin: -1, duration: 350.ms, curve: Curves.easeOutBack);
  }

  Widget _buildPremiumActionButton({
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 200.ms);
  }

  Widget _buildEnhancedQualityBadge() {
    return Positioned(
      top: 18,
      right: 18,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.diamond_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'HD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(target: _isLoading ? 0 : 1)
        .fadeIn(delay: 400.ms, duration: 400.ms, curve: Curves.easeOut)
        .slideX(
            begin: 1,
            delay: 400.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack);
  }

  Widget _buildPremiumBadge() {
    if (!widget.isFavorite) return const SizedBox.shrink();

    return Positioned(
      bottom: 18,
      right: 18,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoading) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        ),
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          ),
        ),
      ),
    )
        .animate(target: _isLoading ? 1 : 0)
        .fadeIn(duration: 300.ms)
        .scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildEnhancedShimmerEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[200]!,
            Colors.grey[50]!,
            Colors.grey[200]!,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(-2.0, -0.5),
          end: const Alignment(2.0, 0.5),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1800.ms,
          color: Colors.white.withOpacity(0.6),
        );
  }

  Widget _buildEnhancedErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[100]!,
            Colors.grey[50]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.grey[500],
              size: 30,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(delay: 100.ms, duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _isLoading = true;
                _isError = false;
              });
              _preloadImage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(
              begin: 0.3,
              delay: 300.ms,
              duration: 400.ms,
              curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  void _handleDownload() {
    HapticFeedback.mediumImpact();
    // Implement download functionality with progress animation
  }

  void _showInfo() {
    HapticFeedback.lightImpact();
    // Show wallpaper information dialog
  }
}

// Enhanced Animation Extensions
extension EnhancedAnimateExtensions on Widget {
  Widget animateOnTap({
    required bool isPressed,
    Duration? duration,
    Curve? curve,
    double scale = 0.95,
  }) {
    return animate(target: isPressed ? 1 : 0).scale(
      begin: const Offset(1.0, 1.0),
      end: Offset(scale, scale),
      duration: duration ?? 120.ms,
      curve: curve ?? Curves.easeOut,
    );
  }

  Widget withPremiumGlow({
    required bool isActive,
    Color? glowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: (glowColor ?? AppColors.primaryColor).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: this,
    );
  }
}
