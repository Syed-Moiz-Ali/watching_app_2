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
  final String? contentType; // Default content type

  const WallpaperCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.onFavorite,
    this.onShare,
    this.isFavorite = false,
    this.showActions = true,
    this.aspectRatio = 0.75, // 3:4 ratio
    this.borderRadius,
    this.contentType = ContentTypes.IMAGE, // Default content type
  });

  @override
  State<WallpaperCard> createState() => _WallpaperCardState();
}

class _WallpaperCardState extends State<WallpaperCard> {
  bool _isPressed = false;
  bool _isLoading = true;
  bool _isError = false;
  bool _isHovered = false;
  bool _showActions = false;
  String? _dominantColor;

  @override
  void initState() {
    super.initState();
    _preloadImage();
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
    // Simplified color extraction - you can integrate a proper color extraction library
    setState(() {
      _dominantColor = '#FF6B6B'; // Placeholder - implement proper extraction
    });
  }

  void _handleTapDown() {
    HapticFeedback.selectionClick();
    setState(() => _isPressed = true);
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _toggleActions() {
    setState(() => _showActions = !_showActions);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
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
          margin: EdgeInsets.all(2.w),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          if (_isHovered)
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: -2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            // _buildGradientOverlay(),
            if (widget.contentType != ContentTypes.IMAGE)
              _buildInteractionOverlay(),
            if (widget.contentType != ContentTypes.IMAGE) _buildContent(),
            if (widget.showActions) _buildActionButtons(),
            if (widget.contentType == ContentTypes.IMAGE) _buildQualityBadge(),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    )
        .animate(target: _isPressed ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.95, 0.95),
          duration: 200.ms,
          curve: Curves.easeOutCubic,
        )
        .animate(target: _isHovered ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildBackground() {
    if (_isLoading) return _buildShimmerEffect();
    if (_isError) return _buildErrorWidget();

    return Hero(
      tag: 'wallpaper_${widget.item.scrapedAt.microsecondsSinceEpoch}',
      child: ImageWidget(
        imagePath: _getImageUrl(),
        fit: BoxFit.cover,
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
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.item.title.isNotEmpty) _buildTitle(),
          // SizedBox(height: 8),
          // _buildMetadata(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextWidget(
        text: widget.item.title,
        color: Colors.white,
        // fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        maxLine: 2,
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.5, delay: 300.ms, duration: 400.ms);
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        // _buildMetadataChip(Icons.photo_size_select_actual, '${widget.item.width}x${widget.item.height}'),
        // SizedBox(width: 8),
        // _buildMetadataChip(Icons.file_download, '${widget.item.downloads ?? 0}'),
        // Spacer(),
      ],
    );
  }

  Widget _buildMetadataChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          SizedBox(width: 4),
          TextWidget(
            text: text,
            color: Colors.white70,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(.9),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        children: [
          FavoriteButton(
            item: widget.item,
            contentType: widget.contentType ?? ContentTypes.IMAGE,
            isGrid: true,
          )
              .animate(target: _isLoading ? 0 : 1)
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.5, delay: 300.ms, duration: 400.ms),
          SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.share,
            onTap: widget.onShare,
          ),
          SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.download,
            onTap: () => _handleDownload(),
          ),
        ],
      ),
    )
        .animate(target: _showActions ? 1 : 0)
        .fadeIn(duration: 200.ms)
        .slideX(begin: -1, duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildQualityBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hd, color: Colors.white, size: 14),
            SizedBox(width: 4),
            TextWidget(
              text: 'HD',
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    )
        .animate(target: _isLoading ? 0 : 1)
        .fadeIn(delay: 400.ms, duration: 300.ms)
        .slideX(begin: 1, delay: 400.ms, duration: 300.ms);
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoading) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          )
              .animate(target: _isLoading ? 1 : 0)
              .fadeIn(duration: 200.ms)
              .scale(duration: 200.ms),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(-2.0, -0.5),
          end: const Alignment(2.0, 0.5),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.5),
        );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: Colors.grey[400],
            size: 48,
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(delay: 100.ms, duration: 300.ms),
          SizedBox(height: 12),
          TextWidget(
            text: 'Failed to load',
            color: Colors.grey[600]!,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isLoading = true;
                _isError = false;
              });
              _preloadImage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextWidget(
                text: 'Retry',
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 300.ms)
              .slideY(begin: 0.3, delay: 300.ms, duration: 300.ms),
        ],
      ),
    );
  }

  void _handleDownload() {
    // Implement download functionality
    HapticFeedback.mediumImpact();
    // Show download progress animation
  }
}

// Extension for better animation chaining
extension AnimateExtensions on Widget {
  Widget animateOnTap({
    required bool isPressed,
    Duration? duration,
    Curve? curve,
  }) {
    return animate(target: isPressed ? 1 : 0).scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(0.95, 0.95),
      duration: duration ?? 150.ms,
      curve: curve ?? Curves.easeOut,
    );
  }
}
