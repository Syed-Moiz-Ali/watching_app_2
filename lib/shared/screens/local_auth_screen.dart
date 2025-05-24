import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../provider/local_auth_provider.dart';
import 'dart:ui' as ui;
import 'dart:math';

import '../widgets/misc/text_widget.dart';

class LocalAuthScreen extends StatefulWidget {
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen>
    with TickerProviderStateMixin {
  // Main animations
  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  // Intro animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Continuous effect animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _particleAnimation;

  // Interactive animations
  late AnimationController _buttonPressController;
  late Animation<double> _buttonScaleAnimation;

  // Background animation values
  List<Color> _gradientColors = [];
  List<Color> _targetGradientColors = [];
  double _gradientAnimationValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize haptic feedback
    HapticFeedback.lightImpact();

    _initializeAnimationControllers();
    _initializeAnimations();
    _initializeGradientColors();

    // Start animations
    _introController.forward();
    _startContinuousAnimations();

    // Check authentication status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
      _startGradientAnimation();
    });
  }

  void _initializeAnimationControllers() {
    // Main controllers
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _initializeAnimations() {
    // Fade animation with easing
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuint),
      ),
    );

    // Scale animation with bounce
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.1, 0.9, curve: Curves.elasticOut),
      ),
    );

    // Staggered slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Continuous subtle pulse animation
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Shimmer effect animation
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Particle flow animation
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.linear,
      ),
    );

    // Button press animation
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonPressController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _initializeGradientColors() {
    // Initialize with default gradient colors
    _gradientColors = [
      Colors.deepPurple.shade900,
      Colors.deepPurple.shade700,
      Colors.indigo.shade500,
    ];

    // Set initial target colors
    _updateTargetGradientColors();
  }

  void _updateTargetGradientColors() {
    // Create random but aesthetically pleasing color combinations
    final baseHue = Random().nextDouble() * 360;

    _targetGradientColors = [
      HSLColor.fromAHSL(1.0, baseHue, 0.7, 0.2).toColor(),
      HSLColor.fromAHSL(1.0, (baseHue + 30) % 360, 0.65, 0.25).toColor(),
      HSLColor.fromAHSL(1.0, (baseHue + 60) % 360, 0.6, 0.3).toColor(),
    ];
  }

  void _startContinuousAnimations() {
    _pulseController.repeat(reverse: true);

    _shimmerController.repeat();

    _particleController.repeat();
  }

  void _startGradientAnimation() {
    // Animate gradient colors smoothly
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      setState(() {
        _updateTargetGradientColors();
      });

      const duration = Duration(seconds: 10);
      // final ticker = TickerProvider.isInstanceOf<TickerProvider>(this) ? this : this;

      AnimationController animController = AnimationController(
        vsync: this,
        duration: duration,
      );

      Animation<double> anim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animController,
          curve: Curves.easeInOut,
        ),
      );

      animController.addListener(() {
        if (!mounted) {
          animController.dispose();
          return;
        }

        setState(() {
          _gradientAnimationValue = anim.value;
        });
      });

      animController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animController.dispose();
          if (mounted) {
            setState(() {
              _gradientColors = List.from(_targetGradientColors);
              _gradientAnimationValue = 0.0;
            });
            _startGradientAnimation();
          }
        }
      });

      animController.forward();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<LocalAuthProvider>(context, listen: false);
    if (authProvider.isProtectionEnabled && !authProvider.isAuthenticated) {
      await authProvider.authenticate();
      if (authProvider.isAuthenticated) {
        HapticFeedback.heavyImpact();
      }
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }

  // Calculate interpolated gradient colors
  List<Color> get _currentGradientColors {
    if (_gradientAnimationValue == 0.0) {
      return _gradientColors;
    }

    return List.generate(
      _gradientColors.length,
      (i) => Color.lerp(
        _gradientColors[i],
        _targetGradientColors[i],
        _gradientAnimationValue,
      )!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Consumer<LocalAuthProvider>(
      builder: (context, authProvider, _) {
        // final isAuthenticated = authProvider.isAuthenticated;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          ),
          body: Stack(
            children: [
              // Advanced animated gradient background
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(_pulseAnimation.value * 0.05 - 0.3,
                            _pulseAnimation.value * 0.05 - 0.2),
                        radius: 1.8,
                        colors: _currentGradientColors
                            .map((color) =>
                                isDark ? color : color.withOpacity(0.2))
                            .toList(),
                        stops: const [0.1, 0.5, 0.9],
                      ),
                    ),
                  );
                },
              ),

              // Dynamic noise overlay for texture
              Opacity(
                opacity: isDark ? 0.04 : 0.02,
                child: CustomPaint(
                  painter: NoisePainter(seed: 42),
                  size: Size.infinite,
                ),
              ),

              // Advanced particle system
              // AnimatedBuilder(
              //   animation: _particleAnimation,
              //   builder: (context, child) {
              //     return CustomPaint(
              //       painter: EnhancedParticlePainter(
              //         baseColor: colorScheme.primary,
              //         secondaryColor: colorScheme.secondary,
              //         time: _particleAnimation.value,
              //         isDark: isDark,
              //       ),
              //       size: Size.infinite,
              //     );
              //   },
              // ),

              // Subtle light flares for depth
              Positioned(
                top: -size.height * 0.2,
                right: -size.width * 0.3,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: size.width * 0.8,
                      height: size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.primary
                                .withOpacity(isDark ? 0.08 : 0.04),
                            colorScheme.primary.withOpacity(0.0),
                          ],
                          stops: [0.0, _pulseAnimation.value],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom: -size.height * 0.1,
                left: -size.width * 0.2,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.secondary
                                .withOpacity(isDark ? 0.07 : 0.03),
                            colorScheme.secondary.withOpacity(0.0),
                          ],
                          stops: [0.0, 1 - _pulseAnimation.value * 0.3],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Subtle mesh grid for depth
              // CustomPaint(
              //   painter: GridPainter(
              //     color: colorScheme.onSurface
              //         .withOpacity(isDark ? 0.03 : 0.02),
              //     pulseValue: _pulseAnimation.value,
              //   ),
              //   size: Size.infinite,
              // ),

              // Main content with enhanced animations
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // Logo and title with enhanced animations
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: _buildEnhancedLogo(
                                      colorScheme, textTheme, isDark),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Status card with enhanced effects
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _introController,
                              curve: const Interval(0.3, 1.0,
                                  curve: Curves.easeOutCubic),
                            ),
                          ),
                          child: _buildEnhancedStatusCard(
                              authProvider, colorScheme, textTheme, isDark),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Enhanced authenticate button
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.4),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _introController,
                              curve: const Interval(0.4, 1.0,
                                  curve: Curves.easeOutCubic),
                            ),
                          ),
                          child: _buildEnhancedAuthButton(
                              authProvider, colorScheme, isDark),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Security info footer
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 0.8).animate(
                          CurvedAnimation(
                            parent: _introController,
                            curve:
                                const Interval(0.7, 1.0, curve: Curves.easeOut),
                          ),
                        ),
                        child: _buildSecurityInfoFooter(colorScheme, textTheme),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLogo(
      ColorScheme colorScheme, TextTheme textTheme, bool isDark) {
    return Column(
      children: [
        // Neo-morphic logo container with 3D effect
        Stack(
          alignment: Alignment.center,
          children: [
            // Shadow layer
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),

            // Outer glow
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.5),
                    colorScheme.primary.withOpacity(0.0),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // Main logo container with glassmorphism
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.7),
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: -3,
                    offset: const Offset(-3, -3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 54,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Subtle highlight line for 3D effect
            Positioned(
              top: 20,
              left: 30,
              child: Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Enhanced title with 3D text effect
        Stack(
          children: [
            // Shadow text for 3D effect
            Opacity(
              opacity: 0.15,
              child: Transform.translate(
                offset: const Offset(2, 2),
                child: TextWidget(
                  text: "SecureAuth",
                  fontWeight: FontWeight.w900,
                  fontSize: 22.sp,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Main title with gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary
                      .withBlue((colorScheme.primary.blue + 30) % 256),
                  colorScheme.secondary,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: TextWidget(
                text: "SecureAuth",
                fontWeight: FontWeight.w900,
                fontSize: 22.sp,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Enhanced subtitle with animated shimmer
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              colorScheme.onSurface.withOpacity(0.6),
              colorScheme.onSurface.withOpacity(0.9),
              colorScheme.onSurface.withOpacity(0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(-1.5 + _shimmerAnimation.value, 0),
            end: Alignment(1.5 + _shimmerAnimation.value, 0),
          ).createShader(bounds),
          child: TextWidget(
            text: "Seamless • Secure • Simple",
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatusCard(LocalAuthProvider authProvider,
      ColorScheme colorScheme, TextTheme textTheme, bool isDark) {
    final isAuthenticated = authProvider.isAuthenticated;

    // Status color based on authentication state
    final statusColor =
        isAuthenticated ? Colors.green.shade400 : colorScheme.error;
    final statusBackgroundColor = isAuthenticated
        ? Colors.green.withOpacity(isDark ? 0.15 : 0.08)
        : colorScheme.error.withOpacity(isDark ? 0.15 : 0.08);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer glow effect
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
        ),

        // Main card with glassmorphism
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.15)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.05)
                        : Colors.white.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated status indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.elasticOut,
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isAuthenticated ? Icons.check_circle : Icons.lock,
                        key: ValueKey<bool>(isAuthenticated),
                        size: 32,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Status information with enhanced typography
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Primary status text
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.05, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: TextWidget(
                                text: isAuthenticated
                                    ? "Authenticated"
                                    : "Locked",
                                key: ValueKey<bool>(isAuthenticated),
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),

                            // Animated dot indicator
                            if (isAuthenticated) ...[
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: statusColor.withOpacity(0.6),
                                          blurRadius:
                                              4 + 3 * _pulseAnimation.value,
                                          spreadRadius:
                                              _pulseAnimation.value * 1,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Detailed status message
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: TextWidget(
                            text: isAuthenticated
                                ? "Your identity is verified and secure"
                                : "Biometric authentication required",
                            key: ValueKey<bool>(isAuthenticated),
                            color: colorScheme.onSurface.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Interactive animated decorative elements
        if (isAuthenticated) ...[
          Positioned(
            top: -8,
            right: 20,
            child: _buildShieldBadge(colorScheme),
          ),
        ],
      ],
    );
  }

  Widget _buildShieldBadge(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.shield,
            color: Colors.green,
            size: 16 + _pulseAnimation.value * 2,
          ),
        );
      },
    );
  }

  Widget _buildEnhancedAuthButton(
      LocalAuthProvider authProvider, ColorScheme colorScheme, bool isDark) {
    final isAuthenticating = authProvider.isAuthenticating;
    final isAuthenticated = authProvider.isAuthenticated;

    // Use different colors based on authentication state
    final List<Color> buttonColors = isAuthenticated
        ? [Colors.blueGrey.shade400, Colors.blueGrey.shade600]
        : [colorScheme.primary, colorScheme.primary.withOpacity(0.8)];

    final iconColor = isAuthenticated
        ? colorScheme.onPrimary.withOpacity(0.9)
        : colorScheme.onPrimary;

    return GestureDetector(
      onTapDown: (_) {
        if (!isAuthenticating) {
          _buttonPressController.forward();
          HapticFeedback.mediumImpact();
        }
      },
      onTapUp: (_) {
        if (!isAuthenticating) {
          _buttonPressController.reverse();
        }
      },
      onTapCancel: () {
        if (!isAuthenticating) {
          _buttonPressController.reverse();
        }
      },
      onTap: isAuthenticating
          ? null
          : () async {
              HapticFeedback.mediumImpact();
              if (isAuthenticated) {
                authProvider.resetAuthentication();
              } else {
                await authProvider.authenticate();
                if (authProvider.isAuthenticated) {
                  HapticFeedback.heavyImpact();
                }
              }
            },
      child: AnimatedBuilder(
        animation: _buttonPressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: buttonColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // Main shadow
                  BoxShadow(
                    color: buttonColors[0].withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  // Inner highlight
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin:
                              Alignment(-1.5 + _shimmerAnimation.value * 2, 0),
                          end: Alignment(1.5 + _shimmerAnimation.value * 2, 0),
                        ).createShader(bounds),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  // Button content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInBack,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: isAuthenticating
                        ? _buildAuthenticatingState(colorScheme)
                        : _buildAuthButtonContent(
                            isAuthenticated, iconColor, colorScheme),
                  ),

                  // Glowing edge effect
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1.5,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthenticatingState(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Enhanced loading indicator
        // SizedBox(
        //   width: 26,
        //   height: 26,
        //   child: Stack(
        //     alignment: Alignment.center,
        //     children: [
        //       // Outer rotating circle
        //       AnimatedBuilder(
        //         animation: _pulseController,
        //         builder: (context, child) {
        //           return CircularProgressIndicator(
        //             strokeWidth: 2.5,
        //             valueColor: AlwaysStoppedAnimation<Color>(
        //               Colors.white
        //                   .withOpacity(0.7 + 0.3 * _pulseAnimation.value),
        //             ),
        //           );
        //         },
        //       ),
        //       // Inner pulsing circle
        //       AnimatedBuilder(
        //         animation: _pulseController,
        //         builder: (context, child) {
        //           return Container(
        //             width: 10 + 3 * _pulseAnimation.value,
        //             height: 10 + 3 * _pulseAnimation.value,
        //             decoration: BoxDecoration(
        //               shape: BoxShape.circle,
        //               color: Colors.white.withOpacity(0.7),
        //             ),
        //           );
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(width: 14),
        const TextWidget(
          text: "Verifying Identity...",
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ],
    );
  }

  Widget _buildAuthButtonContent(
      bool isAuthenticated, Color iconColor, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isAuthenticated ? Icons.lock_open : Icons.fingerprint,
            key: ValueKey<bool>(isAuthenticated),
            size: 28,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 14),
        // Dynamic text based on auth state
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: TextWidget(
            key: ValueKey<bool>(isAuthenticated),
            text: isAuthenticated ? "Sign Out" : "Authenticate",
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInfoFooter(
      ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.security,
          size: 16,
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        TextWidget(
          text: "Enterprise-grade security",
          color: colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}

/// Creates a noise texture effect for visual depth
class NoisePainter extends CustomPainter {
  final int seed;
  final double density;
  final double opacity;

  NoisePainter({
    required this.seed,
    this.density = 0.7,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    // Calculate number of noise points based on screen size and density
    final pointsCount = (size.width * size.height * density / 100).round();

    for (int i = 0; i < pointsCount; i++) {
      // Random position
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Random size between 0.5 and 1.5
      final dotSize = 0.5 + random.nextDouble();

      // Random opacity variation for more realistic noise
      final pointOpacity = 0.3 + random.nextDouble() * 0.7;

      // Random grayscale value for the noise
      final colorValue = random.nextDouble() * 255;

      paint.color = Color.fromRGBO(colorValue.round(), colorValue.round(),
          colorValue.round(), pointOpacity * opacity);

      canvas.drawCircle(Offset(x, y), dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) {
    return oldDelegate.seed != seed ||
        oldDelegate.density != density ||
        oldDelegate.opacity != opacity;
  }
}

/// Creates animated flowing particles for a dynamic background effect
class EnhancedParticlePainter extends CustomPainter {
  final Color baseColor;
  final Color secondaryColor;
  final double time;
  final bool isDark;
  final int particleCount;

  EnhancedParticlePainter({
    required this.baseColor,
    required this.secondaryColor,
    required this.time,
    required this.isDark,
    this.particleCount = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    // Optimize by pre-calculating particles
    final particles = List.generate(particleCount, (_) {
      // Generate random initial positions
      final initialX = random.nextDouble() * size.width;
      final initialY = random.nextDouble() * size.height;

      // Randomize particle size
      final particleSize = 2.0 + random.nextDouble() * 4.0;

      // Random speed and direction
      final speedX = -0.5 + random.nextDouble() * 1.0;
      final speedY = -0.2 + random.nextDouble() * 0.4;

      // Apply time factor to position for animation
      final x = (initialX + speedX * time * size.width) % size.width;
      final y = (initialY + speedY * time * size.height) % size.height;

      // Randomize color between base and secondary
      final useBaseColor = random.nextBool();
      final color = useBaseColor ? baseColor : secondaryColor;

      // Vary opacity for depth effect
      final opacity = (0.2 + random.nextDouble() * 0.3) * (isDark ? 0.7 : 0.4);

      return {
        'position': Offset(x, y),
        'size': particleSize,
        'color': color.withOpacity(opacity),
        'trail': random.nextDouble() > 0.7, // Some particles have trails
      };
    });

    // Draw the particles
    for (final particle in particles) {
      final position = particle['position'] as Offset;
      final size = particle['size'] as double;
      final color = particle['color'] as Color;
      final hasTrail = particle['trail'] as bool;

      // Draw glow effect for larger particles
      if (size > 4.0) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

        canvas.drawCircle(position, size * 2.5, glowPaint);
      }

      // Draw trail if this particle has one
      if (hasTrail) {
        // Create a path for the trail
        final trailPath = Path();
        trailPath.moveTo(position.dx, position.dy);

        // Add points for a curved trail
        final trailLength = random.nextDouble() * 20 + 10;
        trailPath.lineTo(position.dx - trailLength * cos(time * 2),
            position.dy - trailLength * sin(time * 2));

        // Trail gradient
        final trailPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.4
          ..shader = ui.Gradient.linear(
            position,
            Offset(position.dx - trailLength, position.dy - trailLength),
            [
              color,
              color.withOpacity(0.0),
            ],
          );

        canvas.drawPath(trailPath, trailPaint);
      }

      // Draw the particle
      final paint = Paint()..color = color;

      canvas.drawCircle(position, size, paint);
    }

    // Add a few larger, more prominent particles
    for (int i = 0; i < 5; i++) {
      final x = (random.nextDouble() * size.width + time * 50) % size.width;
      final y = (random.nextDouble() * size.height + time * 20) % size.height;
      final prominentSize = 5.0 + random.nextDouble() * 3.0;

      // Pulsate size based on time
      final pulseEffect = 1.0 + 0.2 * sin(time * 2 * pi + i);
      final actualSize = prominentSize * pulseEffect;

      // Shimmer effect with time-based alpha
      final shimmerAlpha = 0.5 + 0.5 * sin(time * 3 + i);

      // Create gradient glow effect
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            isDark
                ? baseColor.withOpacity(0.5 * shimmerAlpha)
                : baseColor.withOpacity(0.3 * shimmerAlpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(x, y),
          radius: actualSize * 3.0,
        ));

      canvas.drawCircle(Offset(x, y), actualSize * 3.0, glowPaint);

      // Draw core of the particle
      final corePaint = Paint()
        ..color = isDark
            ? baseColor.withOpacity(0.8 * shimmerAlpha)
            : baseColor.withOpacity(0.6 * shimmerAlpha);

      canvas.drawCircle(Offset(x, y), actualSize, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedParticlePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.isDark != isDark;
  }
}

/// Creates a subtle grid pattern for depth and dimension
class GridPainter extends CustomPainter {
  final Color color;
  final double pulseValue;
  final double spacing;

  GridPainter({
    required this.color,
    required this.pulseValue,
    this.spacing = 30.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Apply subtle animation to grid spacing
    final dynamicSpacing = spacing * (0.95 + 0.05 * pulseValue);

    // Calculate grid dimensions
    final horizontalLines = (size.height / dynamicSpacing).ceil() + 1;
    final verticalLines = (size.width / dynamicSpacing).ceil() + 1;

    // Small perspective effect by varying line thickness
    final perspectiveCenter = Offset(size.width / 2, size.height / 2);

    // Draw horizontal lines
    for (int i = 0; i < horizontalLines; i++) {
      final y = i * dynamicSpacing;

      // Starting point
      final start = Offset(0, y);
      // End point
      final end = Offset(size.width, y);

      // Calculate distance from perspective center for line opacity
      final distanceRatio =
          (y - perspectiveCenter.dy).abs() / (size.height / 2);
      final opacity = 1.0 - distanceRatio * 0.7;

      // Update paint for this line
      paint.color = color.withOpacity(opacity * (0.6 + 0.4 * pulseValue));

      canvas.drawLine(start, end, paint);
    }

    // Draw vertical lines
    for (int i = 0; i < verticalLines; i++) {
      final x = i * dynamicSpacing;

      // Starting point
      final start = Offset(x, 0);
      // End point
      final end = Offset(x, size.height);

      // Calculate distance from perspective center for line opacity
      final distanceRatio = (x - perspectiveCenter.dx).abs() / (size.width / 2);
      final opacity = 1.0 - distanceRatio * 0.7;

      // Update paint for this line
      paint.color = color.withOpacity(opacity * (0.6 + 0.4 * pulseValue));

      canvas.drawLine(start, end, paint);
    }

    // Add subtle crosspoints for more visual interest
    final crossPointPaint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < horizontalLines; y++) {
      for (int x = 0; x < verticalLines; x++) {
        final xPos = x * dynamicSpacing;
        final yPos = y * dynamicSpacing;

        // Calculate distance from center for size and opacity
        final distance = (Offset(xPos, yPos) - perspectiveCenter).distance;
        final maxDistance = perspectiveCenter.distance;
        final distanceRatio = distance / maxDistance;

        // Size and opacity based on distance from center
        final dotSize = 1.2 * (1.0 - distanceRatio * 0.7) * pulseValue;
        final dotOpacity = 0.3 * (1.0 - distanceRatio * 0.5);

        if (dotSize > 0.3) {
          crossPointPaint.color = color.withOpacity(dotOpacity);
          canvas.drawCircle(Offset(xPos, yPos), dotSize, crossPointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.spacing != spacing;
  }
}
