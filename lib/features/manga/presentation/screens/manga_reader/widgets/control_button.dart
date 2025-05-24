import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/constants/manga_reader_constants.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isActive;
  final Color? color;
  final Color? activeColor;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
    this.color,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryColor.withOpacity(0.3)
                : AppColors.backgroundColorDark,
            boxShadow: MangaReaderConstants.boxShadow,
          ),
          child: Icon(
            icon,
            color: isActive
                ? activeColor ?? AppColors.primaryColor
                : color ?? Colors.white,
            size: 24,
          ),
        ),
      ),
    ).animate().scale(
        duration: MangaReaderConstants.animationDuration,
        curve: Curves.bounceOut);
  }
}
