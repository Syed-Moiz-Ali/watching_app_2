import 'package:flutter/material.dart';
import 'package:watching_app_2/core/global/app_global.dart';

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
}
