import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';

import '../../../../data/models/category_model.dart';
import '../../../widgets/misc/text_widget.dart';

class PremiumCategoryDetailScreen extends StatefulWidget {
  const PremiumCategoryDetailScreen({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  State<PremiumCategoryDetailScreen> createState() =>
      _PremiumCategoryDetailScreenState();
}

class _PremiumCategoryDetailScreenState
    extends State<PremiumCategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late Animation<double> _headerScaleAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  double _scrollOffset = 0.0;
  bool _isBookmarked = false;
  bool _showFloatingHeader = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with longer duration for smoother effects
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Create staggered animations for different UI elements
    _headerScaleAnimation = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _contentOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // Initialize scroll controller with listener for parallax effects
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _showFloatingHeader =
              _scrollOffset > MediaQuery.of(context).size.height * 0.4;
        });
      });

    // Start entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Premium badge with glassmorphism effect
  Widget _buildPremiumBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond_outlined,
                size: 16.sp,
                color: Colors.white,
              ),
              SizedBox(width: 6.w),
              TextWidget(
                text: 'PREMIUM',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
                letterSpacing: 1.2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stat item with improved design
  Widget _buildStatItem(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: Colors.white.withOpacity(0.9),
          ),
          SizedBox(width: 2.w),
          TextWidget(
            text: text,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ],
      ),
    );
  }

  // Neu-morphic button with gradient and pressed state animation
  Widget _buildActionButton(String text, IconData icon, bool isPrimary) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: () {
            // log("rtyuiop");
            HapticFeedback.mediumImpact();
            NH.nameNavigateTo(AppRoutes.searchResult, arguments: {
              "query": widget.category.title.toLowerCase(),
              "category": ContentTypes.VIDEO
            });

            // Action functionality
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.sp),
            ),
            backgroundColor: Colors.transparent,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPrimary
                    ? [
                        Color.lerp(
                            Colors.purple[800], Colors.blue[700], value)!,
                        Color.lerp(
                            Colors.deepPurple[900], Colors.blue[900], value)!,
                      ]
                    : [
                        Colors.grey[850]!,
                        Colors.grey[900]!,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.sp),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              height: 8.h,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  TextWidget(
                    text: text,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    letterSpacing: 0.5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Circle action button with pressed animation
  Widget _buildCircleButton(IconData icon, {VoidCallback? onPressed}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) {
        return Container(
          height: 12.h,
          width: 12.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[850]!,
                Colors.grey[900]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (onPressed != null) {
                  onPressed();
                }
              },
              child: Icon(
                icon,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  // Floating header that appears on scroll
  Widget _buildFloatingHeader() {
    return AnimatedOpacity(
      opacity: _showFloatingHeader ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: _showFloatingHeader
          ? ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: Row(
                    children: [
                      TextWidget(
                        text: widget.category.title,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                      // const Spacer(),
                      // _buildPremiumBadge(),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // Content section with consistent styling
  Widget _buildContentSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: title,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20.sp),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: TextWidget(
            text: content,
            fontSize: 16.sp,
            height: 1.6,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parallax effect calculations
    final parallaxOffset = _scrollOffset * 0.5;
    final headerScale = 1 + (_scrollOffset * 0.0005).clamp(0.0, 0.05);
    final headerOpacity = (1 - (_scrollOffset / 180).clamp(0.0, 1.0));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();

              // Add a smooth exit animation
              _animationController.reverse().then((_) {
                Navigator.pop(context);
              });
            },
          ),
          // actions: [
          //   IconButton(
          //     icon: Container(
          //       padding: EdgeInsets.all(8.sp),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.3),
          //         shape: BoxShape.circle,
          //       ),
          //       child: Icon(
          //         _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          //         color: Colors.white,
          //         size: 18.sp,
          //       ),
          //     ),
          //     onPressed: () {
          //       HapticFeedback.lightImpact();
          //       setState(() {
          //         _isBookmarked = !_isBookmarked;
          //       });
          //     },
          //   ),
          //   IconButton(
          //     icon: Container(
          //       padding: EdgeInsets.all(8.sp),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.3),
          //         shape: BoxShape.circle,
          //       ),
          //       child: Icon(
          //         Icons.share,
          //         color: Colors.white,
          //         size: 18.sp,
          //       ),
          //     ),
          //     onPressed: () {
          //       HapticFeedback.lightImpact();
          //       // Share functionality
          //     },
          //   ),
          //   SizedBox(width: 8.w),
          // ],
          flexibleSpace: _buildFloatingHeader(),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Parallax background image with scale effect
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _headerScaleAnimation.value * headerScale,
                  child: Transform.translate(
                    offset: Offset(0, -parallaxOffset),
                    child: Hero(
                      tag: 'category_${widget.category.id}',
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                              stops: [0.0, 0.7],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: ImageWidget(
                            imagePath: widget.category.image,
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height * 0.6,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Advanced gradient overlay with multiple layers
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.7, 0.85],
                ),
              ),
            ),

            // Main content with animated scrolling
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Header space for parallax effect
                    SizedBox(height: MediaQuery.of(context).size.height * 0.42),

                    // Header info with animations
                    Opacity(
                      opacity: headerOpacity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Premium badge with animation
                            // FadeTransition(
                            //   opacity: _contentOpacityAnimation,
                            //   child: SlideTransition(
                            //     position: _titleSlideAnimation,
                            //     child: _buildPremiumBadge(),
                            //   ),
                            // ),
                            // SizedBox(height: 20.h),

                            // Title with animation
                            FadeTransition(
                              opacity: _contentOpacityAnimation,
                              child: SlideTransition(
                                position: _titleSlideAnimation,
                                child: TextWidget(
                                  text: widget.category.title,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Stats row with wrap for responsive layout
                            // FadeTransition(
                            //   opacity: _contentOpacityAnimation,
                            //   child: SlideTransition(
                            //     position: _titleSlideAnimation,
                            //     child: Wrap(
                            //       spacing: 2.w,
                            //       runSpacing: 2.h,
                            //       children: [
                            //         _buildStatItem(Icons.visibility_outlined,
                            //             '10.5K views'),
                            //         _buildStatItem(
                            //             Icons.star_outline, '4.9 rating'),
                            //         _buildStatItem(
                            //             Icons.update_outlined, 'Daily updates'),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(height: 2.h),

                            // Action buttons with staggered animation
                            FadeTransition(
                              opacity: _contentOpacityAnimation,
                              child: SlideTransition(
                                position: _buttonSlideAnimation,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton(
                                        'Explore Now',
                                        Icons.play_arrow_rounded,
                                        true,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    _buildCircleButton(
                                      _isBookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      onPressed: () {
                                        setState(() {
                                          _isBookmarked = !_isBookmarked;
                                        });
                                      },
                                    ),
                                    SizedBox(width: 3.w),
                                    _buildCircleButton(Icons.share_outlined),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Content sections with fade in animation
                    FadeTransition(
                      opacity: _contentOpacityAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.6, 1.0,
                                curve: Curves.easeOutCubic),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // About section with enhanced styling
                              _buildContentSection(
                                'About This Collection',
                                'Experience our exclusive premium collection featuring the best ${widget.category.title.toLowerCase()} content. Meticulously curated for discerning members, this collection showcases exceptional quality and unprecedented access to premium content updated daily.\n\nWith our advanced filtering system, you can easily find exactly what you\'re looking for within this collection.',
                              ),

                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
