import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watching_app_2/app/splash_screen.dart';
import 'package:watching_app_2/features/tiktok/presentation/screens/tiktok_screen.dart';
import 'package:watching_app_2/shared/screens/local_auth_screen.dart';
import 'package:watching_app_2/shared/screens/update_screen.dart';

import '../../app/age_verification.dart';
import '../../features/videos/presentation/screens/content_detail.dart';
import '../../shared/screens/favorites/favorites.dart';
import '../../shared/screens/navigation_screen.dart';
import '../../shared/screens/search_results_list/search_results_list.dart';
import '../../shared/screens/share_screen.dart';
import '../../shared/screens/sources/sources.dart';
import '../../shared/screens/video_player/video_player.dart';
import '../../features/videos/presentation/screens/videos.dart';
import '../../features/wallpapers/presentation/screens/wallpaper_detail.dart';
import '../../features/wallpapers/presentation/screens/wallpapers.dart';
import '../../shared/widgets/misc/text_widget.dart';
import '../../shared/widgets/network/network_banner.dart';
import '../global/globals.dart';

enum TransitionType {
  fadeIn,
  slideRight,
  slideUp,
  scale,
  rotation,
  custom,
  // New animations
  slideDown,
  slideLeft,
  flipHorizontal,
  flipVertical,
  zoom3D,
  bounceIn,
  skew,
  perspective,
  ripple,
  elastic,
}

class AppRoutes {
  // Random number generator for selecting transitions
  static final Random _random = Random();

  // Store the app-wide transition - initialize with a default value
  static TransitionType _appWideTransition = TransitionType.slideRight;

  // Flag to track if we've initialized the random transition
  static bool _initialized = false;

  // Initialize with a random transition when app starts
  static void initializeRandomTransition() {
    const allTypes = TransitionType.values;
    _appWideTransition = allTypes[_random.nextInt(allTypes.length)];
    _initialized = true;
    if (kDebugMode) {
      print('Selected app-wide transition: $_appWideTransition');
    }
  }

  static const String splash = '/';
  static const String home = '/home';
  static const String auth = '/auth';
  static const String age = '/age';
  static const String update = '/update';
  static const String bottomNavigation = '/bottom-navigation';
  static const String categories = '/categories';
  static const String detail = '/detail';
  static const String video = '/video';
  static const String favorites = '/favorites';
  static const String searchResult = '/search-result';
  static const String settings = '/settings';
  static const String share = '/share';
  static const String sourceList = '/source-list';
  static const String videoList = '/video-list';
  static const String wallpapers = '/wallpapers';
  static const String tiktok = '/tiktok';
  static const String wallpaperDetail = '/wallpaper-detail';

  // Special routes that should override the random selection
  static final Map<String, TransitionType> _fixedTransitionPreferences = {
    detail: TransitionType.custom, // Always use custom for detail views
    video: TransitionType.zoom3D, // Video should have 3D zoom effect
    wallpaperDetail:
        TransitionType.perspective, // Special perspective for wallpapers
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Initialize random transition if not already done
    if (!_initialized) {
      initializeRandomTransition();
    }

    final args = settings.arguments as Map<String, dynamic>? ?? {};

    // Use fixed transitions for certain routes, or the app-wide random transition otherwise
    final transitionType =
        _fixedTransitionPreferences[settings.name] ?? _appWideTransition;

    switch (settings.name) {
      case splash:
        return _createRoute(const SplashScreen(), settings, transitionType);
      case home:
        return _createRoute(const NavigationScreen(), settings, transitionType);
      case auth:
        return _createRoute(const LocalAuthScreen(), settings, transitionType);
      case age:
        return _createRoute(
            const AgeVerificationScreen(), settings, transitionType);
      case update:
        final String updateUrl = args['updateUrl'] ?? '';
        return _createRoute(
            UpdateScreen(
              updateUrl: updateUrl,
            ),
            settings,
            transitionType);

      case detail:
        if (args.containsKey('item')) {
          return _createRoute(
              ContentDetail(item: args['item']), settings, transitionType);
        }
        return _errorRoute(settings.name);

      case wallpapers:
        if (args.containsKey('source')) {
          return _createRoute(
              Wallpapers(source: args['source']), settings, transitionType);
        }
        return _errorRoute(settings.name);

      case wallpaperDetail:
        if (args.containsKey('item')) {
          return _createRoute(MinimalistWallpaperDetail(item: args['item']),
              settings, transitionType);
        }
        return _errorRoute(settings.name);
      case tiktok:
        if (args.containsKey('source')) {
          return _createRoute(
              TikTok(source: args['source']), settings, transitionType);
        }
        return _errorRoute(settings.name);
      case video:
        if (args.containsKey('item')) {
          return _createRoute(
              VideoPlayer(item: args['item']), settings, transitionType);
        }
        return _errorRoute(settings.name);

      case searchResult:
        if (args.containsKey('query')) {
          return _createRoute(
              SearchResultsList(
                query: args['query'],
                category: args['category'],
              ),
              settings,
              transitionType);
        }
        return _errorRoute(settings.name);

      case favorites:
        return _createRoute(const Favorites(), settings, transitionType);

      case share:
        return _createRoute(const DeepLinkHandler(), settings, transitionType);

      case sourceList:
        return _createRoute(const Sources(), settings, transitionType);

      case videoList:
        if (args.containsKey('source')) {
          return _createRoute(
              Videos(source: args['source']), settings, transitionType);
        }
        return _errorRoute(settings.name);

      default:
        return _errorRoute(settings.name);
    }
  }

  /// Enhanced route creation with many transition options
  static PageRouteBuilder<dynamic> _createRoute(
      Widget page, RouteSettings settings, TransitionType type) {
    void onNetworkConnected() {
      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 8),
              Text('Network connection restored!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    void onNetworkDisconnected() {
      ScaffoldMessenger.of(SMA.navigationKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text('Network connection lost!'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }

    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: [
          page,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NetworkBanner(
              showQualityInfo: true,
              autoHide: false,
              onConnected: onNetworkConnected,
              onDisconnected: onNetworkDisconnected,
            ),
          ), // Network banner on every screen
        ],
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Primary animation with enhanced curves
        final primaryAnimation = CurvedAnimation(
          parent: animation,
          curve: _getCurveForTransition(type),
        );

        // Secondary animation for coordinated effects
        final secondaryCurvedAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        );

        switch (type) {
          case TransitionType.fadeIn:
            return FadeTransition(
              opacity:
                  Tween<double>(begin: 0.0, end: 1.0).animate(primaryAnimation),
              child: child,
            );

          case TransitionType.slideRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(primaryAnimation),
              child: child,
            );

          case TransitionType.slideLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(primaryAnimation),
              child: child,
            );

          case TransitionType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(primaryAnimation),
              child: child,
            );

          case TransitionType.slideDown:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(primaryAnimation),
              child: child,
            );

          case TransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(primaryAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1.0)
                    .animate(primaryAnimation),
                child: child,
              ),
            );

          case TransitionType.rotation:
            return RotationTransition(
              turns: Tween<double>(
                begin: 0.05,
                end: 0.0,
              ).animate(primaryAnimation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0)
                    .animate(primaryAnimation),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(primaryAnimation),
                  child: child,
                ),
              ),
            );

          case TransitionType.flipHorizontal:
            return AnimatedBuilder(
              animation: primaryAnimation,
              child: child,
              builder: (context, child) {
                final value = primaryAnimation.value;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateY(pi * (1 - value)),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
            );

          case TransitionType.flipVertical:
            return AnimatedBuilder(
              animation: primaryAnimation,
              child: child,
              builder: (context, child) {
                final value = primaryAnimation.value;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateX(pi * (1 - value)),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
            );

          case TransitionType.zoom3D:
            // Dramatic 3D zoom effect with perspective
            return AnimatedBuilder(
              animation: primaryAnimation,
              child: child,
              builder: (context, child) {
                final value = primaryAnimation.value;
                final depth = 0.8 + (0.2 * value);

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective element
                    ..setEntry(0, 0, depth) // Scale x
                    ..setEntry(1, 1, depth) // Scale y
                    ..setEntry(2, 2, depth) // Scale z
                    ..rotateX(0.1 * (1 - value))
                    ..rotateY(0.1 * (1 - value))
                    ..translate(0.0, 0.0, 200 * (1 - value)),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
            );

          case TransitionType.bounceIn:
            // Bouncy, energetic entrance
            final bounceAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            );

            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.6,
                end: 1.0,
              ).animate(bounceAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(primaryAnimation),
                child: child,
              ),
            );

          case TransitionType.skew:
            // Skew transformation with rotation
            return AnimatedBuilder(
              animation: primaryAnimation,
              child: child,
              builder: (context, child) {
                final value = primaryAnimation.value;
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(0, 1, 0.5 * (1 - value)), // Skew X
                    alignment: Alignment.center,
                    child: child,
                  ),
                );
              },
            );

          case TransitionType.perspective:
            // 3D perspective tilt effect
            return AnimatedBuilder(
              animation: primaryAnimation,
              child: child,
              builder: (context, child) {
                final value = primaryAnimation.value;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateX(0.3 * (1 - value))
                    ..rotateY(0.2 * (1 - value))
                    ..rotateZ(0.1 * (1 - value)),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
            );

          case TransitionType.ripple:
            // Ripple effect that expands from center
            return AnimatedBuilder(
              animation: primaryAnimation,
              child: child,
              builder: (context, child) {
                final value = primaryAnimation.value;
                return ClipPath(
                  clipper: CircleClipper(value * 1.5),
                  child: child,
                );
              },
            );

          case TransitionType.elastic:
            // Elastic, spring-like motion
            final elasticAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.elasticInOut,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(elasticAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(primaryAnimation),
                child: child,
              ),
            );

          case TransitionType.custom:
            // Special detail page transition - hero-like zoom effect combined with slide
            return Stack(
              children: [
                // Fade out the old page
                FadeTransition(
                  opacity: Tween<double>(
                    begin: 1.0,
                    end: 0.0,
                  ).animate(secondaryCurvedAnimation),
                  child: Container(color: Colors.transparent),
                ),
                // Zoom in and slide new content
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0.0),
                    end: Offset.zero,
                  ).animate(primaryAnimation),
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.85,
                      end: 1.0,
                    ).animate(primaryAnimation),
                    child: FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(primaryAnimation),
                      child: child,
                    ),
                  ),
                ),
              ],
            );
        }
      },
      // Adjust transition duration based on transition type
      transitionDuration: _getTransitionDuration(type),
      reverseTransitionDuration: _getReverseTransitionDuration(type),
    );
  }

  /// Get appropriate curve for the transition type
  static Curve _getCurveForTransition(TransitionType type) {
    switch (type) {
      case TransitionType.bounceIn:
        return Curves.elasticOut;
      case TransitionType.elastic:
        return Curves.elasticInOut;
      case TransitionType.zoom3D:
        return Curves.easeOutExpo;
      case TransitionType.perspective:
        return Curves.easeOutQuad;
      case TransitionType.flipHorizontal:
      case TransitionType.flipVertical:
        return Curves.easeOutBack;
      case TransitionType.ripple:
        return Curves.fastOutSlowIn;
      default:
        return Curves.easeOutCubic;
    }
  }

  /// Get appropriate transition duration based on transition type
  static Duration _getTransitionDuration(TransitionType type) {
    switch (type) {
      case TransitionType.fadeIn:
        return const Duration(milliseconds: 400);
      case TransitionType.bounceIn:
      case TransitionType.elastic:
        return const Duration(milliseconds: 900);
      case TransitionType.custom:
        return const Duration(milliseconds: 700);
      case TransitionType.rotation:
        return const Duration(milliseconds: 650);
      case TransitionType.zoom3D:
      case TransitionType.perspective:
        return const Duration(milliseconds: 750);
      case TransitionType.flipHorizontal:
      case TransitionType.flipVertical:
        return const Duration(milliseconds: 800);
      default:
        return const Duration(milliseconds: 500);
    }
  }

  /// Get appropriate reverse transition duration
  static Duration _getReverseTransitionDuration(TransitionType type) {
    switch (type) {
      case TransitionType.custom:
        return const Duration(milliseconds: 550);
      case TransitionType.bounceIn:
      case TransitionType.elastic:
        return const Duration(milliseconds: 700);
      case TransitionType.zoom3D:
      case TransitionType.perspective:
        return const Duration(milliseconds: 600);
      default:
        return const Duration(milliseconds: 400);
    }
  }

  /// **Error Route for Invalid Navigation**
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: TextWidget(
              text: 'Route "$routeName" not found or missing parameters.'),
        ),
      ),
    );
  }
}

/// Custom clipper for ripple effect
class CircleClipper extends CustomClipper<Path> {
  final double progress;

  CircleClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * progress;

    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) =>
      progress != oldClipper.progress;
}
