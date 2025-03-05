import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/presentation/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';
import 'dart:ui';

import '../../../data/models/content_item.dart';
import '../../provider/favorites_provider.dart';

// Extension of the FavoritesProvider to include the enhanced removal method with confirmation
extension FavoritesProviderExtension on FavoritesProvider {
  Future<bool> removeWithConfirmation(
      BuildContext context, ContentItem item, String contentType) async {
    final bool shouldRemove = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          builder: (BuildContext context) => PremiumConfirmationDialog(
            item: item,
            contentType: contentType,
          ),
        ) ??
        false;

    if (shouldRemove) {
      await removeFromFavorites(item, contentType);
      return true;
    }
    return false;
  }
}

class PremiumConfirmationDialog extends StatefulWidget {
  final ContentItem item;
  final String contentType;

  const PremiumConfirmationDialog({
    super.key,
    required this.item,
    required this.contentType,
  });

  @override
  State<PremiumConfirmationDialog> createState() =>
      _PremiumConfirmationDialogState();
}

class _PremiumConfirmationDialogState extends State<PremiumConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _iconAnimationSize;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    );

    _blurAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _iconAnimationSize = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );

    // Play entrance animation
    _animationController.forward();

    // Add haptic feedback on dialog open
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _confirmRemoval() async {
    // Reverse animation before closing dialog
    HapticFeedback.mediumImpact();
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _cancelRemoval() async {
    // Reverse animation before closing dialog
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryColor = theme.colorScheme.primary;
    final Color errorColor = theme.colorScheme.error;

    // Derive colors based on theme
    final Color cardColor = isDarkMode
        ? Color.lerp(theme.cardColor, Colors.black, 0.3)!
        : Color.lerp(theme.cardColor, Colors.white, 0.5)!;
    final Color shadowColor = primaryColor.withOpacity(0.2);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _blurAnimation.value,
            sigmaY: _blurAnimation.value,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 30,
                        spreadRadius: 1,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with heart breaking animation
                      Transform.scale(
                        scale: _iconAnimationSize.value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: errorColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.heart_broken_rounded,
                            color: errorColor,
                            size: 40,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryColor, errorColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: TextWidget(
                          text: 'Remove from Favorites?',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Content description
                      TextWidget(
                        text:
                            'Are you sure you want to remove "${widget.item.title}" from your favorites?',
                        maxLine: 4,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Buttons row
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: PrimaryButton(
                              onTap: _cancelRemoval,
                              bgColor: AppColors.greyColor.withOpacity(.2),
                              borderRadius: 2.5.w,
                              elevation: 0,
                              child: const TextWidget(text: 'Cancel'),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Remove button
                          Expanded(
                            child: PrimaryButton(
                              onTap: _confirmRemoval,
                              bgColor: AppColors.errorColor,
                              borderRadius: 2.5.w,
                              elevation: 0,
                              child: const TextWidget(
                                text: 'Remove',
                                color: AppColors.backgroundColorLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Updated toggleFavorite method for the PremiumFavoriteButton
