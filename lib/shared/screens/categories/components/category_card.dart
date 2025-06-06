import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/category_model.dart';
import '../../../widgets/misc/image.dart';
import '../../../widgets/misc/text_widget.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int index;
  final Function(int) onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;

  // Hover state
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    // Main hover animation controller
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Subtle continuous pulse animation for premium indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Shimmer effect animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Define animations
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // Handle mouse enter/exit for web/desktop
  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });

    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDarkMode = brightness == Brightness.dark;

    // Premium colors
    final primaryColor = isDarkMode
        ? const Color(0xFF9D81FC) // Soft purple for dark mode
        : const Color(0xFF6C5CE7); // Bold purple for light mode

    final accentColor = isDarkMode
        ? const Color(0xFFFD79A8) // Pink accent for dark mode
        : const Color(0xFFFF7675); // Coral accent for light mode

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _hoverController,
            _pulseController,
            _shimmerController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 220.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image with parallax effect
                      TweenAnimationBuilder<double>(
                        tween:
                            Tween<double>(begin: 0, end: _isHovering ? 1.0 : 0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 1.1 + (0.05 * value),
                            child: Transform.translate(
                              offset: Offset(5 * value, -5 * value),
                              child: ImageWidget(
                                imagePath: widget.category.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),

                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: 0.5 + (0.3 * _hoverController.value),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                primaryColor.withOpacity(0.3),
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                              transform: GradientRotation(
                                (0.5 * 3.14) +
                                    (0.05 * _shimmerController.value),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Bottom content section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category title with animated shadow
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                      begin: 0, end: _isHovering ? 1.0 : 0),
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -3 * value),
                                      child: TextWidget(
                                        text: widget.category.title,
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            blurRadius: 8 + (8 * value),
                                            offset: Offset(0, 2 + (2 * value)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 16.sp,
                                    ),
                                    // SizedBox(width: 6.w),
                                    TextWidget(
                                      text:
                                          '${(widget.index + 1) * 1250}+ views',
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),

                                    // SizedBox(width: 16.w),
                                    // Pulse animation for "trending" indicator
                                  ],
                                ),

                                Row(
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: 1),
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      curve: Curves.elasticOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value *
                                              (0.9 +
                                                  (0.1 *
                                                      _pulseController.value)),
                                          child: Icon(
                                            Icons.trending_up_rounded,
                                            color: accentColor.withOpacity(0.9),
                                            size: 16.sp,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 1.w),
                                    TextWidget(
                                      text: 'Trending',
                                      color: accentColor.withOpacity(0.9),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Animated border overlay
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _borderAnimation.value * 0.8,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // Animated corner accents that appear on hover
                      ...List.generate(4, (cornerIndex) {
                        final positions = [
                          Alignment.topLeft,
                          Alignment.topRight,
                          Alignment.bottomRight,
                          Alignment.bottomLeft,
                        ];

                        return Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _hoverController,
                            builder: (context, child) {
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: _hoverController.value,
                                child: Align(
                                  alignment: positions[cornerIndex],
                                  child: FractionalTranslation(
                                    translation: Offset(
                                      cornerIndex == 0 || cornerIndex == 3
                                          ? -0.5
                                          : 0.5,
                                      cornerIndex == 0 || cornerIndex == 1
                                          ? -0.5
                                          : 0.5,
                                    ),
                                    child: Container(
                                      height: 3.w,
                                      width: 3.w,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                          begin: positions[cornerIndex],
                                          end: positions[(cornerIndex + 2) % 4],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
