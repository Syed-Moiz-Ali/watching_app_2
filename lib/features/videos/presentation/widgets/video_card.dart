import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/shared/widgets/misc/gap.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/global/globals.dart';
import '../../../../data/models/content_item.dart';
import '../../../../shared/widgets/misc/image.dart';
import '../../../../shared/widgets/misc/video_player_widget.dart';
import '../../../../shared/screens/favorites/favorite_button.dart';

class VideoCard extends StatefulWidget {
  final ContentItem item;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onHorizontalDragStart;
  final VoidCallback onHorizontalDragEnd;
  final bool isGrid;
  final String contentType;

  const VideoCard({
    super.key,
    required this.item,
    required this.isPlaying,
    required this.onTap,
    required this.onHorizontalDragStart,
    required this.onHorizontalDragEnd,
    this.isGrid = false,
    required this.contentType,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _playController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _playButtonScale;
  late Animation<double> _overlayOpacity;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
      begin: 4.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _playButtonScale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _playController,
      curve: Curves.elasticOut,
    ));

    _overlayOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _playController.forward();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _playController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _playController.forward();
      } else {
        _playController.reverse();
      }
    }
  }

  void _onHover(bool isHovered) {
    if (mounted) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverController, _playController]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isPlaying ? 1.0 : _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: widget.isGrid ? 4 : 6,
                vertical: widget.isGrid ? 4 : 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isGrid ? 20 : 24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value * 0.3),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: _elevationAnimation.value * 0.8,
                    offset: Offset(0, _elevationAnimation.value * 0.2),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: _buildCardContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent() {
    return GestureDetector(
      onTap: widget.onTap,
      onHorizontalDragStart: (_) => widget.onHorizontalDragStart(),
      onHorizontalDragEnd: (_) => widget.onHorizontalDragEnd(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(widget.isGrid ? 20 : 24),
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isGrid ? 20 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnailSection(),
              _buildDetailsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return Hero(
      tag: 'video_${widget.item.contentUrl}',
      child: Container(
        height: widget.isGrid ? 17.h : 30.h,
        margin: EdgeInsets.all(widget.isGrid ? 8 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isGrid ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main video/thumbnail content
            _buildMainContent(),

            // Enhanced gradient overlay
            _buildGradientOverlay(),

            // Hover overlay effect
            _buildHoverOverlay(),

            // Top badges row
            _buildTopBadges(),

            // Play button
            if (widget.item.source.isPreview == '1') _buildPlayButton(),

            // Bottom badges row
            _buildBottomBadges(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.isGrid ? 16 : 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: widget.item.source.isPreview == '1' && widget.isPlaying
            ? VideoPlayerWidget(
                key: const ValueKey('video_player'),
                imageUrl: SMA.formatImage(
                  image: widget.item.thumbnailUrl,
                  baseUrl: widget.item.source.url,
                ),
                videoUrl: SMA.formatImage(
                  image: widget.item.preview,
                  baseUrl: widget.item.source.url,
                ),
                isShown: widget.isPlaying,
              )
            : ImageWidget(
                key: const ValueKey('thumbnail'),
                imagePath: SMA.formatImage(
                  image: widget.item.thumbnailUrl,
                  baseUrl: widget.item.source.url,
                ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isGrid ? 16 : 20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return AnimatedBuilder(
      animation: _overlayOpacity,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isGrid ? 16 : 20),
              color: AppColors.primaryColor
                  .withOpacity(0.1 * _overlayOpacity.value),
              border: Border.all(
                color: AppColors.primaryColor
                    .withOpacity(0.3 * _overlayOpacity.value),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBadges() {
    return Positioned(
      left: 8,
      right: 8,
      top: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQualityBadge(),
          if (widget.isPlaying) _buildPlayingIndicator(),
        ],
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isGrid ? 10 : 12,
        vertical: widget.isGrid ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hd_outlined,
            size: widget.isGrid ? 13 : 18,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          TextWidget(
            text: widget.item.quality,
            fontSize: widget.isGrid ? 11.sp : 13.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: AnimatedBuilder(
        animation: _playButtonScale,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isPlaying ? 0.0 : _playButtonScale.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.isGrid ? 50 : 70,
                height: widget.isGrid ? 50 : 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.primaryColor,
                  size: widget.isGrid ? 32 : 36,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBadges() {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FavoriteButton(
            item: widget.item,
            contentType: widget.contentType,
            isGrid: widget.isGrid,
          ),
          if (widget.item.duration != '0:00') _buildDurationBadge(),
        ],
      ),
    );
  }

  Widget _buildDurationBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isGrid ? 10 : 12,
        vertical: widget.isGrid ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: widget.isGrid ? 13 : 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          TextWidget(
            text: widget.item.duration.replaceAll("HD", "").trim(),
            fontSize: widget.isGrid ? 11.sp : 13.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        widget.isGrid ? 16 : 20,
        widget.isGrid ? 12 : 16,
        widget.isGrid ? 16 : 20,
        widget.isGrid ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with better typography
          TextWidget(
            text: widget.item.title,
            fontSize: widget.isGrid ? 16.sp : 18.sp,
            fontWeight: FontWeight.w700,
            maxLine: 2,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),

          SizedBox(height: widget.isGrid ? 12 : 16),

          // Meta info with improved design
          Row(
            children: [
              Expanded(child: _buildSourceChip()),
              const SizedBox(width: 8),
              _buildTimeChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isGrid ? 12 : 14,
        vertical: widget.isGrid ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.source_outlined,
            size: widget.isGrid ? 16 : 18,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: TextWidget(
              text: widget.item.source.name,
              fontSize: widget.isGrid ? 13.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
              maxLine: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isGrid ? 12 : 14,
        vertical: widget.isGrid ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: widget.isGrid ? 16 : 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          TextWidget(
            text: widget.item.time,
            fontSize: widget.isGrid ? 13.sp : 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

// Enhanced Loading States
class PremiumShimmerEffect extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const PremiumShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<PremiumShimmerEffect> createState() => _PremiumShimmerEffectState();
}

class _PremiumShimmerEffectState extends State<PremiumShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey[300]!.withOpacity(0.1),
                Colors.grey[300]!.withOpacity(0.3),
                Colors.grey[300]!.withOpacity(0.1),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PremiumLoadingOverlay extends StatelessWidget {
  const PremiumLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              TextWidget(
                text: 'Loading premium content...',
                fontSize: 16.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
