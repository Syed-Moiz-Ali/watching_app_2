// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/core/navigation/navigator.dart';
import 'package:watching_app_2/presentation/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';

class ErrorPage extends StatefulWidget {
  final String errorMessage;

  const ErrorPage({super.key, required this.errorMessage});

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Slide and fade controller
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Bounce controller for the icon
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Pulse controller for the button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Slide animation with spring effect
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const SpringCurve(),
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    // Bounce animation for the icon
    _bounceAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Pulse animation for the button
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF2d2d2d),
            ],
          ),
        ),
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_bounceAnimation.value),
                          child: const Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.redAccent,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.red, Colors.orange],
                      ).createShader(bounds),
                      child: TextWidget(
                        text: 'Oops! Something Went Wrong',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        maxLine: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextWidget(
                      text: widget.errorMessage,
                      color: Colors.white70,
                      fontSize: 16.sp,
                      maxLine: 4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: PrimaryButton(
                            onTap: () {
                              NH.navigateBack();
                              NH.navigateBack();
                            },
                            // Navigator.pop(context),
                            borderRadius: 100.w,
                            child: TextWidget(
                              text: 'Try Again',
                              fontSize: 19.sp,
                              color: AppColors.backgroundColorLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom spring curve for more natural motion
class SpringCurve extends Curve {
  const SpringCurve([
    this.a = 0.15,
    this.w = 19.4,
  ]);
  final double a;
  final double w;

  @override
  double transformInternal(double t) {
    return -(pow(e, -t / a) * cos(t * w)) + 1;
  }
}
