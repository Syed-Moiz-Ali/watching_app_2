import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:watching_app_2/core/global/globals.dart';

import '../../../app/splash_screen.dart';

/// A widget that provides app restart functionality.
///
/// This widget maintains state that can be reset to trigger a full application restart,
/// refreshing the widget tree and optionally resetting navigation and state.
class RestartWidget extends StatefulWidget {
  const RestartWidget({
    super.key,
    required this.child,
    this.splashScreen,
    this.onBeforeRestart,
    this.onAfterRestart,
    this.resetProviders = true,
  });

  /// The child widget that will be restarted.
  final Widget child;

  /// Optional custom splash screen to show after restart.
  /// If not provided, defaults to SplashScreen.
  final Widget? splashScreen;

  /// Optional callback that runs before the restart process begins.
  final VoidCallback? onBeforeRestart;

  /// Optional callback that runs after the restart process completes.
  final VoidCallback? onAfterRestart;

  /// Whether to reset provider states during restart.
  final bool resetProviders;

  /// Restarts the application with default settings.
  static void restartApp() {
    _restartApp();
  }

  /// Restarts the application with custom options.
  static void restartAppWithOptions({
    bool resetNavigation = true,
    bool resetProviders = true,
    VoidCallback? onBeforeRestart,
    VoidCallback? onAfterRestart,
  }) {
    _restartApp(
      resetNavigation: resetNavigation,
      resetProviders: resetProviders,
      onBeforeRestart: onBeforeRestart,
      onAfterRestart: onAfterRestart,
    );
  }

  /// Internal restart implementation.
  static void _restartApp({
    bool resetNavigation = true,
    bool resetProviders = true,
    VoidCallback? onBeforeRestart,
    VoidCallback? onAfterRestart,
  }) {
    final state = SMA.restartKey.currentState;
    if (state != null) {
      state.restartApp(
        resetNavigation: resetNavigation,
        resetProviders: resetProviders,
        onBeforeRestart: onBeforeRestart,
        onAfterRestart: onAfterRestart,
      );
    } else {
      log("Error: RestartWidget state not found.", name: "RestartWidget");
      // Fallback restart method
      try {
        if (SMA.navigationKey.currentState != null) {
          SMA.navigationKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
          );
        } else {
          log("Navigation state also not found. Cannot restart app.",
              name: "RestartWidget");
        }
      } catch (e) {
        log("Error in fallback restart: $e", name: "RestartWidget");
      }
    }
  }

  @override
  RestartWidgetState createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();
  bool _isRestarting = false;

  /// Restarts the application with the provided options.
  Future<void> restartApp({
    bool resetNavigation = true,
    bool resetProviders = true,
    VoidCallback? onBeforeRestart,
    VoidCallback? onAfterRestart,
  }) async {
    if (_isRestarting) {
      log("Restart already in progress. Ignoring request.",
          name: "RestartWidget");
      return;
    }

    _isRestarting = true;
    log("Restarting app...", name: "RestartWidget");

    try {
      // Run pre-restart callback if provided
      onBeforeRestart ?? widget.onBeforeRestart?.call();

      // Reset widget tree with new key
      setState(() {
        key = UniqueKey();
        log("Generated new app key: $key", name: "RestartWidget");
      });

      // Reset navigation if requested
      if (resetNavigation && SMA.navigationKey.currentState != null) {
        final splashScreen = widget.splashScreen ?? const SplashScreen();
        SMA.navigationKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => splashScreen),
          (route) => false,
        );
        log("Navigation stack reset", name: "RestartWidget");
      }

      // Reset providers if requested
      if (resetProviders || widget.resetProviders) {
        // Add your provider reset logic here
        log("Provider states reset", name: "RestartWidget");
      }

      // Run post-restart callback if provided
      onAfterRestart ?? widget.onAfterRestart?.call();

      log("App restart completed successfully", name: "RestartWidget");
    } catch (e) {
      log("Error during app restart: $e", name: "RestartWidget");
    } finally {
      _isRestarting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

/// Extension providing restart functionality to BuildContext
extension RestartExtension on BuildContext {
  /// Restarts the app from any BuildContext
  void restartApp() {
    RestartWidget.restartApp();
  }

  /// Restarts the app with custom options from any BuildContext
  void restartAppWithOptions({
    bool resetNavigation = true,
    bool resetProviders = true,
    VoidCallback? onBeforeRestart,
    VoidCallback? onAfterRestart,
  }) {
    RestartWidget.restartAppWithOptions(
      resetNavigation: resetNavigation,
      resetProviders: resetProviders,
      onBeforeRestart: onBeforeRestart,
      onAfterRestart: onAfterRestart,
    );
  }
}
