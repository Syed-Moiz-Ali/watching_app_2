import 'package:flutter/material.dart';
import 'package:watching_app_2/core/global/globals.dart';

class NH {
  // Reusable method for the slide transition animation
  static Widget _buildSlideTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const begin = Offset(1.0, 0.0); // Start the animation from the right
    const end = Offset.zero; // End at the center
    const curve = Curves.easeInOut; // Apply a smooth curve

    var tween = Tween<Offset>(begin: begin, end: end);
    var offsetAnimation =
        animation.drive(tween.chain(CurveTween(curve: curve)));

    return SlideTransition(position: offsetAnimation, child: child);
  }

  // Navigate to a new page with a slide transition
  static Future<void> navigateTo(Widget page) {
    return Navigator.push<void>(
      SMA.navigationKey.currentContext!,
      PageRouteBuilder<void>(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return page;
        },
        transitionsBuilder: _buildSlideTransition,
        transitionDuration:
            const Duration(milliseconds: 600), // Increase duration here
      ),
    );
  }

  // Navigate back to the previous page
  static void navigateBack() {
    Navigator.pop(SMA.navigationKey.currentContext!);
  }

  // Force navigate to a new page, replacing the current page
  static Future<void> forceNavigate(Widget page) {
    return Navigator.pushReplacement<void, void>(
      SMA.navigationKey.currentContext!,
      PageRouteBuilder<void>(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return page;
        },
        transitionsBuilder: _buildSlideTransition,
        transitionDuration:
            const Duration(milliseconds: 600), // Increase duration here
      ),
    );
  }

  static Future<void> nameNavigateTo(String routeName,
      {Map<String, dynamic>? arguments}) {
    return Navigator.pushNamed(
      SMA.navigationKey.currentContext!,
      routeName,
      arguments: arguments,
    );
  }

  /// **Navigate and replace the current screen using named routes**
  static Future<void> nameForceNavigate(String routeName,
      {Map<String, dynamic>? arguments}) {
    return Navigator.pushReplacementNamed(
      SMA.navigationKey.currentContext!,
      routeName,
      arguments: arguments,
    );
  }

  /// **Navigate and remove all previous routes**
  static Future<void> nameNavigateAndRemoveUntil(String routeName,
      {Map<String, dynamic>? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      SMA.navigationKey.currentContext!,
      routeName,
      (route) => false, // Removes all previous routes
      arguments: arguments,
    );
  }

  /// **Navigate back to the previous screen**
  static void nameNavigateBack() {
    if (Navigator.canPop(SMA.navigationKey.currentContext!)) {
      Navigator.pop(SMA.navigationKey.currentContext!);
    }
  }

  /// **Navigate back until a specific route is found**
  static void nameNavigateBackUntil(String routeName) {
    Navigator.popUntil(
        SMA.navigationKey.currentContext!, ModalRoute.withName(routeName));
  }
}
