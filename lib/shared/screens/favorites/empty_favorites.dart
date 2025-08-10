import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/misc/text_widget.dart';

class AnimatedEmptyState extends StatefulWidget {
  final String contentType;
  final VoidCallback onExplore;

  const AnimatedEmptyState({
    super.key,
    required this.contentType,
    required this.onExplore,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _breathController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _floatingAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Main animation controller for the icon
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Floating animation controller
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Breathing animation controller
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Enhanced scale animation with smooth transitions
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
    ]).animate(_mainController);

    // Subtle rotation animation
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.03)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.03, end: -0.03)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.03, end: 0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25,
      ),
    ]).animate(_mainController);

    // Smooth opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutQuart),
    ));

    // Glow animation
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ));

    // Floating animation
    _floatingAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.015),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.015),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_floatingController);

    // Start animations
    _mainController.repeat();
    _floatingController.repeat();
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  String _getEmptyStateIcon() {
    switch (widget.contentType.toLowerCase()) {
      case 'video':
      case 'videos':
        return 'play_circle_outline';
      case 'image':
      case 'images':
      case 'wallpaper':
      case 'wallpapers':
        return 'image_outlined';
      case 'manga':
        return 'menu_book_outlined';
      case 'anime':
        return 'movie_outlined';
      default:
        return 'favorite_outline';
    }
  }

  IconData _getContentIcon() {
    switch (widget.contentType.toLowerCase()) {
      case 'video':
      case 'videos':
        return Icons.play_circle_outline_rounded;
      case 'image':
      case 'images':
      case 'wallpaper':
      case 'wallpapers':
        return Icons.image_outlined;
      case 'manga':
        return Icons.menu_book_outlined;
      case 'anime':
        return Icons.movie_outlined;
      default:
        return Icons.favorite_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 1500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        curve: Curves.easeOutQuint,
        child: FadeInAnimation(
          curve: Curves.easeOutQuart,
          child: Container(
            constraints: BoxConstraints(maxWidth: 85.w),
            child: CustomPadding(
              horizontalFactor: .04,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildEnhancedAnimatedIcon(isDark),
                  SizedBox(height: 5.h),
                  _buildEnhancedTitle(theme),
                  SizedBox(height: 2.h),
                  _buildEnhancedSubtitle(theme),
                  SizedBox(height: 6.h),
                  _buildEnhancedExploreButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAnimatedIcon(bool isDark) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _floatingController,
          _breathController,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: _floatingAnimation.value * 30,
            child: Transform.rotate(
              angle: _rotationAnimation.value * math.pi,
              child: Transform.scale(
                scale: _scaleAnimation.value * (_isHovered ? 1.05 : 1.0),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    boxShadow: [
                      // Primary shadow
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        blurRadius: 30 + (10 * _glowAnimation.value),
                        spreadRadius: 5 + (3 * _glowAnimation.value),
                      ),
                      // Soft ambient shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      // Inner glow effect
                      BoxShadow(
                        color: AppColors.primaryColor
                            .withOpacity(0.1 * _glowAnimation.value),
                        blurRadius: 40,
                        spreadRadius: -10,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primaryColor
                          .withOpacity(0.2 + (0.2 * _glowAnimation.value)),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background icon with opacity
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Icon(
                          _getContentIcon(),
                          size: 80,
                          color: AppColors.primaryColor.withOpacity(0.15),
                        ),
                      ),

                      // Main icon
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Icon(
                          _getContentIcon(),
                          size: 70,
                          color: AppColors.primaryColor.withOpacity(0.8),
                        ),
                      ),

                      // Floating particles
                      ..._buildFloatingParticles(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(3, (index) {
      final delays = [0, 800, 1600];
      final sizes = [8.0, 6.0, 4.0];
      final positions = [
        const Offset(0.7, 0.3),
        const Offset(0.2, 0.6),
        const Offset(0.8, 0.8),
      ];

      return Positioned(
        left: 140 * positions[index].dx,
        top: 140 * positions[index].dy,
        child: Container(
          width: sizes[index],
          height: sizes[index],
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor.withOpacity(0.6),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
              delay: Duration(milliseconds: delays[index]),
            )
            .fadeIn(duration: 1.seconds)
            .then()
            .fadeOut(duration: 1.seconds),
      );
    });
  }

  Widget _buildEnhancedTitle(ThemeData theme) {
    return Hero(
      tag: 'empty_state_title_${widget.contentType}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              TextWidget(
                text: 'No ${_getContentTypeDisplay()} yet',
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleLarge?.color,
                textAlign: TextAlign.center,
                letterSpacing: -0.5,
              ),
              SizedBox(height: 1.h),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.8),
                      AppColors.primaryColor.withOpacity(0.4),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideX(
                  begin: -1,
                  duration: 800.ms,
                  delay: 800.ms,
                  curve: Curves.easeOutQuart),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 700.ms, delay: 400.ms).slideY(
          begin: 0.3,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutQuint,
          delay: 400.ms,
        );
  }

  String _getContentTypeDisplay() {
    switch (widget.contentType.toLowerCase()) {
      case 'video':
      case 'videos':
        return 'favorite videos';
      case 'image':
      case 'images':
        return 'favorite images';
      case 'wallpaper':
      case 'wallpapers':
        return 'favorite wallpapers';
      case 'manga':
        return 'favorite manga';
      case 'anime':
        return 'favorite anime';
      default:
        return '${widget.contentType} favorites';
    }
  }

  Widget _buildEnhancedSubtitle(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: TextWidget(
        text:
            'Discover amazing ${widget.contentType.toLowerCase()} and save your favorites to build your personal collection!',
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
        textAlign: TextAlign.center,
        maxLine: 3,
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutQuint,
          delay: 600.ms,
        );
  }

  Widget _buildEnhancedExploreButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => HapticFeedback.lightImpact(),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onExplore();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.4),
                  blurRadius: _isHovered ? 25 : 20,
                  spreadRadius: _isHovered ? 3 : 1,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                TextWidget(
                  text: 'Start Exploring',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 900.ms, delay: 800.ms)
        .slideY(
          begin: 0.4,
          end: 0,
          duration: 900.ms,
          curve: Curves.easeOutQuint,
          delay: 800.ms,
        )
        .shimmer(
          duration: 2.seconds,
          delay: 3.seconds,
          color: Colors.white.withOpacity(0.3),
        );
  }
}
