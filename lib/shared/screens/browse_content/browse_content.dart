// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math';

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
  // Simplified animation controllers
  late AnimationController _particleController;
  late AnimationController _floatController;

  // Simplified animations
  late Animation<double> _particleFlow;
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
  }

  void _initializeAnimations() {
    // Simplified particle system with slower, more ambient movement
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Floating elements animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particleFlow = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );

    _floatOffset = CurvedAnimation(
      parent: _floatController,
      curve: Curves.linear,
    );
  }

  void _initializeParticles() {
    particles = _generateEnhancedParticles(40); // Reduced for minimalism
    floatingElements = _generateFloatingElements(6); // Reduced for cleaner look
  }

  List<EnhancedParticle> _generateEnhancedParticles(int count) {
    final Random random = Random();
    final List<EnhancedParticle> particles = [];

    for (int i = 0; i < count; i++) {
      final Color color = _generateHarmonizedColor(random);

      particles.add(
        EnhancedParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: 1.0 + random.nextDouble() * 1.5, // Smaller particles
          speed: 0.05 + random.nextDouble() * 0.15, // Slower movement
          directionX: -0.3 + random.nextDouble() * 0.6,
          directionY: -0.3 + random.nextDouble() * 0.6,
          opacity: 0.15 + random.nextDouble() * 0.25, // More subtle
          id: i,
          color: color,
          pulsePhase: random.nextDouble() * 2 * pi,
          trailLength: 2 + random.nextInt(3), // Shorter trails
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
          size: 30.0 + random.nextDouble() * 50.0, // Slightly larger
          speed: 0.01 + random.nextDouble() * 0.02, // Slower drift
          opacity: 0.05 + random.nextDouble() * 0.08, // Very subtle
          rotationSpeed: 0.005 + random.nextDouble() * 0.01,
          color: AppColors.primaryColor
              .withOpacity(0.03 + random.nextDouble() * 0.05),
        ),
      );
    }

    return elements;
  }

  Color _generateHarmonizedColor(Random random) {
    final baseHue = HSLColor.fromColor(AppColors.primaryColor).hue;
    final hueVariation = baseHue + (-20 + random.nextDouble() * 40);

    return HSLColor.fromAHSL(
      0.25 + random.nextDouble() * 0.15, // Lower alpha for subtlety
      hueVariation % 360,
      0.5 + random.nextDouble() * 0.2,
      0.65 + random.nextDouble() * 0.25,
    ).toColor();
  }

  @override
  void dispose() {
    _particleController.dispose();
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
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      extendBody: true,
      body: Stack(
        children: [
          // Simplified background
          _buildMinimalistBackground(theme, isDark),

          // Main content
          _buildMainContent(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMinimalistBackground(ThemeData theme, bool isDark) {
    return Stack(
      children: [
        // Clean gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF0A0A0A),
                      const Color(0xFF1A1A1A),
                    ]
                  : [
                      const Color(0xFFFAFAFA),
                      const Color(0xFFF5F5F7),
                    ],
            ),
          ),
        ),

        // Subtle particle system
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

        // Minimal floating elements
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

        // Subtle ambient glow
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(isDark ? 0.08 : 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(ThemeData theme, bool isDark) {
    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Hero icon with minimal animation
                  _buildHeroIcon(theme, isDark)
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 32),

                  // Main title
                  _buildTitle(theme, isDark)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuart),

                  const SizedBox(height: 12),

                  // Subtitle with helper text
                  _buildSubtitle(theme, isDark)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuart),

                  const SizedBox(height: 48),

                  // Premium search bar
                  _buildPremiumSearchBar(theme, isDark)
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuart),

                  const Spacer(),



                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon(ThemeData theme, bool isDark) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? AppColors.primaryColor.withOpacity(0.12)
            : AppColors.primaryColor.withOpacity(0.08),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.search_rounded,
        size: 44,
        color: AppColors.primaryColor.withOpacity(0.9),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, bool isDark) {
    return TextWidget(
      text: 'Discover Content',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      letterSpacing: -0.5,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(ThemeData theme, bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: TextWidget(
        text:
            'Search through our vast collection of videos, movies, series, and more',
        fontSize: 15,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w400,
        maxLine: 3,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPremiumSearchBar(ThemeData theme, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: UltraPremiumSearchBar(
        primaryColor: AppColors.primaryColor,
        backgroundColor: Colors.transparent,
        hintText: 'Search for movies, series, anime...',
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

  Widget _buildQuickActions(ThemeData theme, bool isDark) {
    final categories = [
      {'icon': Icons.local_movies_rounded, 'label': 'Movies'},
      {'icon': Icons.tv_rounded, 'label': 'TV Series'},
      {'icon': Icons.live_tv_rounded, 'label': 'Anime'},
      {'icon': Icons.sports_esports_rounded, 'label': 'Gaming'},
    ];

    return Column(
      children: [
        TextWidget(
          text: 'Popular Categories',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
          letterSpacing: 0.5,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            return _buildCategoryChip(
              theme,
              isDark,
              category['icon'] as IconData,
              category['label'] as String,
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 900 + (index * 100)))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
      ThemeData theme, bool isDark, IconData icon, String label) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _searchController.text = label;
        // widget.onSearch?.call(label, 'All');
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            TextWidget(
              text: label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Model Classes (unchanged)

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

// Enhanced Custom Painters (simplified for better performance)

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
    // Slower, more ambient movement
    particle.x =
        (particle.x + particle.directionX * particle.speed * 0.002) % 1.0;
    particle.y =
        (particle.y + particle.directionY * particle.speed * 0.002) % 1.0;

    if (particle.x < 0) particle.x = 1.0;
    if (particle.y < 0) particle.y = 1.0;

    // Minimal direction variation
    particle.directionX +=
        sin(animation.value * 2 * pi + particle.id * 0.1) * 0.0003;
    particle.directionY +=
        cos(animation.value * 2 * pi + particle.id * 0.1) * 0.0003;

    final magnitude = sqrt(particle.directionX * particle.directionX +
        particle.directionY * particle.directionY);
    if (magnitude > 0) {
      particle.directionX /= magnitude;
      particle.directionY /= magnitude;
    }

    // Simplified trail
    final currentPos =
        Offset(particle.x * size.width, particle.y * size.height);
    particle.trail.insert(0, currentPos);
    if (particle.trail.length > particle.trailLength) {
      particle.trail.removeLast();
    }
  }

  void _drawParticle(Canvas canvas, EnhancedParticle particle, Size size) {
    // Draw subtle trail
    for (int i = 1; i < particle.trail.length; i++) {
      final trailOpacity =
          particle.opacity * (1.0 - (i / particle.trail.length)) * 0.4;
      final trailPaint = Paint()
        ..color = particle.color.withOpacity(trailOpacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.trail[i],
        particle.radius * (1.0 - (i / particle.trail.length)) * 0.6,
        trailPaint,
      );
    }

    // Draw main particle with subtle pulse
    final pulseFactor =
        1.0 + sin(animation.value * 2 * pi + particle.pulsePhase) * 0.1;
    final mainPaint = Paint()
      ..color = particle.color.withOpacity(particle.opacity)
      ..style = PaintingStyle.fill;

    final position = Offset(particle.x * size.width, particle.y * size.height);
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
    // Very slow upward drift
    element.y = (element.y - element.speed * 0.5) % 1.0;
    if (element.y < 0) element.y = 1.0;

    // Minimal horizontal sway
    element.x += sin(animation.value * 2 * pi * 0.05) * 0.00005;
    element.x = element.x.clamp(0.0, 1.0);

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

    // Draw simple circle instead of hexagon for minimalism
    canvas.drawCircle(Offset.zero, element.size * 0.5, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(FloatingElementsPainter oldDelegate) => true;
}
