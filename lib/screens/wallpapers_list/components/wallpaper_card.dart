import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/global/app_global.dart';
import 'package:watching_app_2/widgets/custom_image_widget.dart';
import '../../../core/zoom/zoom_widget.dart';
import '../../../models/content_item.dart';

class WallpaperCard extends StatefulWidget {
  final ContentItem item;
  final VoidCallback onTap;

  const WallpaperCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WallpaperCard> createState() => _WallpaperCardState();
}

class _WallpaperCardState extends State<WallpaperCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create scale animation for press effect
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Create opacity animation for overlay
    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Preload image
    _preloadImage();
  }

  // Preload image to handle loading state
  void _preloadImage() {
    final imageProvider = NetworkImage(SMA.formatImage(
        image: widget.item.thumbnailUrl.toString(),
        baseUrl: widget.item.source.url));
    imageProvider.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero animated wallpaper image
                      _isLoading
                          ? _buildShimmerEffect()
                          : _isError
                              ? _buildErrorWidget()
                              : _buildWallpaperImage(),

                      // Gradient overlay for better readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.4),
                              ],
                              stops: const [0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Tap effect overlay
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: _isPressed ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            color: Colors.white
                                .withOpacity(_opacityAnimation.value),
                          ),
                        ),
                      ),

                      // Bottom info section
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title with blurred background
                            if (widget.item.title != null &&
                                widget.item.title!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.item.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Quality badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _buildQualityBadge(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Wallpaper image with cached network image
  Widget _buildWallpaperImage() {
    log("widget.item.thumbnailUrl is ${widget.item.thumbnailUrl}");
    return Hero(
      tag: 'wallpaper-${widget.item.thumbnailUrl}',
      child: CustomImageWidget(
        imagePath: SMA.formatImage(
            image: widget.item.thumbnailUrl.toString(),
            baseUrl: widget.item.source.url),
        fit: BoxFit.cover,
      ),
    );
  }

  // Shimmer loading effect
  Widget _buildShimmerEffect() {
    return ShimmerLoading(
      child: Container(
        color: Colors.grey[300],
      ),
    );
  }

  // Error state widget
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }

  // Quality badge widget
  Widget _buildQualityBadge() {
    final isHD =
        true; // You can determine this based on your ContentItem properties

    return AnimatedOpacity(
      opacity: _isLoading ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'HD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Custom Shimmer Loading Effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return _shimmerGradient.createShader(bounds,
            textDirection: TextDirection.ltr);
      },
      child: widget.child,
    );
  }

  LinearGradient get _shimmerGradient {
    return LinearGradient(
      colors: [
        Colors.grey[300]!,
        Colors.grey[100]!,
        Colors.grey[300]!,
      ],
      stops: const [0.1, 0.5, 0.9],
      begin: const Alignment(-1.0, -0.5),
      end: const Alignment(1.0, 0.5),
      transform:
          _SlidingGradientTransform(slidePercent: _shimmerController.value),
    );
  }
}

// Gradient animation transformer
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
