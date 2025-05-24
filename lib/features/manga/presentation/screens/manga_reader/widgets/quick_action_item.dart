import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/constants/manga_reader_constants.dart';

import '../../../../../../core/constants/colors.dart';

class QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLightTheme;

  const QuickActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isLightTheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MangaReaderConstants.borderRadius),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLightTheme
              ? Colors.grey[100]
              : AppColors.backgroundColorDark.withOpacity(0.5),
          borderRadius:
              BorderRadius.circular(MangaReaderConstants.borderRadius),
          boxShadow: MangaReaderConstants.boxShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isLightTheme ? Colors.black87 : Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: MangaReaderConstants.subtitleStyle.copyWith(
                  color: isLightTheme ? Colors.black87 : Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: MangaReaderConstants.fadeDuration).scale(
        curve: Curves.easeOutBack,
        duration: MangaReaderConstants.animationDuration);
  }
}
