// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/navigation/app_navigator.dart';
import '../core/navigation/routes.dart';
import '../shared/widgets/misc/text_widget.dart';
import 'app_config_provider.dart';

class ErrorScreen extends StatefulWidget {
  final String message;
  final String? details;
  final String? retryRoute;

  const ErrorScreen({
    super.key,
    required this.message,
    this.details,
    this.retryRoute,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _errorIconController;
  late final Animation<double> _errorIconShakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _logErrorDisplay();
  }

  void _initializeAnimation() {
    _errorIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _errorIconShakeAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _errorIconController,
      curve: Curves.easeInOut,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _errorIconController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _errorIconController.forward();
        }
      });

    _errorIconController.forward();
  }

  void _logErrorDisplay() async {
    await Provider.of<FirebaseAnalytics>(context, listen: false).logEvent(
      name: 'error_screen_displayed',
      parameters: {
        'error': widget.message,
        'details': widget.details ?? 'none',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void dispose() {
    _errorIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor.withOpacity(0.9),
            AppColors.primaryColor.withOpacity(0.4),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Error Icon',
              child: AnimatedBuilder(
                animation: _errorIconShakeAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _errorIconShakeAnimation.value,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextWidget(
              text: 'Oops, Something Went Wrong!',
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
              // semanticsLabel: 'Error Title',
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: TextWidget(
                text: widget.message,
                fontSize: 15.sp,
                color: Colors.white,
                textAlign: TextAlign.center,
                // semanticsLabel: 'Error Message',
              ),
            ),
            if (widget.details != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: TextWidget(
                  text: 'Details: ${widget.details}',
                  fontSize: 12.sp,
                  color: Colors.white70,
                  textAlign: TextAlign.center,
                  // semanticsLabel: 'Error Details',
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<FirebaseAnalytics>(context, listen: false)
                    .logEvent(
                  name: 'retry_button_clicked',
                  parameters: {'timestamp': DateTime.now().toIso8601String()},
                );
                Provider.of<AppConfigProvider>(context, listen: false)
                    .clearError();
                if (widget.retryRoute != null) {
                  NH.nameForceNavigate(widget.retryRoute!, arguments: null);
                } else {
                  // Trigger re-initialization or fallback to home
                  NH.nameForceNavigate(AppRoutes.home, arguments: null);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
                shadowColor: AppColors.primaryColor.withOpacity(0.4),
              ),
              child: TextWidget(
                text: 'Try Again',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                // semanticsLabel: 'Retry Button',
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await Provider.of<FirebaseAnalytics>(context, listen: false)
                    .logEvent(
                  name: 'contact_support_clicked',
                  parameters: {'timestamp': DateTime.now().toIso8601String()},
                );
                if (kDebugMode) {
                  print(
                      'Contact Support clicked - implement email or support page');
                }
              },
              child: TextWidget(
                text: 'Contact Support',
                fontSize: 13.sp,
                color: AppColors.primaryColor,
                decoration: TextDecoration.underline,
                // semanticsLabel: 'Contact Support Button',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
