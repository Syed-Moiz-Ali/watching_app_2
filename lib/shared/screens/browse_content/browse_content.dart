// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/presentation/provider/search_provider.dart';
import 'package:watching_app_2/shared/screens/browse_content/animated_search_bar.dart';

import '../../widgets/misc/text_widget.dart';

class BrowseContent extends StatefulWidget {
  const BrowseContent({super.key});

  @override
  _BrowseContentState createState() => _BrowseContentState();
}

class _BrowseContentState extends State<BrowseContent>
    with TickerProviderStateMixin {
  // Enhanced Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _searchBarController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _breatheController;
  late AnimationController _floatController;

  // Enhanced Animations
  late Animation<double> _searchBarFade;
  late Animation<double> _searchBarSlide;
  late Animation<double> _particleFlow;
  late Animation<double> _glowPulse;
  late Animation<double> _breatheScale;
  late Animation<double> _floatOffset;

  late List<EnhancedParticle> particles;
  late List<FloatingElement> floatingElements;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Main background animation with extended duration for smoothness
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    // Search bar entrance animation
    _searchBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Particle system controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Breathing animation for ambient effects
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    // Floating elements animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Create smooth animations with premium easing
    _searchBarFade = CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.easeOutQuart,
    );

    _searchBarSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _searchBarController,
        curve: Curves.easeOutBack,
      ),
    );

    _particleFlow = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );

    _glowPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _breatheScale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOut,
      ),
    );

    _floatOffset = CurvedAnimation(
      parent: _floatController,
      curve: Curves.linear,
    );
  }

  void _initializeParticles() {
    particles =
        _generateEnhancedParticles(80); // Reduced count for better performance
    floatingElements = _generateFloatingElements(12);
  }

  void _startAnimationSequence() {
    // Staggered animation entrance
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _searchBarController.forward();
    });
  }

  List<EnhancedParticle> _generateEnhancedParticles(int count) {
    final Random random = Random();
    final List<EnhancedParticle> particles = [];

    for (int i = 0; i < count; i++) {
      // Enhanced color palette with better visual harmony
      final Color color = _generateHarmonizedColor(random);

      particles.add(
        EnhancedParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: 1.0 + random.nextDouble() * 2.5,
          speed: 0.1 + random.nextDouble() * 0.4,
          directionX: -0.5 + random.nextDouble(),
          directionY: -0.5 + random.nextDouble(),
          opacity: 0.3 + random.nextDouble() * 0.4,
          id: i,
          color: color,
          pulsePhase: random.nextDouble() * 2 * pi,
          trailLength: 3 + random.nextInt(5),
          trail: [],
        ),
      );
    }

    return particles;
  }

  List<FloatingElement> _generateFloatingElements(int count) {
    final Random random = Random();
    final List<FloatingElement> elements = [];

    for (int i = 0; i < count; i++) {
      elements.add(
        FloatingElement(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 20.0 + random.nextDouble() * 40.0,
          speed: 0.02 + random.nextDouble() * 0.05,
          opacity: 0.1 + random.nextDouble() * 0.2,
          rotationSpeed: 0.01 + random.nextDouble() * 0.02,
          color: AppColors.primaryColor
              .withOpacity(0.05 + random.nextDouble() * 0.1),
        ),
      );
    }

    return elements;
  }

  Color _generateHarmonizedColor(Random random) {
    // Create a harmonized color palette based on primary color
    final baseHue = HSLColor.fromColor(AppColors.primaryColor).hue;
    final hueVariation = baseHue + (-30 + random.nextDouble() * 60);

    return HSLColor.fromAHSL(
      0.4 + random.nextDouble() * 0.4, // Alpha
      hueVariation % 360, // Hue with variation
      0.6 + random.nextDouble() * 0.3, // Saturation
      0.6 + random.nextDouble() * 0.3, // Lightness
    ).toColor();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchBarController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _breatheController.dispose();
    _floatController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFBFBFB),
      extendBody: true,
      body: Stack(
        children: [
          // Enhanced layered background system
          _buildEnhancedBackground(theme, isDark),

          // Main content with improved positioning
          _buildMainContent(theme, isDark),

          // Optional floating action elements
          _buildFloatingElements(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildEnhancedBackground(ThemeData theme, bool isDark) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0A0A0A),
                      const Color(0xFF1A1A1A).withOpacity(0.8),
                      AppColors.primaryColor.withOpacity(0.05),
                    ]
                  : [
                      const Color(0xFFFBFBFB),
                      const Color(0xFFF5F5F5).withOpacity(0.9),
                      AppColors.primaryColor.withOpacity(0.03),
                    ],
            ),
          ),
        ),

        // Enhanced particle system
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: EnhancedParticlePainter(
                particles: particles,
                animation: _particleFlow,
                isDark: isDark,
              ),
            );
          },
        ),

        // Floating geometric elements
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: FloatingElementsPainter(
                elements: floatingElements,
                animation: _floatOffset,
                isDark: isDark,
              ),
            );
          },
        ),

        // Ambient glow effects
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppColors.primaryColor.withOpacity(0.02 * _glowPulse.value),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMainContent(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheScale.value,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: AnimatedBuilder(
                animation: _searchBarController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _searchBarSlide.value),
                    child: Opacity(
                      opacity: _searchBarFade.value,
                      child: _buildEnhancedSearchSection(theme, isDark),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSearchSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced welcome section
          _buildWelcomeSection(theme, isDark),

          const SizedBox(height: 10),

          // Premium search bar
          _buildPremiumSearchBar(theme, isDark),

          // const SizedBox(height: 30),

          // // Search suggestions or recent searches
          // _buildSearchSuggestions(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // App logo or icon with glow effect
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.2 * _glowPulse.value),
                    AppColors.primaryColor.withOpacity(0.05 * _glowPulse.value),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 60,
                color: AppColors.primaryColor.withOpacity(0.8),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Welcome text
        TextWidget(
          text: 'Discover Amazing Content',
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: theme.textTheme.bodyLarge?.color,
          letterSpacing: -0.5,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        TextWidget(
          text: 'Search through millions of videos, images, and more',
          fontSize: 16,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          maxLine: 2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPremiumSearchBar(ThemeData theme, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: UltraPremiumSearchBar(
        primaryColor: AppColors.primaryColor,
        backgroundColor: Colors.transparent,
        hintText: 'Search for anything...',
        onSearch: (value, category) {
          if (value.isNotEmpty) {
            HapticFeedback.lightImpact();
            context.read<SearchProvider>().setAllCategoryResults({});
            NH.nameNavigateTo(
              AppRoutes.searchResult,
              arguments: {'query': value, 'category': category},
            );
          }
        },
        onCategoryChanged: (value) {
          HapticFeedback.lightImpact();
        },
        recentSearches: const [
          'Action Movies',
          'Anime Series',
          'Documentary',
          'Comedy',
          'Sci-Fi',
          'Adventure',
        ],
        onRecentSearchesUpdated: (list) {
          if (kDebugMode) {
            print('Recent searches updated: $list');
          }
        },
      ),
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme, bool isDark) {
    final suggestions = [
      {
        'title': 'Popular Movies',
        'icon': Icons.movie_rounded,
        'color': Colors.red
      },
      {
        'title': 'Trending Anime',
        'icon': Icons.animation_rounded,
        'color': Colors.blue
      },
      {
        'title': 'New Releases',
        'icon': Icons.fiber_new_rounded,
        'color': Colors.green
      },
      {'title': 'Top Rated', 'icon': Icons.star_rounded, 'color': Colors.amber},
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: suggestions.map((suggestion) {
          final color = suggestion['color'] as Color;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  suggestion['icon'] as IconData,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                TextWidget(
                  text: suggestion['title'] as String,
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingElements(ThemeData theme, bool isDark) {
    // Optional floating UI elements for enhanced visual appeal
    return const SizedBox.shrink(); // Implement if needed
  }
}

// Enhanced Model Classes

class EnhancedParticle {
  double x;
  double y;
  double radius;
  double speed;
  double directionX;
  double directionY;
  double opacity;
  int id;
  Color color;
  double pulsePhase;
  int trailLength;
  List<Offset> trail;

  EnhancedParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.directionX,
    required this.directionY,
    required this.opacity,
    required this.id,
    required this.color,
    required this.pulsePhase,
    required this.trailLength,
    required this.trail,
  });
}

class FloatingElement {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double rotationSpeed;
  Color color;
  double rotation = 0.0;

  FloatingElement({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.rotationSpeed,
    required this.color,
  });
}

// Enhanced Custom Painters

class EnhancedParticlePainter extends CustomPainter {
  final List<EnhancedParticle> particles;
  final Animation<double> animation;
  final bool isDark;

  EnhancedParticlePainter({
    required this.particles,
    required this.animation,
    required this.isDark,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      _updateParticle(particle, size);
      _drawParticle(canvas, particle, size);
    }
  }

  void _updateParticle(EnhancedParticle particle, Size size) {
    // Smooth movement with fluid motion
    particle.x =
        (particle.x + particle.directionX * particle.speed * 0.003) % 1.0;
    particle.y =
        (particle.y + particle.directionY * particle.speed * 0.003) % 1.0;

    // Handle edge wrapping
    if (particle.x < 0) particle.x = 1.0;
    if (particle.y < 0) particle.y = 1.0;

    // Add subtle direction variation for organic movement
    particle.directionX +=
        sin(animation.value * 2 * pi + particle.id * 0.1) * 0.0005;
    particle.directionY +=
        cos(animation.value * 2 * pi + particle.id * 0.1) * 0.0005;

    // Normalize direction to maintain consistent speed
    final magnitude = sqrt(particle.directionX * particle.directionX +
        particle.directionY * particle.directionY);
    if (magnitude > 0) {
      particle.directionX /= magnitude;
      particle.directionY /= magnitude;
    }

    // Update trail
    final currentPos =
        Offset(particle.x * size.width, particle.y * size.height);
    particle.trail.insert(0, currentPos);
    if (particle.trail.length > particle.trailLength) {
      particle.trail.removeLast();
    }
  }

  void _drawParticle(Canvas canvas, EnhancedParticle particle, Size size) {
    // Draw trail with fading opacity
    for (int i = 0; i < particle.trail.length; i++) {
      final trailOpacity =
          particle.opacity * (1.0 - (i / particle.trail.length));
      final trailPaint = Paint()
        ..color = particle.color.withOpacity(trailOpacity * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.trail[i],
        particle.radius * (1.0 - (i / particle.trail.length)) * 0.5,
        trailPaint,
      );
    }

    // Draw main particle with pulsing effect
    final pulseFactor =
        1.0 + sin(animation.value * 2 * pi + particle.pulsePhase) * 0.15;
    final mainPaint = Paint()
      ..color = particle.color.withOpacity(particle.opacity)
      ..style = PaintingStyle.fill;

    // Add subtle glow effect
    final glowPaint = Paint()
      ..color = particle.color.withOpacity(particle.opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final position = Offset(particle.x * size.width, particle.y * size.height);

    // Draw glow
    canvas.drawCircle(position, particle.radius * pulseFactor * 1.5, glowPaint);

    // Draw main particle
    canvas.drawCircle(position, particle.radius * pulseFactor, mainPaint);
  }

  @override
  bool shouldRepaint(EnhancedParticlePainter oldDelegate) => true;
}

class FloatingElementsPainter extends CustomPainter {
  final List<FloatingElement> elements;
  final Animation<double> animation;
  final bool isDark;

  FloatingElementsPainter({
    required this.elements,
    required this.animation,
    required this.isDark,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var element in elements) {
      _updateElement(element, size);
      _drawElement(canvas, element, size);
    }
  }

  void _updateElement(FloatingElement element, Size size) {
    // Slow upward drift
    element.y = (element.y - element.speed) % 1.0;
    if (element.y < 0) element.y = 1.0;

    // Gentle horizontal sway
    element.x += sin(animation.value * 2 * pi * 0.1) * 0.0001;
    element.x = element.x.clamp(0.0, 1.0);

    // Update rotation
    element.rotation += element.rotationSpeed;
  }

  void _drawElement(Canvas canvas, FloatingElement element, Size size) {
    final paint = Paint()
      ..color = element.color
      ..style = PaintingStyle.fill;

    final position = Offset(element.x * size.width, element.y * size.height);

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(element.rotation);

    // Draw hexagon shape
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi * 2) / 6;
      final x = cos(angle) * element.size * 0.5;
      final y = sin(angle) * element.size * 0.5;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(FloatingElementsPainter oldDelegate) => true;
}
