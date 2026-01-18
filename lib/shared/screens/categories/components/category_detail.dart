// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
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
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  bool _isBookmarked = false;
  bool _showFloatingHeader = false;

  @override
  void initState() {
    super.initState();

    // Initialize scroll controller
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _showFloatingHeader = _scrollOffset > 200;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Modern action button with clean design
  Widget _buildActionButton(String text, IconData icon, bool isPrimary) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          NH.nameNavigateTo(AppRoutes.searchResult, arguments: {
            "query": widget.category.title.toLowerCase(),
            "category": ContentTypes.VIDEO
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary
                ? null
                : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06)),
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08),
                    width: 1,
                  ),
          ),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  size: 20,
                ),
                SizedBox(width: 10),
                TextWidget(
                  text: text,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  letterSpacing: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Circle icon button with modern design
  Widget _buildCircleButton(IconData icon, {VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
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
            color: isDark ? Colors.white : Colors.black87,
            size: 22,
          ),
        ),
      ),
    );
  }

  // Minimal floating header
  Widget _buildFloatingHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: _showFloatingHeader ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: _showFloatingHeader
          ? ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white)
                        .withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.06),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextWidget(
                            text: widget.category.title,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                            maxLine: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // Content section with modern card design
  Widget _buildContentSection(String title, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: title,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
          letterSpacing: -0.3,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: TextWidget(
            text: content,
            fontSize: 15.sp,
            color: isDark
                ? Colors.grey[300]
                : Colors.grey[700],
            maxLine: 20,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Smooth parallax calculations
    final parallaxOffset = (_scrollOffset * 0.4).clamp(0.0, 150.0);
    final headerOpacity = (1 - (_scrollOffset / 250).clamp(0.0, 1.0));
    final headerScale = 1 + (_scrollOffset * 0.0003).clamp(0.0, 0.15);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero header with parallax image
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.5,
                  pinned: false,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Parallax background image
                        Transform.scale(
                          scale: headerScale,
                          child: Transform.translate(
                            offset: Offset(0, -parallaxOffset),
                            child: Hero(
                              tag: 'category_${widget.category.id}',
                              child: ImageWidget(
                                imagePath: widget.category.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Clean gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                (isDark ? Colors.black : Colors.white)
                                    .withOpacity(0.5),
                                (isDark ? Colors.black : Colors.white)
                                    .withOpacity(0.9),
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content section
                SliverToBoxAdapter(
                  child: Container(
                    color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and actions section
                        Opacity(
                          opacity: headerOpacity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category title
                                TextWidget(
                                  text: widget.category.title,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                )
                                    .animate()
                                    .fadeIn(
                                        delay: 300.ms, duration: 600.ms)
                                    .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        curve: Curves.easeOutCubic),

                                SizedBox(height: 24),

                                // Action buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton(
                                        'Explore Now',
                                        Icons.play_arrow_rounded,
                                        true,
                                      )
                                          .animate()
                                          .fadeIn(
                                              delay: 500.ms,
                                              duration: 600.ms)
                                          .slideX(
                                              begin: -0.2,
                                              end: 0,
                                              curve: Curves.easeOutCubic),
                                    ),
                                    SizedBox(width: 12),
                                    _buildCircleButton(
                                      _isBookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      onPressed: () {
                                        setState(() {
                                          _isBookmarked = !_isBookmarked;
                                        });
                                      },
                                    )
                                        .animate()
                                        .fadeIn(
                                            delay: 600.ms, duration: 600.ms)
                                        .scale(
                                            begin: const Offset(0.8, 0.8),
                                            curve: Curves.easeOutBack),
                                    SizedBox(width: 12),
                                    _buildCircleButton(
                                      Icons.share_outlined,
                                      onPressed: () {
                                        // Share functionality
                                      },
                                    )
                                        .animate()
                                        .fadeIn(
                                            delay: 700.ms, duration: 600.ms)
                                        .scale(
                                            begin: const Offset(0.8, 0.8),
                                            curve: Curves.easeOutBack),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 32),

                        // About section
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: _buildContentSection(
                            'About This Collection',
                            'Explore our curated collection of premium ${widget.category.title.toLowerCase()} content. Each piece is carefully selected to ensure exceptional quality and relevance.\n\nDiscover new favorites, trending items, and hidden gems within this collection. Our advanced filtering and search capabilities make it easy to find exactly what you\'re looking for.',
                          )
                              .animate()
                              .fadeIn(delay: 800.ms, duration: 600.ms)
                              .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  curve: Curves.easeOutCubic),
                        ),

                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFloatingHeader(),
            ),
          ],
        ),
      ),
    );
  }
}
