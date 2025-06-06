import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';

class PaginationLoadingIndicator extends StatefulWidget {
  final String? loadingText;
  final double size;
  final bool horizontal;

  const PaginationLoadingIndicator({
    super.key,
    this.loadingText,
    this.size = 30.0, // Much smaller default size
    this.horizontal = true, // Horizontal layout by default for compactness
  });

  @override
  State<PaginationLoadingIndicator> createState() =>
      _CompactLoadingIndicatorState();
}

class _CompactLoadingIndicatorState extends State<PaginationLoadingIndicator>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _colorController;
  late AnimationController _textController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Main rotation controller - faster for more dynamic feel
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Subtle pulse effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    // Color transition controller
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
            begin: const Color(0xFF6200EE), end: const Color(0xFF03DAC5)),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: ColorTween(
            begin: const Color(0xFF03DAC5), end: const Color(0xFF009688)),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: ColorTween(
            begin: const Color(0xFF009688), end: const Color(0xFF6200EE)),
        weight: 34,
      ),
    ]).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _colorController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = AnimatedBuilder(
      animation: Listenable.merge(
          [_rotationController, _pulseController, _colorController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            height: widget.size.sp,
            width: widget.size.sp,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle glow effect
                Container(
                  width: widget.size * 0.9,
                  height: widget.size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_colorAnimation.value ?? Colors.purple)
                            .withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),

                // Main spinner
                Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: CompactLoadingPainter(
                      primaryColor: _colorAnimation.value ?? Colors.purple,
                      secondaryColor: Color.lerp(
                            _colorAnimation.value ?? Colors.purple,
                            Colors.white,
                            0.3,
                          ) ??
                          Colors.purpleAccent,
                      strokeWidth: widget.size * 0.1,
                      progress: _rotationController.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Optional text with subtle animation
    Widget? textWidget;
    if (widget.loadingText != null && widget.loadingText!.isNotEmpty) {
      textWidget = AnimatedBuilder(
        animation: _textController,
        builder: (context, child) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontal ? 8.0 : 0,
              vertical: widget.horizontal ? 0 : 4.0,
            ),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6) ??
                        Colors.grey.shade600,
                    Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.grey.shade800,
                    Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6) ??
                        Colors.grey.shade600,
                  ],
                  stops: [0.0, (_textController.value + 0.5) % 1.0, 1.0],
                ).createShader(bounds);
              },
              child: TextWidget(
                text: widget.loadingText!,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          );
        },
      );
    }

    // Return either horizontal or vertical layout based on configuration
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: widget.horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                mainContent,
                if (textWidget != null) textWidget,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                mainContent,
                if (textWidget != null) textWidget,
              ],
            ),
    );
  }
}

// Compact and efficient loading indicator painter
class CompactLoadingPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;
  final double progress;

  CompactLoadingPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Draw subtle background ring
    final backgroundPaint = Paint()
      ..color = primaryColor.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.6;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw main arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        primaryColor.withOpacity(0.8),
        primaryColor,
        secondaryColor,
        primaryColor.withOpacity(0.8),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
      transform: GradientRotation(progress * 2 * math.pi),
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (0.25 + 0.5 * progress);

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw subtle dot at the end of arc
    final endPoint = Offset(
      center.dx + radius * math.cos(startAngle + sweepAngle),
      center.dy + radius * math.sin(startAngle + sweepAngle),
    );

    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(endPoint, strokeWidth * 0.6, dotPaint);
  }

  @override
  bool shouldRepaint(CompactLoadingPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progress != progress;
  }
}

// // Example usage modifier for list pagination
// class PaginationFooter extends StatelessWidget {
//   final bool isLoading;
//   final String loadingText;

//   const PaginationFooter({
//     super.key,
//     required this.isLoading,
//     this.loadingText = "Loading more",
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (!isLoading) return const SizedBox.shrink();

//     return Container(
//       height: 40, // Very compact height
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       alignment: Alignment.center,
//       child: PaginationLoadingIndicator(
//         loadingText: loadingText,
//         size: 20, // Even smaller for pagination footer
//       ),
//     );
//   }
// }
