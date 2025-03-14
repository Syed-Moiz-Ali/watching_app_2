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
  final String contentType; // Add content type for favorites

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

class _VideoCardState extends State<VideoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isPlaying) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..scale(widget.isPlaying ? 1.0 : (_isHovered ? 1.02 : 0.98)),
        child: GestureDetector(
          onTap: widget.onTap,
          onHorizontalDragStart: (_) => widget.onHorizontalDragStart(),
          onHorizontalDragEnd: (_) => widget.onHorizontalDragEnd(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isGrid ? 20 : 28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor
                      .withOpacity(_isHovered ? 0.2 : 0.1),
                  blurRadius: 100,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isGrid ? 20 : 28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.all(widget.isGrid ? 5.sp : 5.sp),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColorLight.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.backgroundColorLight.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoThumbnail(),
                      CustomGap(heightFactor: widget.isGrid ? 0.01 : .02),
                      _buildVideoDetails(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Hero(
      tag: 'video_${widget.item.contentUrl}',
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.isGrid ? 18.h : 30.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isGrid ? 16 : 24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.isGrid ? 16 : 24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.item.source.isPreview == '1' && widget.isPlaying)
                      VideoPlayerWidget(
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
                    else
                      _buildThumbnailImage(widget.item),
                    _buildGradientOverlay(),
                    if (widget.item.source.isPreview == '1') _buildPlayButton(),
                    if (widget.item.duration != '0:00') _buildDurationBadge(),
                    _buildQualityBadge(),
                    Positioned(
                      left: widget.isGrid ? 12 : 16,
                      bottom: widget.isGrid ? 12 : 16,
                      child: FavoriteButton(
                        item: widget.item,
                        contentType: widget.contentType,
                        // primaryColor: AppColors.errorColor,
                        isGrid: widget.isGrid,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnailImage(ContentItem item) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.95, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: CustomImageWidget(
            imagePath: SMA.formatImage(
              image: widget.item.thumbnailUrl,
              baseUrl: widget.item.source.url,
            ),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned(
      top: widget.isGrid ? 12 : 16,
      right: widget.isGrid ? 12 : 16,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: _isHovered ? 1.1 : 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: EdgeInsets.all(widget.isGrid ? 10 : 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(120),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primaryColor,
                size: widget.isGrid ? 20 : 36,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationBadge() {
    return Positioned(
      right: widget.isGrid ? 12 : 16,
      bottom: widget.isGrid ? 12 : 16,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isGrid ? 10 : 14,
          vertical: widget.isGrid ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(widget.isGrid ? 10 : 16),
          border: Border.all(
            color: AppColors.backgroundColorDark.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: widget.isGrid ? 14 : 16,
              color: AppColors.backgroundColorLight,
            ),
            const SizedBox(width: 6),
            TextWidget(
              text: widget.item.duration.replaceAll("HD", ""),
              fontSize: widget.isGrid ? 12.sp : 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Positioned(
      left: widget.isGrid ? 12 : 16,
      top: widget.isGrid ? 12 : 16,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isGrid ? 10 : 14,
          vertical: widget.isGrid ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(widget.isGrid ? 10 : 16),
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
            Icon(
              Icons.high_quality_rounded,
              size: widget.isGrid ? 14 : 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            TextWidget(
              text: widget.item.quality,
              fontSize: widget.isGrid ? 12.sp : 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoDetails() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.isGrid ? 5.sp : 15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: widget.item.title,
                  fontSize: widget.isGrid ? 15.sp : 18.sp,
                  // color: AppColors.backgroundColorDark,
                  fontWeight: FontWeight.w700,
                  maxLine: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: widget.isGrid ? 12 : 16),
                Wrap(
                  children: [
                    _buildSourceBadge(),
                    const CustomGap(widthFactor: .01),
                    _buildTimeBadge(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isGrid ? 10 : 14,
        vertical: widget.isGrid ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_outline_rounded,
            size: widget.isGrid ? 14 : 16,
            color: Colors.grey[800],
          ),
          const CustomGap(widthFactor: .005),
          TextWidget(
            text: widget.item.source.name,
            fontSize: widget.isGrid ? 12.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isGrid ? 10 : 14,
        vertical: widget.isGrid ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: widget.isGrid ? 14 : 16,
            color: Colors.grey[800],
          ),
          const CustomGap(widthFactor: .005),
          TextWidget(
            text: widget.item.time,
            fontSize: widget.isGrid ? 12.sp : 14.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

// Custom Shimmer Effect for loading state
class ShimmerEffect extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-2 + (value * 4), 0),
              end: Alignment(-1 + (value * 4), 0),
              colors: [
                Colors.grey[800]!.withOpacity(0.1),
                Colors.grey[800]!.withOpacity(0.2),
                Colors.grey[800]!.withOpacity(0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// Custom Loading Overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              TextWidget(
                text: 'Loading...',
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension for custom animations
extension VideoCardAnimations on Widget {
  Widget withPulseAnimation({
    required bool isActive,
    required Duration duration,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: isActive ? 1.1 : 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: this,
    );
  }

  Widget withFadeSlideAnimation({
    required bool isVisible,
    required Duration duration,
    Offset? offset,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: isVisible ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              (offset?.dy ?? 20) * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: this,
    );
  }
}

// Custom Ripple Effect
class RippleEffect extends StatelessWidget {
  final Widget child;
  final bool isActive;

  const RippleEffect({
    super.key,
    required this.child,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isActive)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: 1 - value,
                child: Transform.scale(
                  scale: 1 + (value * 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
