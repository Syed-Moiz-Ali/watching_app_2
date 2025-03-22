import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomLoadingIndicator extends StatefulWidget {
  final Color? primaryColor;
  final Color? secondaryColor;
  final double? size;
  final Duration duration;
  final bool useGlassmorphism;

  const CustomLoadingIndicator({
    super.key,
    this.primaryColor,
    this.secondaryColor,
    this.size,
    this.duration = const Duration(milliseconds: 1500),
    this.useGlassmorphism = true,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _primaryRotationController;
  late AnimationController _secondaryRotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Primary rotation animation controller - continuous rotation
    _primaryRotationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    // Secondary rotation animation controller - different speed, continuous rotation
    _secondaryRotationController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: (widget.duration.inMilliseconds * 1.5).round()),
    )..repeat();

    // Pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Pulse animation that scales the indicator
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _primaryRotationController.dispose();
    _secondaryRotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final Color secondaryColor = widget.secondaryColor ??
        (theme.colorScheme.secondary != primaryColor
            ? theme.colorScheme.secondary
            : primaryColor.withOpacity(0.7));

    // Calculate responsive size based on screen width if not provided
    final double calculatedSize =
        widget.size ?? MediaQuery.of(context).size.shortestSide * 0.15;

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _primaryRotationController,
          _secondaryRotationController,
          _pulseController
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: SizedBox(
              width: calculatedSize,
              height: calculatedSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background glow effect
                  if (widget.useGlassmorphism)
                    Container(
                      width: calculatedSize * 1.2,
                      height: calculatedSize * 1.2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),

                  // Glass background
                  if (widget.useGlassmorphism)
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: calculatedSize,
                          height: calculatedSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Primary spinning arc - continuous rotation
                  Transform.rotate(
                    angle: _primaryRotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(calculatedSize, calculatedSize),
                      painter: ArcPainter(
                        color: primaryColor,
                        strokeWidth: calculatedSize * 0.08,
                        startAngle: 0,
                        sweepAngle: 270,
                      ),
                    ),
                  ),

                  // Secondary spinning arc - continuous rotation at different speed
                  Transform.rotate(
                    angle: -_secondaryRotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(calculatedSize * 0.7, calculatedSize * 0.7),
                      painter: ArcPainter(
                        color: secondaryColor,
                        strokeWidth: calculatedSize * 0.06,
                        startAngle: 45,
                        sweepAngle: 180,
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
}

// Custom painter for drawing arcs with rounded caps
class ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle * (math.pi / 180),
      sweepAngle * (math.pi / 180),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Extension to make the component even more adaptable
extension CustomLoadingIndicatorExtensions on CustomLoadingIndicator {
  // Static factory method for creating a minimalist version
  static Widget minimalist({
    Color? color,
    double? size,
    Key? key,
  }) {
    return CustomLoadingIndicator(
      key: key,
      primaryColor: color,
      size: size,
      useGlassmorphism: false,
      duration: const Duration(milliseconds: 1200),
    );
  }

  // Static factory method for creating a high-energy version
  static Widget energetic({
    Color? primaryColor,
    Color? secondaryColor,
    double? size,
    Key? key,
  }) {
    return CustomLoadingIndicator(
      key: key,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      size: size,
      duration: const Duration(milliseconds: 800),
    );
  }
}
