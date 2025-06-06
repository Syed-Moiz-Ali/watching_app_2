import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';

import '../loading/loading_indicator.dart';

class ImageWidget extends StatefulWidget {
  final String imagePath;
  final BoxFit fit;
  final double? height;
  final double? width;
  final dynamic borderRadius;
  final Duration animationDuration;
  final bool enableParallax;
  final bool enableGlow;
  final bool enableZoomOnHover;
  final Color? overlayColor;
  final double? overlayOpacity;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? customBorderRadius;
  final Border? border;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Widget? overlayWidget;
  final ImageTransitionType transitionType;
  final ImageFilterType filterType;

  const ImageWidget({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.height = double.infinity,
    this.width = double.infinity,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 800),
    this.enableParallax = false,
    this.enableGlow = false,
    this.enableZoomOnHover = false,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.boxShadow,
    this.customBorderRadius,
    this.border,
    this.margin,
    this.padding,
    this.onTap,
    this.onDoubleTap,
    this.overlayWidget,
    this.transitionType = ImageTransitionType.fade,
    this.filterType = ImageFilterType.none,
  });

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget>
    with SingleTickerProviderStateMixin {
  String? randomErrorImage;
  bool _isHovering = false;
  Offset _parallaxOffset = Offset.zero;

  // Animation controller for various effects
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;

  Future<void> getRandomErrorImage() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/stars2.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final random = math.Random();
      final randomImage = jsonData[random.nextInt(jsonData.length)];

      setState(() {
        randomErrorImage = randomImage['image'];
      });
    } catch (e) {
      // Silently ignore errors
    }
  }

  @override
  void initState() {
    super.initState();
    getRandomErrorImage();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Configure different animations
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _animationController.forward();

    // Auto-repeat glow animation if enabled
    if (widget.enableGlow) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateParallaxOffset(Offset offset, BoxConstraints constraints) {
    if (!widget.enableParallax) return;

    // Calculate parallax effect with subtle movement
    final dx = (offset.dx / constraints.maxWidth - 0.5) * 10;
    final dy = (offset.dy / constraints.maxHeight - 0.5) * 10;

    setState(() {
      _parallaxOffset = Offset(dx, dy);
    });
  }

  void _resetParallax() {
    if (!widget.enableParallax) return;
    setState(() {
      _parallaxOffset = Offset.zero;
    });
  }

  void _handleHover(bool isHovering) {
    if (!widget.enableZoomOnHover) return;
    setState(() {
      _isHovering = isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    // log("imagePath is ${widget.imagePath}");
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) {
            _handleHover(true);
            _updateParallaxOffset(event.localPosition, constraints);
          },
          onExit: (_) {
            _handleHover(false);
            _resetParallax();
          },
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  height: widget.height,
                  width: widget.width,
                  margin: widget.margin,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    // color: AppColors.disabledColor,
                    borderRadius: widget.customBorderRadius ??
                        (widget.borderRadius is double
                            ? BorderRadius.circular(widget.borderRadius)
                            : (widget.borderRadius as BorderRadius? ??
                                BorderRadius.circular(12))),
                    border: widget.border,
                    boxShadow: widget.enableGlow
                        ? [
                            BoxShadow(
                              color: Colors.blue
                                  .withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                            ...(widget.boxShadow ?? []),
                          ]
                        : widget.boxShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: widget.customBorderRadius ??
                        (widget.borderRadius is double
                            ? BorderRadius.circular(widget.borderRadius)
                            : (widget.borderRadius as BorderRadius? ??
                                BorderRadius.circular(12))),
                    child: Stack(
                      children: [
                        // Parallax container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutCubic,
                          transform: Transform.translate(
                            offset: _parallaxOffset,
                          ).transform,
                          transformAlignment: Alignment.center,
                          child: AnimatedScale(
                            scale: _isHovering ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: _buildFilteredImage(
                                  _buildImageContent(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Loading indicator overlay when image is loading
                        // if (!_isLoaded && !_isError) _buildPlaceholder(),

                        // Color overlay with adjustable opacity
                        if (widget.overlayColor != null &&
                            widget.overlayOpacity! > 0)
                          Positioned.fill(
                            child: Container(
                              color: widget.overlayColor!.withOpacity(
                                widget.overlayOpacity!,
                              ),
                            ),
                          ),

                        // Custom overlay widget if provided
                        if (widget.overlayWidget != null)
                          Positioned.fill(
                            child: widget.overlayWidget!,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilteredImage(Widget imageWidget) {
    switch (widget.filterType) {
      case ImageFilterType.grayscale:
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: imageWidget,
        );

      case ImageFilterType.sepia:
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.393,
            0.769,
            0.189,
            0,
            0,
            0.349,
            0.686,
            0.168,
            0,
            0,
            0.272,
            0.534,
            0.131,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: imageWidget,
        );

      case ImageFilterType.blurred:
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: imageWidget,
        );

      case ImageFilterType.none:
      default:
        return imageWidget;
    }
  }

  Widget _buildImageContent() {
    final bool isSvg = widget.imagePath.toLowerCase().endsWith('.svg');
    final String image = widget.imagePath;

    return _buildImage(image, isSvg);
  }

  Widget _buildImage(String imageUrl, bool isSvg) {
    // Early validation: if the URL is empty or invalid, show error widget
    if (imageUrl.isEmpty) {
      return _buildFallbackErrorWidget();
    }

    // Check if it's a local asset path
    if (imageUrl.startsWith('assets/')) {
      return _buildLocalAssetImage(imageUrl, isSvg);
    }

    // Validate URL for network images
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return _buildFallbackErrorWidget(); // Invalid URL (no host or scheme)
    }

    // For valid URLs, attempt to load the image
    return isSvg ? _buildSvgImage(imageUrl) : _buildRasterImage(imageUrl);
  }

  Widget _buildLocalAssetImage(String assetPath, bool isSvg) {
    try {
      if (isSvg) {
        return SvgPicture.asset(
          assetPath,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          placeholderBuilder: (context) => _buildPlaceholder(),
        );
      } else {
        return Image.asset(
          assetPath,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {});
                }
              });
              return child;
            }
            return _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackErrorWidget();
          },
        );
      }
    } catch (e) {
      return _buildFallbackErrorWidget();
    }
  }

  Widget _buildSvgImage(String imageUrl) {
    log("this is svg image");
    try {
      return SvgPicture.network(
        imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        placeholderBuilder: (context) => _buildPlaceholder(),
        semanticsLabel: 'SVG Image',
      );
    } catch (e) {
      // Catch any loading errors and return the error widget silently
      return _buildFallbackErrorWidget();
    }
  }

  Widget _buildRasterImage(String imageUrl) {
    try {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) {
          return _buildFallbackErrorWidget();
        },
        fadeInDuration: _getTransitionDuration(),
        fadeOutDuration: _getTransitionDuration(),
        imageBuilder: (context, imageProvider) {
          // Mark as loaded once image is ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });

          switch (widget.transitionType) {
            case ImageTransitionType.fade:
              return Image(
                image: imageProvider,
                fit: widget.fit,
                height: widget.height,
                width: widget.width,
              );

            case ImageTransitionType.scale:
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: widget.animationDuration,
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Image(
                      image: imageProvider,
                      fit: widget.fit,
                      height: widget.height,
                      width: widget.width,
                    ),
                  );
                },
              );

            case ImageTransitionType.slideIn:
              return TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ),
                duration: widget.animationDuration,
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: value * 50,
                    child: Image(
                      image: imageProvider,
                      fit: widget.fit,
                      height: widget.height,
                      width: widget.width,
                    ),
                  );
                },
              );

            default:
              return Image(
                image: imageProvider,
                fit: widget.fit,
                height: widget.height,
                width: widget.width,
              );
          }
        },
      );
    } catch (e) {
      // Catch any loading errors and return the error widget silently
      return _buildFallbackErrorWidget();
    }
  }

  Duration _getTransitionDuration() {
    switch (widget.transitionType) {
      case ImageTransitionType.none:
        return Duration.zero;
      default:
        return widget.animationDuration;
    }
  }

  Widget _buildPlaceholder() {
    if (widget.height == null && widget.width == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const Center(child: CustomLoadingIndicator()),
      );
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.customBorderRadius ??
              (widget.borderRadius is double
                  ? BorderRadius.circular(widget.borderRadius)
                  : (widget.borderRadius as BorderRadius? ??
                      BorderRadius.circular(12))),
        ),
      ),
    );
  }

  Widget _buildFallbackErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.customBorderRadius ??
            (widget.borderRadius is double
                ? BorderRadius.circular(widget.borderRadius)
                : (widget.borderRadius as BorderRadius? ??
                    BorderRadius.circular(12))),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              color: Colors.grey,
              size: math.min(40, (widget.width ?? 80) / 4),
            ),
            const SizedBox(height: 8),
            TextWidget(
              text: 'Image not available',
              color: Colors.grey[600],
              fontSize: math.min(14, (widget.width ?? 80) / 8),
            ),
          ],
        ),
      ),
    );
  }
}

// Enum for image transition types
enum ImageTransitionType {
  none,
  fade,
  scale,
  slideIn,
}

// Enum for image filter types
enum ImageFilterType {
  none,
  grayscale,
  sepia,
  blurred,
}
