import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/constants/manga_reader_constants.dart';

import '../../../../../../core/constants/colors.dart';

class ControlHub extends StatelessWidget {
  final VoidCallback onPressed;

  const ControlHub({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primaryColor,
      onPressed: onPressed,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
      elevation: 8,
      tooltip: 'Quick Actions',
    ).animate().scale(
        duration: MangaReaderConstants.animationDuration,
        curve: Curves.easeOutBack);
  }
}
