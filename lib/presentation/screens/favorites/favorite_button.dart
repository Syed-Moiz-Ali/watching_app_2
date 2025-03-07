import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/screens/favorites/remove_favorite_dialog.dart';
import 'dart:math' as math;

import '../../provider/favorites_provider.dart';

class FavoriteButton extends StatefulWidget {
  final dynamic item;
  final String contentType;
  final bool isGrid;
  final bool initialFavorite;
  final Color primaryColor;
  final Color secondaryColor;
  final Color errorColor;

  const FavoriteButton({
    super.key,
    required this.item,
    required this.contentType,
    this.isGrid = false,
    this.initialFavorite = false,
    this.primaryColor = const Color(0xFF6200EE),
    this.secondaryColor = Colors.white,
    this.errorColor = const Color(0xFFE53935),
  });

  @override
  State<FavoriteButton> createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _rotationController;
  late AnimationController _colorChangeController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _particleAnimation;

  bool _isFavorite = false;
  bool _isCheckingFavorite = false;
  bool _isProcessing = false;
  bool _isHovered = false;

  final List<ParticleModel> _particles = [];
  final int _particleCount = 12;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialFavorite;

    // Scale animation for hover and tap
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Bounce animation when toggling favorite
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.35), weight: 30),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.1), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 20),
    ]).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutCubic),
    );

    // Rotation animation for toggling
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi / 12).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOutQuad),
    );

    // Color change animation
    _colorChangeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: widget.primaryColor,
      end: widget.errorColor,
    ).animate(_colorChangeController);
    _backgroundColorAnimation = ColorTween(
      begin: widget.secondaryColor.withOpacity(0.9),
      end: widget.secondaryColor.withOpacity(0.95),
    ).animate(_colorChangeController);

    // Particle animation for celebration effect
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOutQuint,
    );

    // Initialize animation states based on initial favorite status
    if (_isFavorite) {
      _colorChangeController.value = 1.0;
    }
    _checkFavoriteStatus();
    // Setup particles
    _setupParticles();
  }

  void _setupParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      final angle = (i / _particleCount) * 2 * math.pi;
      final speed = 0.5 + _random.nextDouble() * 0.8;
      final size = 4.0 + _random.nextDouble() * 4.0;
      final distance = 20.0 + _random.nextDouble() * 20.0;

      _particles.add(ParticleModel(
        angle: angle,
        speed: speed,
        size: size,
        distance: distance,
        color: [
          widget.errorColor,
          widget.primaryColor,
          widget.errorColor.withOpacity(0.8),
          widget.primaryColor.withOpacity(0.8),
        ][_random.nextInt(4)],
      ));
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    _rotationController.dispose();
    _colorChangeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    if (_isCheckingFavorite) return;

    setState(() {
      _isCheckingFavorite = true;
    });

    try {
      final favoritesProvider =
          Provider.of<FavoritesProvider>(context, listen: false);
      final isFavorite =
          await favoritesProvider.isFavorite(widget.item.contentUrl);

      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isCheckingFavorite = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Simulate API call with Provider
      final favoritesProvider =
          Provider.of<FavoritesProvider>(context, listen: false);

      // If currently favorited, show confirmation dialog before removal
      if (_isFavorite) {
        setState(() => _isProcessing = false); // Stop processing indicator

        final bool removed = await favoritesProvider.removeWithConfirmation(
            context, widget.item, widget.contentType);

        if (removed) {
          // Animation handled by dialog, just update state
          setState(() => _isFavorite = false);
          _colorChangeController.reverse();
        }
      } else {
        // Start animations for adding to favorites
        _colorChangeController.forward();
        // _rotationController.forward(from: 0.0);
        _bounceController.forward(from: 0.0);
        _particleController.forward(from: 0.0);

        // Optimistic update
        setState(() => _isFavorite = true);

        // Perform the actual API call
        await favoritesProvider.toggleFavorite(widget.item, widget.contentType);

        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isProcessing = false;

          // Reverse color animation if needed
          if (_isFavorite) {
            _colorChangeController.forward();
          } else {
            _colorChangeController.reverse();
          }
        });

        _showErrorSnackbar(e.toString());
      }
    }
  }

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating favorites: $errorMessage'),
        backgroundColor: widget.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.isGrid ? 12 : 16,
      bottom: widget.isGrid ? 12 : 16,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _scaleController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _scaleController.reverse();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _bounceAnimation,
            _rotationAnimation,
            _colorAnimation,
            _particleAnimation
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value *
                  (_bounceController.isAnimating
                      ? _bounceAnimation.value
                      : 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Particle effects
                  if (_particleController.isAnimating && _isFavorite)
                    ...buildParticles(),

                  // Main button
                  Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: EdgeInsets.all(widget.isGrid ? 10 : 14),
                        decoration: BoxDecoration(
                          color: _isFavorite
                              ? _backgroundColorAnimation.value
                              : widget.secondaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(120),
                          boxShadow: [
                            BoxShadow(
                              color: _isFavorite
                                  ? widget.primaryColor.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: _isHovered ? 3 : 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isProcessing
                            ? SizedBox(
                                width: widget.isGrid ? 18 : 24,
                                height: widget.isGrid ? 20 : 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _isFavorite
                                        ? widget.secondaryColor
                                        : widget.primaryColor,
                                  ),
                                ),
                              )
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey<bool>(_isFavorite),
                                  color: _isFavorite
                                      ? _colorAnimation.value
                                      : widget.primaryColor,
                                  size: widget.isGrid ? 20 : 24,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> buildParticles() {
    return _particles.map((particle) {
      final progress = _particleAnimation.value;
      final dx = math.cos(particle.angle) * particle.distance * progress;
      final dy = math.sin(particle.angle) * particle.distance * progress;
      final opacity = (1 - progress) * 0.8;

      return Positioned(
        left: (widget.isGrid ? 20 : 24) + dx,
        top: (widget.isGrid ? 20 : 24) + dy,
        child: Transform.scale(
          scale: progress < 0.5 ? progress * 2 : 1 - ((progress - 0.5) * 2),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: particle.color,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// Model class for particles
class ParticleModel {
  final double angle;
  final double speed;
  final double size;
  final double distance;
  final Color color;

  ParticleModel({
    required this.angle,
    required this.speed,
    required this.size,
    required this.distance,
    required this.color,
  });
}
