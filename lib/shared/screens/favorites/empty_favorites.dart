import 'dart:math' as math;
import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutQuint)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuint)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 20,
      ),
    ]).animate(_controller);

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.05)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 80,
      ),
    ]).animate(_controller);

    _controller.repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 1200),
      child: SlideAnimation(
        verticalOffset: 30.0,
        curve: Curves.easeOutQuint,
        child: FadeInAnimation(
          curve: Curves.easeOut,
          child: Container(
            constraints: BoxConstraints(maxWidth: 80.w),
            child: CustomPadding(
              horizontalFactor: .03,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedIcon(),
                  SizedBox(height: 4.h),
                  _buildTitle(),
                  SizedBox(height: 1.5.h),
                  _buildSubtitle(),
                  SizedBox(height: 5.h),
                  _buildExploreButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * math.pi,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).cardColor,
                    Theme.of(context).cardColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 70,
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 64,
                      color: AppColors.primaryColor,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryColor.withOpacity(0.7),
                        ),
                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .scaleXY(
                            begin: 0.8,
                            end: 1.2,
                            duration: 1.5.seconds,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scaleXY(
                            begin: 1.2,
                            end: 0.8,
                            duration: 1.5.seconds,
                            curve: Curves.easeInOut,
                          ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Hero(
      tag: 'empty_state_title_${widget.contentType}',
      child: Material(
        color: Colors.transparent,
        child: TextWidget(
          text: 'No ${widget.contentType} favorites yet',
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.titleLarge?.color,
          textAlign: TextAlign.center,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuint,
          delay: 300.ms,
        );
  }

  Widget _buildSubtitle() {
    return TextWidget(
      text: 'Browse content and heart your favorites to see them here!',
      fontWeight: FontWeight.w400,
      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      textAlign: TextAlign.center,
      maxLine: 4,
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuint,
          delay: 500.ms,
        );
  }

  Widget _buildExploreButton() {
    return InkWell(
      onTap: widget.onExplore,
      borderRadius: BorderRadius.circular(14.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.h),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withBlue(
                (AppColors.primaryColor.blue * 1.3).clamp(0, 255).toInt(),
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_rounded,
              color: AppColors.backgroundColorLight,
              size: 22.sp,
            ),
            SizedBox(width: 3.w),
            TextWidget(
              text: 'Explore Now',
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.backgroundColorLight,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 700.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutQuint,
          delay: 700.ms,
        )
        .shimmer(
          duration: 1.5.seconds,
          delay: 2.seconds,
          color: Colors.white.withOpacity(0.7),
        );
  }
}
