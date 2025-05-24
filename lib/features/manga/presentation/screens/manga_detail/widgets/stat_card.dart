import 'package:flutter/material.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/constants/manga_detail_constants.dart';

import '../../../../../../shared/widgets/misc/text_widget.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: MangaDetailConstants.statPadding,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(height: 8),
            TextWidget(
              text: value,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            TextWidget(
              text: label,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
