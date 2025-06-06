import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';

import '../shared/widgets/misc/text_widget.dart';
import 'app_initializer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeAndNavigate();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  Future<void> _initializeAndNavigate() async {
    final (route, args) = await AppInitializer.initializeApp();
    if (!mounted) return;

    // Subtle fade out before navigation
    await _animationController.reverse(from: 1.0);
    NH.nameForceNavigate(route, arguments: args);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Premium dark gradient background
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium logo container with subtle glow
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App name with premium thin typography
              TextWidget(
                text: 'BrowseX',
                fontSize: 22.sp,
                fontWeight: FontWeight.w300,
                letterSpacing: 6,
                color: AppColors.primaryColor,
              ),

              const SizedBox(height: 8),

              // Tagline text
              TextWidget(
                text: 'Premium Viewing Experience',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryColor.withOpacity(0.7),
                letterSpacing: 0.5,
              ),

              const SizedBox(height: 48),

              // Elegant custom divider
              Container(
                width: 30,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0),
                      AppColors.primaryColor.withOpacity(0.7),
                      AppColors.primaryColor.withOpacity(0),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Custom styled loading indicator
              // const SizedBox(
              //   width: 36,
              //   height: 36,
              //   child: CustomLoadingIndicator(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
