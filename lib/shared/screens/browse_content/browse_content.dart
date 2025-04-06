// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/presentation/provider/search_provider.dart';
import 'package:watching_app_2/shared/screens/browse_content/animated_search_bar.dart';

class BrowseContent extends StatefulWidget {
  const BrowseContent({super.key});

  @override
  _BrowseContentState createState() => _BrowseContentState();
}

class _BrowseContentState extends State<BrowseContent>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimController;
  late AnimationController _searchBarAnimController;
  late AnimationController _contentAnimController;
  late AnimationController _particleController;
  late AnimationController _blobAnimController;
  late List<ParticleModel> particles;

  final ScrollController _scrollController = ScrollController();
  // Add these to your state class
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    particles = generateParticles(100);

    // Initialize content cards

    // Background animation controller with smoother, longer animation
    _backgroundAnimController =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..repeat();

    // Blob animation controller
    _blobAnimController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();

    // Search bar animation controller with improved timing
    _searchBarAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    // Content animation controller for staggered animations
    _contentAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    // Particle system controller with varied speeds
    _particleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    // Start animations with slight delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      _searchBarAnimController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _contentAnimController.forward();
    });
  }

  List<ParticleModel> generateParticles(int count) {
    final Random random = Random();
    final List<ParticleModel> particles = [];

    for (int i = 0; i < count; i++) {
      // Generate a random red shade
      final Color color = HSLColor.fromAHSL(
        1.0,
        0.0, // Fixed hue for red
        0.7 + random.nextDouble() * 0.3, // Random saturation (70% - 100%)
        0.5 + random.nextDouble() * 0.3, // Random lightness (50% - 80%)
      ).toColor();

      particles.add(
        ParticleModel(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: 1.5 + random.nextDouble() * 3.5, // Random size between 1.5-5
          speed: 0.2 + random.nextDouble() * 0.8, // Random speed
          directionX: -1 + random.nextDouble() * 2, // Random direction X
          directionY: -1 + random.nextDouble() * 2, // Random direction Y
          opacity: 0.4 + random.nextDouble() * 0.5, // Semi-transparent
          id: i,
          color: color, // Assign the random red shade
        ),
      );
    }

    return particles;
  }

  @override
  void dispose() {
    _backgroundAnimController.dispose();
    _searchBarAnimController.dispose();
    _contentAnimController.dispose();
    _particleController.dispose();
    _blobAnimController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildParticleBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(
              particles: particles,
              animation: _particleController,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Background layers
          // _buildAnimatedBackground(),
          // _buildDynamicBlobs(),
          // _buildWaves(),
          _buildParticleBackground(),

          // Main content
          Align(
            alignment: Alignment.center,
            // bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: UltraPremiumSearchBar(
                  primaryColor: AppColors.greyColor,
                  backgroundColor: AppColors.transparent,
                  hintText: 'Search for anything...',
                  onSearch: (value, category) {
                    if (value.isNotEmpty) {
                      // NH.navigateTo(GlobalSearchDataList(query: value));
                      context.read<SearchProvider>().setAllCategoryResults({});
                      NH.nameNavigateTo(AppRoutes.searchResult,
                          arguments: {'query': value, 'category': category});
                    }
                  },
                  onCategoryChanged: (value) {},
                  recentSearches: const [
                    'Action',
                    'Flutter',
                    'Dart',
                    'Firebase',
                    'Flutter Animations',
                    'Flutter UI',
                  ],
                  onRecentSearchesUpdated: (list) {
                    if (kDebugMode) {
                      print('onRecentSearchesUpdated: $list');
                    }
                  },
                ),
              ),
            ),
          ),

          // Bottom navigation floating
        ],
      ),
    );
  }
}

// Model classes and painters

class CardItem {
  final String title;
  final IconData icon;
  final int colorIndex;

  CardItem({required this.title, required this.icon, required this.colorIndex});
}

class ParticleModel {
  double x;
  double y;
  double radius;
  double speed;
  double directionX;
  double directionY;
  double opacity;
  int id;
  Color color; // Add color property to each particle

  ParticleModel({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.directionX,
    required this.directionY,
    required this.opacity,
    required this.id,
    required this.color, // Store individual color
  });
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final Animation<double> animation;
  final Random random = Random();

  // Base color is now optional since each particle has its own color
  ParticlePainter({
    required this.particles,
    required this.animation,
  }) : super(repaint: animation);

  // Helper method to generate a random light color
  Color generateRandomLightColor() {
    // Create light colors by using high brightness/lightness values
    return HSLColor.fromAHSL(
      1.0,
      random.nextDouble() * 360, // Random hue (0-360)
      0.7 + random.nextDouble() * 0.3, // High saturation (0.7-1.0)
      0.7 + random.nextDouble() * 0.2, // High lightness (0.7-0.9)
    ).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Use the particle's own color with its opacity
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity);

      // Move particles in random directions with slower speed
      particle.x =
          (particle.x + particle.directionX * particle.speed * 0.005) % 1.0;
      particle.y =
          (particle.y + particle.directionY * particle.speed * 0.005) % 1.0;

      // Wrap around edges
      if (particle.x < 0) particle.x = 1.0;
      if (particle.y < 0) particle.y = 1.0;

      // Add very subtle variation to direction over time for natural movement
      particle.directionX +=
          (sin(animation.value * pi + particle.id * 0.5) * 0.001);
      particle.directionY +=
          (cos(animation.value * pi + particle.id * 0.5) * 0.001);

      // Normalize direction vector to keep consistent speed
      final magnitude = sqrt(particle.directionX * particle.directionX +
          particle.directionY * particle.directionY);
      if (magnitude > 0) {
        particle.directionX /= magnitude;
        particle.directionY /= magnitude;
      }

      // Very subtle size pulsing effect based on animation value
      final pulseFactor =
          1.0 + sin(animation.value * 2 * pi + particle.id) * 0.1;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius * pulseFactor,
        paint,
      );

      // Occasionally change particle color with a small probability for gentle color shifting
      if (random.nextDouble() < 0.001) {
        // 0.1% chance per frame
        particle.color = generateRandomLightColor();
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class BlobPainter extends CustomPainter {
  final Animation<double> animation;

  BlobPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value;

    // Paint for multiple blobs with varying opacity
    List<Color> blobColors = [
      AppColors.primaryColor.withOpacity(0.05),
      AppColors.primaryColor.withOpacity(0.07),
      AppColors.primaryColor.withOpacity(0.04),
    ];

    // Draw multiple blobs with varying positions and sizes
    for (int i = 0; i < blobColors.length; i++) {
      final paint = Paint()
        ..color = blobColors[i]
        ..style = PaintingStyle.fill;

      final offsetX = size.width * 0.2 + (i * size.width * 0.3);
      final offsetY = size.height * (0.3 + i * 0.2);
      final radius = size.width * (0.3 + i * 0.1);

      final path = Path();

      for (double angle = 0; angle < 2 * pi; angle += 0.01) {
        // Create irregular blob shape
        double r = radius *
            (1 +
                0.2 * sin(angle * 3 + time * 2 * pi) +
                0.1 * cos(angle * 7 + time * 2 * pi));
        double x = offsetX + r * cos(angle);
        double y = offsetY + r * sin(angle);

        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;

  WavePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Multiple waves with different parameters
    _drawWave(canvas, size, AppColors.primaryColor.withOpacity(0.08), 3, 30,
        animation.value, 0.01, 0.02);

    _drawWave(canvas, size, AppColors.primaryColor.withOpacity(0.05), 2, 20,
        animation.value + 0.5, 0.015, 0.01);
  }

  void _drawWave(Canvas canvas, Size size, Color color, double strokeWidth,
      double amplitude, double phase, double freqX, double freqY) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    for (var i = 0; i < size.width; i += 1) {
      var y = size.height * 0.5 +
          amplitude * sin((i * freqX) + phase * 2 * pi) +
          amplitude * 0.5 * cos((i * freqY) + phase * 2 * pi);
      path.lineTo(i.toDouble(), y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
