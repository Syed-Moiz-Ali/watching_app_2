import 'package:flutter/material.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/constants/manga_reader_constants.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsTile({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MangaReaderConstants.sectionTitleStyle,
          ),
          const SizedBox(height: MangaReaderConstants.spacing),
          child,
        ],
      ),
    );
  }
}
