import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/global/app_global.dart';
import 'package:watching_app_2/models/content_source.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../models/content_item.dart';
import '../../widgets/custom_image_widget.dart';

class UltraPremiumWallpaperDetail extends StatefulWidget {
  final ContentItem item;

  const UltraPremiumWallpaperDetail({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  _UltraPremiumWallpaperDetailState createState() =>
      _UltraPremiumWallpaperDetailState();
}

class _UltraPremiumWallpaperDetailState
    extends State<UltraPremiumWallpaperDetail> with TickerProviderStateMixin {
  // Controllers for various animations
  late AnimationController _backgroundController;
  late AnimationController _interfaceController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundScaleAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _rippleAnimation;

  // State variables
  bool _isDownloading = false;
  bool _isSettingWallpaper = false;
  bool _interfaceVisible = true;
  double _dragPosition = 0.0;

  // Gesture values for 3D tilt effect
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.05),
        weight: 1,
      ),
    ]).animate(_backgroundController);

    _backgroundOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.93, end: 1.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.93),
        weight: 1,
      ),
    ]).animate(_backgroundController);

    // UI Interface animation
    _interfaceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize fully visible UI
    _interfaceController.value = 1.0;

    // Pulse animation for buttons
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
    ]).animate(_pulseController);

    // Blur animation for backdrop filter
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _interfaceController,
        curve: Curves.easeOut,
      ),
    );

    // Ripple effect for button press
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    // Add status listeners for the ripple effect
    _rippleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rippleController.reset();
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _interfaceController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _toggleInterface() {
    setState(() {
      _interfaceVisible = !_interfaceVisible;

      if (_interfaceVisible) {
        _interfaceController.forward();
      } else {
        _interfaceController.reverse();
      }
    });
  }

  void _updateTiltEffect(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate tilt percentage based on pointer position
    setState(() {
      _tiltX = (details.globalPosition.dx / screenWidth * 2 - 1) * 5;
      _tiltY = (details.globalPosition.dy / screenHeight * 2 - 1) * 5;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  void _downloadWallpaper() {
    // Start ripple animation for tactile feedback
    _rippleController.forward();

    setState(() {
      _isDownloading = true;
    });

    // Simulate download with success animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        _showSuccessAnimation('Downloaded');
      }
    });
  }

  void _setWallpaper() {
    // Start ripple animation for tactile feedback
    _rippleController.forward();

    setState(() {
      _isSettingWallpaper = true;
    });

    // Simulate setting wallpaper
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isSettingWallpaper = false;
        });
        _showApplyOptions();
      }
    });
  }

  void _startDrag(DragStartDetails details) {
    setState(() {
      _dragPosition = details.globalPosition.dy;
    });
  }

  void _updateDrag(DragUpdateDetails details) {
    final delta = _dragPosition - details.globalPosition.dy;

    // If dragging up significantly, show the apply options
    if (delta > 50) {
      _dragPosition = details.globalPosition.dy;
      _showApplyOptions();
    }
  }

  void _showSuccessAnimation(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success animated check mark
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4CAF50),
                                  Color(0xFF8BC34A),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ).then((_) {
      // Close dialog after a delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.of(context).maybePop();
        }
      });
    });
  }

  void _showApplyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 200 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.95),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    'Set Wallpaper As',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildApplyOption(
                      context,
                      Icons.home_outlined,
                      'Home Screen',
                      0,
                    ),
                    _buildApplyOption(
                      context,
                      Icons.lock_outlined,
                      'Lock Screen',
                      1,
                    ),
                    _buildApplyOption(
                      context,
                      Icons.smartphone_outlined,
                      'Both',
                      2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyOption(
      BuildContext context, IconData icon, String label, int delayFactor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      // Add staggered delay based on position
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _showSuccessAnimation('Applied to $label');
        },
        child: Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[100]!,
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3C8CE7),
                      Color(0xFF00EAFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3C8CE7).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: GestureDetector(
          onTap: _toggleInterface,
          onPanStart: _startDrag,
          onPanUpdate: (details) {
            _updateTiltEffect(details);
            _updateDrag(details);
          },
          onPanEnd: (_) => _resetTilt(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Animated wallpaper background with 3D tilt effect
              Hero(
                tag: 'wallpaper-${widget.item.thumbnailUrl}',
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateX(_tiltY * 0.01)
                              ..rotateY(-_tiltX * 0.01)
                              ..scale(_backgroundScaleAnimation.value),
                            child: Opacity(
                                opacity: _backgroundOpacityAnimation.value,
                                child: CustomImageWidget(
                                  imagePath: SMA.formatImage(
                                      image: widget.item.thumbnailUrl,
                                      baseUrl: widget.item.source.url),
                                  fit: BoxFit.contain,
                                )
                                // Container(
                                //   decoration: BoxDecoration(
                                //     image: DecorationImage(
                                //       image: NetworkImage(widget.imageUrl),
                                //       fit: BoxFit.cover,
                                //     ),
                                //   ),
                                // ),
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Gorgeous dynamic light effects overlay
              AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.transparent,
                            Colors.blue.withOpacity(0.3),
                          ],
                          stops: [
                            0.0,
                            0.5,
                            1.0,
                          ],
                          transform: GradientRotation(
                            _backgroundController.value * 2 * math.pi,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Interface elements
              AnimatedBuilder(
                animation: _interfaceController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _interfaceController.value,
                    child: Stack(
                      children: [
                        // Top app bar
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            leading: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: _blurAnimation.value,
                                sigmaY: _blurAnimation.value,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      size: 18),
                                  color: Colors.white,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            title: Text(
                              widget.item.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Elegant bottom action area with glassmorphism
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 100 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Download button
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Ripple effect animation
                                          AnimatedBuilder(
                                            animation: _rippleAnimation,
                                            builder: (context, child) {
                                              return Opacity(
                                                opacity:
                                                    1 - _rippleAnimation.value,
                                                child: Transform.scale(
                                                  scale: 1 +
                                                      _rippleAnimation.value *
                                                          0.5,
                                                  child: Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          // Download button
                                          GestureDetector(
                                            onTap: _isDownloading
                                                ? null
                                                : _downloadWallpaper,
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: _isDownloading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.download_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Apply wallpaper button
                                      AnimatedBuilder(
                                        animation: _pulseAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _pulseAnimation.value,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Ripple effect animation
                                                AnimatedBuilder(
                                                  animation: _rippleAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: 1 -
                                                          _rippleAnimation
                                                              .value,
                                                      child: Transform.scale(
                                                        scale: 1 +
                                                            _rippleAnimation
                                                                    .value *
                                                                0.3,
                                                        child: Container(
                                                          width: 200,
                                                          height: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                const Color(
                                                                        0xFF3C8CE7)
                                                                    .withOpacity(
                                                                        0.5),
                                                                const Color(
                                                                        0xFF00EAFF)
                                                                    .withOpacity(
                                                                        0.5),
                                                              ],
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),

                                                // Apply button
                                                GestureDetector(
                                                  onTap: _isSettingWallpaper
                                                      ? null
                                                      : _setWallpaper,
                                                  child: Container(
                                                    width: 200,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color(0xFF3C8CE7),
                                                          Color(0xFF00EAFF),
                                                        ],
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(
                                                                  0xFF3C8CE7)
                                                              .withOpacity(0.5),
                                                          blurRadius: 15,
                                                          spreadRadius: 0,
                                                          offset: const Offset(
                                                              0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: _isSettingWallpaper
                                                        ? const Center(
                                                            child: SizedBox(
                                                              width: 24,
                                                              height: 24,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                strokeWidth: 2,
                                                              ),
                                                            ),
                                                          )
                                                        : const Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.wallpaper,
                                                                color: Colors
                                                                    .white,
                                                                size: 24,
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Apply Wallpaper',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Hint text for swiping up
                        Positioned(
                          bottom: 110,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value * 0.7,
                                  child: child,
                                );
                              },
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Swipe up to apply',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
