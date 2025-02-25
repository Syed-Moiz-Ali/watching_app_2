import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedWallpaperScreen extends StatefulWidget {
  @override
  _AnimatedWallpaperScreenState createState() =>
      _AnimatedWallpaperScreenState();
}

class _AnimatedWallpaperScreenState extends State<AnimatedWallpaperScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimController;
  late AnimationController _searchBarAnimController;
  late Animation<double> _searchBarAnimation;
  late AnimationController _particleController;
  late List<ParticleModel> particles;

  @override
  void initState() {
    super.initState();

    // Initialize particles
    particles = List.generate(100, (index) => ParticleModel());

    // Background animation controller with slower animation
    _backgroundAnimController =
        AnimationController(vsync: this, duration: Duration(seconds: 15))
          ..repeat();

    // Search bar animation controller
    _searchBarAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _searchBarAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _searchBarAnimController, curve: Curves.elasticOut));
    _searchBarAnimController.forward();

    // Particle system controller
    _particleController =
        AnimationController(vsync: this, duration: Duration(seconds: 4))
          ..repeat();
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HSLColor.fromAHSL(
                        1, _backgroundAnimController.value * 360, 0.8, 0.4)
                    .toColor(),
                HSLColor.fromAHSL(
                        1,
                        (_backgroundAnimController.value * 360 + 60) % 360,
                        0.9,
                        0.5)
                    .toColor(),
                HSLColor.fromAHSL(
                        1,
                        (_backgroundAnimController.value * 360 + 120) % 360,
                        0.8,
                        0.4)
                    .toColor(),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: WavePainter(animation: _backgroundAnimController),
          ),
        );
      },
    );
  }

  Widget _buildParticleBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(
            particles: particles,
            animation: _particleController,
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchBarAnimController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _searchBarAnimation.value)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                _buildAnimatedSearchIcon(),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search your content...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                _buildAnimatedFilterIcon(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSearchIcon() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.search_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildAnimatedFilterIcon() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.tune_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildParticleBackground(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSearchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add these new classes for enhanced animations

class ParticleModel {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double speed = Random().nextDouble() * 2 + 0.5;
  double radius = Random().nextDouble() * 2 + 1;
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final Animation<double> animation;

  ParticlePainter({required this.particles, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    for (var particle in particles) {
      particle.y = (particle.y + particle.speed * animation.value) % 10.0;
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;

  WavePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    var y = size.height / 20;
    path.moveTo(0, y);

    for (var i = 0; i < size.width; i++) {
      y = size.height / 2 +
          sin((i * 0.01) + animation.value * 2 * pi) * 20 +
          cos((i * 0.02) + animation.value * 2 * pi) * 20;
      path.lineTo(i.toDouble(), y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
