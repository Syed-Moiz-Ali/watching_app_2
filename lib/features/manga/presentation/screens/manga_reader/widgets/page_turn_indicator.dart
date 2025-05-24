import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/constants/manga_reader_constants.dart';

import '../../../../../../core/constants/colors.dart';

class PageTurnIndicator extends StatelessWidget {
  final bool isRightToLeft;
  final PageController pageController;

  const PageTurnIndicator(
      {super.key, required this.isRightToLeft, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIndicator(
          onTap: () => pageController.nextPage(
            duration: MangaReaderConstants.pageTransitionDuration,
            curve: Curves.easeInOutCubic,
          ),
          isNext: isRightToLeft,
          gradientColors: [
            AppColors.primaryColor.withOpacity(0.3),
            Colors.transparent
          ],
        ),
        const Spacer(),
        _buildIndicator(
          onTap: () => pageController.previousPage(
            duration: MangaReaderConstants.pageTransitionDuration,
            curve: Curves.easeInOutCubic,
          ),
          isNext: !isRightToLeft,
          gradientColors: [
            Colors.transparent,
            AppColors.primaryColor.withOpacity(0.3)
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required VoidCallback onTap,
    required bool isNext,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        decoration:
            BoxDecoration(gradient: LinearGradient(colors: gradientColors)),
        child: Center(
          child: AnimatedOpacity(
            opacity: 0.5,
            duration: MangaReaderConstants.fadeDuration,
            child: Icon(
              isNext ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
