// ignore_for_file: library_private_types_in_public_api, only_throw_errors

import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watching_app_2/core/constants/colors.dart';

import '../widgets/misc/text_widget.dart';

class UpdateScreen extends StatefulWidget {
  final String updateUrl;
  const UpdateScreen({super.key, required this.updateUrl});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>
    with TickerProviderStateMixin {
  double _progress = 0;
  String _filePath = '';
  bool _isDownloading = false;
  final Dio _dio = Dio();

  // Animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _downloadAnimationController;
  late AnimationController _successAnimationController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _contentSlideAnimation;
  late Animation<Offset> _downloadButtonSlideAnimation;
  late Animation<double> _downloadButtonScaleAnimation;

  // Particles animation
  List<Particle> _particles = [];
  late AnimationController _particleController;

  // Gesture animation for glass card effect
  double _cardRotationX = 0;
  double _cardRotationY = 0;

  // Colors - Luxurious color scheme
  final Color _bgDarkColor = AppColors.disabledColor;
  final Color _bgLightColor = const Color(0xFF1E1E1E);
  final Color _accentColor = AppColors.primaryColor; // Luxurious gold
  final Color _accentSecondaryColor =
      AppColors.primaryColor.withOpacity(.8); // Deeper gold
  final Color _textWhiteColor = const Color(0xFFF5F5F5);
  final Color _textGreyColor = const Color(0xFFAAAAAA);
  final Color _glassBgColor = const Color(0x24FFFFFF);

  @override
  void initState() {
    super.initState();
    _initializeDownload();
    _setupAnimations();
    _generateParticles();
  }

  void _setupAnimations() {
    // Main entrance animation
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Background animation
    _backgroundAnimation = CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    // Card animation with dramatic entrance
    _cardAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.7),
      ),
    );

    // Content animations
    _contentFadeAnimation = CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _contentSlideAnimation = Tween<double>(
      begin: 40.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutQuint),
      ),
    );

    // Download button animations
    _downloadButtonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );

    _downloadButtonScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 100,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.7, 1.0),
      ),
    );

    // Subtle pulse animation
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Download specific animation
    _downloadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Success animation
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Start the entrance animation
    _mainAnimationController.forward();
  }

  void _generateParticles() {
    final random = math.Random();
    _particles = List.generate(40, (index) {
      return Particle(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * 800,
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 3 + 1,
        angle: random.nextDouble() * math.pi * 2,
        color: _accentColor.withOpacity(random.nextDouble() * 0.5 + 0.1),
      );
    });
  }

  Future<void> _initializeDownload() async {
    Directory? newDir = await getExternalStorageDirectory();
    if (newDir != null) {
      setState(() {
        _filePath = '${newDir.path}/stream.apk';
      });
    }
  }

  Future<void> _startDownload() async {
    if (_progress == 100) {
      _openFile();
    } else {
      if (_isDownloading) return;

      setState(() {
        _isDownloading = true;
      });

      // Animation for download start
      _downloadAnimationController.forward();

      try {
        await _dio.download(
          widget.updateUrl,
          _filePath,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'en-US,en;q=0.9',
              'Cache-Control': 'no-cache',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                _progress = (received / total) * 100;
              });
            }
          },
        );
        setState(() {
          _progress = 100;
        });

        // Play success animation
        _successAnimationController.forward();

        _openFile();
      } catch (e) {
        setState(() {
          _isDownloading = false;
        });
        _showSnackbar('Download failed. Please try again.');

        // Reset download animation
        _downloadAnimationController.reverse();
      }
    }
  }

  Future<void> _openFile() async {
    var status = await Permission.requestInstallPackages.status;
    if (status.isDenied) {
      await Permission.requestInstallPackages.request();
      status = await Permission.requestInstallPackages.status;
    }

    if (status.isGranted) {
      try {
        final result = await OpenFile.open(_filePath);
        log(result.message, name: 'OpenFile');
        log(result.type.toString(), name: 'OpenFileType');
      } catch (e) {
        _showSnackbar('An error occurred while trying to open the file.');
        log(e.toString(), name: 'OpenFileError');
      }
    } else {
      _showSnackbar('Permission to install packages is required to proceed.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                border: Border.all(
                  color: _accentColor.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextWidget(
                      text: message,
                      color: _textWhiteColor,
                      maxLine: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: 20,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _launchURL() async {
    var url = Uri.parse('https://pornstreamapp.pages.dev/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _updateCardRotation(DragUpdateDetails details) {
    final Size screenSize = MediaQuery.of(context).size;
    // Calculate rotation based on pointer position
    setState(() {
      _cardRotationX = (details.localPosition.dy - 150) / 500;
      _cardRotationY = -(details.localPosition.dx - screenSize.width / 2) / 500;
    });
  }

  void _resetCardRotation() {
    setState(() {
      _cardRotationX = 0;
      _cardRotationY = 0;
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseAnimationController.dispose();
    _downloadAnimationController.dispose();
    _successAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated Background
          // AnimatedBuilder(
          //   animation: _backgroundAnimation,
          //   builder: (context, child) {
          //     return Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //           colors: [
          //             _bgDarkColor,
          //             _bgLightColor,
          //           ],
          //           stops: const [0.3, 0.9],
          //         ),
          //       ),
          //     );
          //   },
          // ),

          // Particles Effect
          // AnimatedBuilder(
          //   animation: _particleController,
          //   builder: (context, child) {
          //     return CustomPaint(
          //       painter: ParticlesPainter(
          //         particles: _particles,
          //         progress: _particleController.value,
          //       ),
          //       size: Size(screenSize.width, screenSize.height),
          //     );
          //   },
          // ),

          // Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Name Animation
                  AnimatedBuilder(
                      animation: _mainAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _backgroundAnimation.value,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 30 * _backgroundAnimation.value),
                            child: TextWidget(
                              text: "BrowseX",
                              color: _accentColor,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),

                  // Main Card with Glass Effect
                  AnimatedBuilder(
                    animation: _mainAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardAnimation.value,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // Perspective
                            ..rotateX(_cardRotationX)
                            ..rotateY(_cardRotationY),
                          alignment: FractionalOffset.center,
                          child: GestureDetector(
                            onPanUpdate: _updateCardRotation,
                            onPanEnd: (_) => _resetCardRotation(),
                            child: Container(
                              width: screenSize.width * 0.85,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: _glassBgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _accentColor.withOpacity(0.2),
                                  width: 1,
                                ),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black.withOpacity(0.2),
                                //     blurRadius: 30,
                                //     spreadRadius: 0,
                                //     offset: const Offset(0, 15),
                                //   ),
                                // ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Opacity(
                                    opacity: _contentFadeAnimation.value,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Icon or Logo
                                        _buildUpdateIcon(),

                                        const SizedBox(height: 30),

                                        // Title with animation
                                        Transform.translate(
                                          offset: Offset(
                                              0, _contentSlideAnimation.value),
                                          child: _buildUpdateText(),
                                        ),

                                        const SizedBox(height: 16),

                                        // Description with animation
                                        Transform.translate(
                                          offset: Offset(
                                              0,
                                              _contentSlideAnimation.value *
                                                  1.2),
                                          child: _buildUpdateDescription(),
                                        ),

                                        const SizedBox(height: 25),

                                        // Progress indicator or Update button
                                        if (_progress > 0 && _progress < 100)
                                          _buildProgressIndicator()
                                        else
                                          _buildUpdateButton(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Secondary action (Visit Website)
                  AnimatedBuilder(
                    animation: _mainAnimationController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _downloadButtonSlideAnimation,
                        child: ScaleTransition(
                          scale: _downloadButtonScaleAnimation,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: _buildWebsiteButton(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        // Calculate subtle pulse effect
        double scale = 1.0 + (_pulseAnimationController.value * 0.05);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentColor.withOpacity(0.3),
                    _accentColor.withOpacity(0.0),
                  ],
                  radius: 0.7,
                ),
              ),
            ),

            // Inner container with subtle animation
            Transform.scale(
              scale: scale,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _textWhiteColor.withOpacity(0.2),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: _progress == 100
                      ? _buildSuccessCheckmark()
                      : Icon(
                          Icons.arrow_downward_rounded,
                          color: _accentColor,
                          size: 38,
                        ),
                ),
              ),
            ),

            // Dynamic Rotation Ring
            Transform.rotate(
              angle: _pulseAnimationController.value * 2 * math.pi,
              child: _buildRotatingRing(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRotatingRing() {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
      ),
      child: CustomPaint(
        painter: DashedRingPainter(
          color: _accentColor,
          dashWidth: 5,
          dashGap: 5,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildSuccessCheckmark() {
    return AnimatedBuilder(
      animation: _successAnimationController,
      builder: (context, child) {
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _accentColor,
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.check,
            color: _textWhiteColor,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildUpdateText() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            _accentColor,
            _accentSecondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: TextWidget(
        text: 'Update Available',
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUpdateDescription() {
    return TextWidget(
      text:
          'An update is available. Please update the app to continue. This will help us improve the app with new features and bug fixes.',
      maxLine: 10,
      fontSize: 15.sp,
      color: _textGreyColor,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUpdateButton() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        // Subtle pulse effect for the button
        double scale = 1.0 + (_pulseAnimationController.value * 0.03);

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  _accentColor,
                  _accentSecondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _startDownload,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon
                      AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _pulseAnimationController.value * 0.1,
                            child: Icon(
                              _progress >= 100
                                  ? Icons.check_circle_outline
                                  : Icons.download_rounded,
                              color: _textWhiteColor,
                              size: 20,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      TextWidget(
                        text: _progress >= 100 ? "Install" : 'Update Now',
                        fontWeight: FontWeight.w600,
                        color: _textWhiteColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress visualization
        Stack(
          alignment: Alignment.center,
          children: [
            // Animated circular progress
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: GlowingProgressPainter(
                  progress: _progress / 100,
                  progressColor: _accentColor,
                  glowColor: _accentColor.withOpacity(0.5),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  strokeWidth: 6,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWidget(
                          text: '${_progress.toStringAsFixed(0)}%',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: _accentColor,
                        ),
                        const SizedBox(height: 4),
                        TextWidget(
                          text: 'Downloading',
                          fontSize: 14.sp,
                          color: _textGreyColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebsiteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launchURL,
        borderRadius: BorderRadius.circular(20),
        splashColor: _accentColor.withOpacity(0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: _textGreyColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              TextWidget(
                text: 'Visit Our Website',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: _textGreyColor,
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _textGreyColor.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particle class
class Particle {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  });
}

// Custom Particles Painter
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update position based on progress
      double x = (particle.x + progress * particle.speed * 50) % size.width;
      double y = (particle.y + progress * particle.speed * 20) % size.height;

      // Draw particle
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Dashed Ring Painter
class DashedRingPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  DashedRingPainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Calculate dash count based on circumference
    final double circumference = 2 * math.pi * radius;
    final int dashCount = (circumference / (dashWidth + dashGap)).floor();
    final double eachAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = i * eachAngle;
      final double endAngle =
          startAngle + (eachAngle * dashWidth / (dashWidth + dashGap));

      canvas.drawArc(rect, startAngle, endAngle - startAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GlowingProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color glowColor;
  final Color backgroundColor;
  final double strokeWidth;

  GlowingProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.glowColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double radius = math.min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Background track
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Glow effect
    final Paint glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );

    // Progress arc
    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GlowingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
