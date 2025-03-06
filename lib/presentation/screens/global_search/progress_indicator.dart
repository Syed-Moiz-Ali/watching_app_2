import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';

class RealtimeProgressIndicator extends StatefulWidget {
  final List<String> sourceNames;
  final int activeSourceIndex;
  final bool isGrid;
  final Color? primaryColor;
  final Color? accentColor;
  final Color? backgroundColor;

  const RealtimeProgressIndicator({
    super.key,
    required this.sourceNames,
    required this.activeSourceIndex,
    required this.isGrid,
    this.primaryColor,
    this.accentColor,
    this.backgroundColor,
  });

  @override
  State<RealtimeProgressIndicator> createState() =>
      _RealtimeProgressIndicatorState();
}

class _RealtimeProgressIndicatorState extends State<RealtimeProgressIndicator>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _typingController;
  late AnimationController _loadingDotsController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _breatheController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<int> _typingTextAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _breatheAnimation;

  // Particle system
  // final List<ParticleModel> _particles = [];

  // Shimmer animation properties

  // Loading dots text
  final List<String> _loadingDots = [".", "..", "..."];
  int _currentDotIndex = 0;

  // Source transition tracking
  int? _previousActiveIndex;

  @override
  void initState() {
    super.initState();

    // Store initial active index
    _previousActiveIndex = widget.activeSourceIndex;

    // Pulse animation for the active source
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressController.forward();

    // Typing animation for "Searching Content"
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _typingTextAnimation = IntTween(begin: 0, end: 16).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeIn),
    );

    _typingController.forward();

    // Loading dots animation
    _loadingDotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentDotIndex = (_currentDotIndex + 1) % _loadingDots.length;
          });
          _loadingDotsController.reset();
          _loadingDotsController.forward();
        }
      });

    _loadingDotsController.forward();

    // Continuous rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Initialize particles

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Breathing animation for background elements
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(RealtimeProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Store previous index for transition animations
    _previousActiveIndex = oldWidget.activeSourceIndex;

    if (oldWidget.activeSourceIndex != widget.activeSourceIndex) {
      // Update progress animation when the active source changes

      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _typingController.dispose();
    _loadingDotsController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  Color get primaryColor =>
      widget.primaryColor ?? Theme.of(context).primaryColor;
  Color get accentColor =>
      widget.accentColor ??
      primaryColor.withBlue(math.min(primaryColor.blue + 60, 255));
  Color get backgroundColor =>
      widget.backgroundColor ?? Theme.of(context).cardColor;

  @override
  Widget build(BuildContext context) {
    // Get the previous, current, and next source
    String currentSource = widget.sourceNames.isNotEmpty &&
            widget.activeSourceIndex < widget.sourceNames.length
        ? widget.sourceNames[widget.activeSourceIndex]
        : "Unknown";

    String? previousSource = widget.activeSourceIndex > 0
        ? widget.sourceNames[widget.activeSourceIndex - 1]
        : null;

    String? nextSource =
        widget.activeSourceIndex < widget.sourceNames.length - 1
            ? widget.sourceNames[widget.activeSourceIndex + 1]
            : null;

    return Column(
      children: [
        // Ultra-premium frosted glass progress header
        _buildUltraPremiumHeader(currentSource, previousSource, nextSource),

        // Enhanced shimmer content with animated elements
        Expanded(
          child: _buildPremiumShimmerContent(),
        ),
      ],
    );
  }

  Widget _buildUltraPremiumHeader(
      String currentSource, String? previousSource, String? nextSource) {
    const String fullText = "Searching Content";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with animated typing effect and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(
                                        0.3 * _glowAnimation.value),
                                    blurRadius: 10 * _glowAnimation.value,
                                    spreadRadius: 1 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.search,
                                color: primaryColor,
                                size: 18,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  // Animated text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _typingTextAnimation,
                        builder: (context, child) {
                          String displayText = fullText.substring(
                              0, _typingTextAnimation.value + 1);

                          return TextWidget(
                            text: displayText,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          );
                        },
                      ),

                      // Subtitle with fade-in animation
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextWidget(
                          text: 'Finding relevant information',
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // Animated loading dots
                  AnimatedBuilder(
                    animation: _loadingDotsController,
                    builder: (context, child) {
                      return TextWidget(
                        text: _loadingDots[_currentDotIndex],
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      );
                    },
                  ),
                ],
              ),

              // Animated counter badge
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.8),
                            accentColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextWidget(
                        text:
                            '${widget.activeSourceIndex + 1}/${widget.sourceNames.length}',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Enhanced source flow with 3D and depth effects
          _buildPremiumSourceFlow(currentSource, previousSource, nextSource),

          const SizedBox(height: 32),

          // Glow-animated progress bar
          // _buildGlowingProgressBar(),
        ],
      ),
    );
  }

  Widget _buildPremiumSourceFlow(
      String currentSource, String? previousSource, String? nextSource) {
    return Row(
      children: [
        // Previous source with completed state and transition animation
        if (previousSource != null)
          Expanded(
            child: _buildPremiumSourceItem(
              name: previousSource,
              isActive: false,
              isCompleted: true,
              wasActive: _previousActiveIndex == widget.activeSourceIndex - 1,
            ),
          )
        else
          const Spacer(),

        // Animated connection line for completed sources
        if (previousSource != null)
          _buildAnimatedConnectionLine(isCompleted: true),

        const SizedBox(width: 8),

        // Current source with 3D pulse animation
        Expanded(
          flex: 2,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..scale(_pulseAnimation.value)
                  ..rotateX((_pulseAnimation.value - 1) * 0.05)
                  ..rotateY((_pulseAnimation.value - 1) * 0.05),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: _buildPremiumSourceItem(
              name: currentSource,
              isActive: true,
              isCompleted: false,
              wasActive: false,
              showParticles: true,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Animated connection line for pending sources
        if (nextSource != null)
          _buildAnimatedConnectionLine(isCompleted: false),

        // Next source with pending state
        if (nextSource != null)
          Expanded(
            child: _buildPremiumSourceItem(
              name: nextSource,
              isActive: false,
              isCompleted: false,
              wasActive: _previousActiveIndex == widget.activeSourceIndex + 1,
            ),
          )
        else
          const Spacer(),
      ],
    );
  }

  Widget _buildAnimatedConnectionLine({required bool isCompleted}) {
    return SizedBox(
      width: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base line
          Container(
            height: 2,
            color: isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),

          // Animated particle effect on the line
          if (isCompleted)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return Positioned(
                  left: 40 * _particleController.value - 10,
                  child: Container(
                    width: 10,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Direction arrow
          Positioned(
            right: 5,
            child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        _pulseController.value * (isCompleted ? 2 : -2), 0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: isCompleted ? Colors.green : Colors.grey,
                      size: isCompleted ? 22 : 18,
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSourceItem({
    required String name,
    required bool isActive,
    required bool isCompleted,
    required bool wasActive,
    bool showParticles = false,
  }) {
    // Define base colors
    Color bgColor;
    Color textColor;
    IconData iconData;

    if (isActive) {
      bgColor = primaryColor;
      textColor = Colors.white;
      iconData = Icons.sync;
    } else if (isCompleted) {
      bgColor = Colors.green;
      textColor = Colors.white;
      iconData = Icons.check;
    } else {
      bgColor = Colors.grey[300]!;
      textColor = Colors.grey[700]!;
      iconData = Icons.hourglass_empty;
    }

    // Create animated transition
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: wasActive ? 1.2 : (isActive ? 0.8 : 1.0),
        end: isActive ? 1.0 : (wasActive ? 0.8 : 1.0),
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isActive ? 16 : 12,
              horizontal: isActive ? 16 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(isActive ? 0.5 : 0.3),
                  blurRadius: isActive ? 15 : 8,
                  offset: const Offset(0, 4),
                  spreadRadius: isActive ? 1 : 0,
                ),
                if (isActive)
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
              ],
              gradient: LinearGradient(
                colors: isActive
                    ? [
                        primaryColor,
                        accentColor,
                      ]
                    : isCompleted
                        ? [
                            Colors.green.shade600,
                            Colors.green.shade400,
                          ]
                        : [
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Particle effect for active item
                // if (isActive && showParticles)
                //   Positioned.fill(
                //     child: AnimatedBuilder(
                //       animation: _particleController,
                //       builder: (context, child) {
                //         return CustomPaint(
                //           painter: ParticlePainter(
                //             particles: _particles,
                //             animation: _particleController,
                //             color: Colors.white.withOpacity(0.4),
                //           ),
                //         );
                //       },
                //     ),
                //   ),

                // Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with special animation for active state
                    isActive
                        ? _buildAnimatedActiveIcon(iconData, textColor)
                        : isCompleted
                            ? _buildCompletedIcon(iconData, textColor)
                            : Icon(
                                iconData,
                                color: textColor,
                                size: 22,
                              ),

                    const SizedBox(height: 8),

                    // Text with optional glow effect
                    AnimatedBuilder(
                      animation: isActive ? _glowAnimation : _breatheAnimation,
                      builder: (context, child) {
                        return TextWidget(
                          text: name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          color: textColor,
                        );
                      },
                    ),
                  ],
                ),

                // Status indicator badge for active item
                if (isActive)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor
                                    .withOpacity(0.5 * _glowAnimation.value),
                                blurRadius: 4 * _glowAnimation.value,
                                spreadRadius: 1 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedActiveIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),

            // Rotating inner circle
            Transform.rotate(
              angle: _rotationController.value * 1.5,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.6),
                    width: 1,
                  ),
                ),
              ),
            ),

            // Icon with pulse
            Transform.rotate(
              angle: _pulseController.value * 0.2 - 0.1,
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompletedIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumShimmerContent() {
    // Dynamic layout based on the grid option
    if (widget.isGrid) {
      return _buildGridShimmerLayout();
    } else {
      return _buildListShimmerLayout();
    }
  }

  Widget _buildGridShimmerLayout() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _breatheAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breatheAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity * 0.7,
                              height: 12,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListShimmerLayout() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AnimatedBuilder(
              animation: _breatheAnimation,
              builder: (context, child) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 88,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity * 0.8,
                              height: 12,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// // Particle model for the animated background effect
// class ParticleModel {
//   Offset position;
//   Offset speed;
//   double radius;
//   double alpha;

//   ParticleModel({
//     required this.position,
//     required this.speed,
//     required this.radius,
//     required this.alpha,
//   });

//   factory ParticleModel.random() {
//     final random = math.Random();
//     return ParticleModel(
//       position: Offset(
//         random.nextDouble() * 400,
//         random.nextDouble() * 200,
//       ),
//       speed: Offset(
//         (random.nextDouble() - 0.5) * 2,
//         (random.nextDouble() - 0.5) * 2,
//       ),
//       radius: random.nextDouble() * 6 + 1,
//       alpha: random.nextDouble() * 0.5 + 0.3,
//     );
//   }

//   void update() {
//     position += speed;

//     // Bounce off boundaries
//     if (position.dx < 0 || position.dx > 400) {
//       speed = Offset(-speed.dx, speed.dy);
//     }

//     if (position.dy < 0 || position.dy > 200) {
//       speed = Offset(speed.dx, -speed.dy);
//     }
//   }
// }

// // Custom painter for rendering particles
// class ParticlePainter extends CustomPainter {
//   final List<ParticleModel> particles;
//   final AnimationController animation;
//   final Color color;

//   ParticlePainter({
//     required this.particles,
//     required this.animation,
//     required this.color,
//   }) : super(repaint: animation);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     // Update and draw each particle
//     for (final particle in particles) {
//       particle.update();

//       paint.color = color.withOpacity(particle.alpha);
//       canvas.drawCircle(
//         particle.position,
//         particle.radius,
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(ParticlePainter oldDelegate) => true;
// }
