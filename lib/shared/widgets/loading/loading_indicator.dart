import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../misc/text_widget.dart';

class CustomLoadingIndicator extends StatefulWidget {
  final String loadingText;
  const CustomLoadingIndicator({super.key, this.loadingText = 'loading....'});

  @override
  State<CustomLoadingIndicator> createState() =>
      _PaginationLoadingIndicatorState();
}

class _PaginationLoadingIndicatorState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  // Multiple animation controllers for complex effects
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _colorController;
  late AnimationController _particleController;
  late AnimationController _waveController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _particleAnimation;

  // Particle system variables
  final List<Particle> _particles = [];
  final int _particleCount = 8;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Main rotation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Pulse effect controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    // Color transition controller with smoother easing
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
            begin: const Color(0xFF6200EE), end: const Color(0xFF9C27B0)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ColorTween(
            begin: const Color(0xFF9C27B0), end: const Color(0xFF03DAC5)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ColorTween(
            begin: const Color(0xFF03DAC5), end: const Color(0xFF009688)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ColorTween(
            begin: const Color(0xFF009688), end: const Color(0xFF6200EE)),
        weight: 25,
      ),
    ]).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );

    // Particle system animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Initialize particles
    _initializeParticles();

    // Wave animation for text
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  void _initializeParticles() {
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle(
        angle: 2 * math.pi * i / _particleCount,
        speed: 0.2 + _random.nextDouble() * 0.3,
        size: 2 + _random.nextDouble() * 3,
        opacity: 0.3 + _random.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _colorController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stacked effect for depth
          Stack(
            alignment: Alignment.center,
            children: [
              // Background glow effect
              AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_colorAnimation.value ?? Colors.purple)
                              .withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Particle system
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(90, 90),
                    painter: ParticlePainter(
                      particles: _particles,
                      progress: _particleAnimation.value,
                      baseColor: _colorAnimation.value ?? Colors.purple,
                    ),
                  );
                },
              ),

              // Main spinner with enhanced effects
              AnimatedBuilder(
                animation: Listenable.merge(
                    [_rotationController, _pulseController, _colorController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: CustomPaint(
                          painter: EnhancedLoadingPainter(
                            primaryColor:
                                _colorAnimation.value ?? Colors.purple,
                            secondaryColor: Color.lerp(
                                  _colorAnimation.value ?? Colors.purple,
                                  Colors.white,
                                  0.3,
                                ) ??
                                Colors.purpleAccent,
                            strokeWidth: 4.0,
                            progress: _rotationController.value,
                            secondaryProgress: _rotationController.value * 0.75,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Central icon/dot with pulse
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.5,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: (_colorAnimation.value ?? Colors.purple)
                                .withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Animated wave text
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildWaveText(widget.loadingText),
              );
            },
          ),
        ],
      ),
    );
  }

  // Creates a list of animated characters for wave text effect
  List<Widget> _buildWaveText(String text) {
    final List<Widget> result = [];

    for (int i = 0; i < text.length; i++) {
      final double phase = i / text.length;
      final Animation<double> waveAnim = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _waveController,
          curve: Interval(
            phase,
            phase + 0.6,
            curve: Curves.easeInOut,
          ),
        ),
      );

      result.add(
        AnimatedBuilder(
          animation: waveAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0,
                  math.sin(_waveController.value * 2 * math.pi + i * 0.5) * 3),
              child: Opacity(
                opacity: 0.6 +
                    0.4 *
                        math.sin(
                            (_waveController.value * 2 * math.pi + i * 0.5) %
                                math.pi),
                child: TextWidget(
                  text: text[i],
                  fontSize: 14.sp,
                  fontWeight: i % 3 == 0 ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            );
          },
        ),
      );
    }

    return result;
  }
}

// Particle class for the particle system
class Particle {
  final double angle;
  final double speed;
  final double size;
  final double opacity;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

// Particle system painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color baseColor;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (final particle in particles) {
      // Calculate position based on angle, speed and progress
      final radius =
          maxRadius * 0.3 + maxRadius * 0.7 * progress * particle.speed;
      final position = Offset(
        center.dx + radius * math.cos(particle.angle + progress * 2),
        center.dy + radius * math.sin(particle.angle + progress * 2),
      );

      // Draw the particle
      final paint = Paint()
        ..color = baseColor.withOpacity(particle.opacity * (1.0 - progress))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          position, particle.size * (1.0 - progress * 0.7), paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor;
  }
}

// Enhanced painter with dual arcs and more visual details
class EnhancedLoadingPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;
  final double progress;
  final double secondaryProgress;

  EnhancedLoadingPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
    required this.progress,
    required this.secondaryProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Draw background ring
    final backgroundPaint = Paint()
      ..color = primaryColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.6;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw secondary arc in opposite direction
    final secondaryArcPaint = Paint()
      ..color = secondaryColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round;

    const secondaryStartAngle = math.pi / 2;
    final secondaryEndAngle = 2 * math.pi * (0.3 + 0.6 * secondaryProgress);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      secondaryStartAngle,
      -secondaryEndAngle, // Negative for opposite direction
      false,
      secondaryArcPaint,
    );

    // Draw main arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        primaryColor.withOpacity(0.7),
        primaryColor,
        Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor,
        primaryColor.withOpacity(0.7),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      transform: GradientRotation(progress * 2 * math.pi),
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const mainStartAngle = -math.pi / 2;
    final mainSweepAngle = 2 * math.pi * (0.25 + 0.5 * progress);

    canvas.drawArc(
      rect,
      mainStartAngle,
      mainSweepAngle,
      false,
      arcPaint,
    );

    // Draw enhanced dots at ends of the arc
    final dotRadius = strokeWidth * 0.9;

    // Starting point dot
    final startPoint = Offset(
      center.dx + radius * math.cos(mainStartAngle),
      center.dy + radius * math.sin(mainStartAngle),
    );

    // Ending point dot (moves with the progress)
    final endPoint = Offset(
      center.dx + radius * math.cos(mainStartAngle + mainSweepAngle),
      center.dy + radius * math.sin(mainStartAngle + mainSweepAngle),
    );

    // Draw with glow effect
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Draw dots with glow
    canvas.drawCircle(startPoint, dotRadius * 1.5, glowPaint);
    canvas.drawCircle(startPoint, dotRadius, dotPaint);

    canvas.drawCircle(endPoint, dotRadius * 1.5, glowPaint);
    canvas.drawCircle(endPoint, dotRadius, dotPaint);

    // Draw subtle tick marks around the circle
    final tickPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.3;

    for (int i = 0; i < 12; i++) {
      final tickAngle = i * (2 * math.pi / 12);
      final outerPoint = Offset(
        center.dx + (radius + strokeWidth) * math.cos(tickAngle),
        center.dy + (radius + strokeWidth) * math.sin(tickAngle),
      );
      final innerPoint = Offset(
        center.dx + (radius - strokeWidth) * math.cos(tickAngle),
        center.dy + (radius - strokeWidth) * math.sin(tickAngle),
      );

      // Make the ticks fade in and out based on their position relative to the progress
      final distFromProgress =
          (tickAngle - (mainStartAngle + mainSweepAngle)).abs() % (2 * math.pi);
      final opacity = math.max(0.1, 1.0 - distFromProgress / (math.pi / 2));

      tickPaint.color = primaryColor.withOpacity(opacity * 0.3);
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(EnhancedLoadingPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progress != progress ||
        oldDelegate.secondaryProgress != secondaryProgress;
  }
}
