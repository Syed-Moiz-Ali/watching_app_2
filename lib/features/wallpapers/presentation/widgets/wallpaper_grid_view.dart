import 'package:flutter/material.dart';

import '../../../../data/database/local_database.dart';
import '../../../../data/models/content_item.dart';
import 'wallpaper_card.dart';

class WallpaperGridView extends StatelessWidget {
  final List<ContentItem> wallpapers;
  final String? contentType; // Default content type

  final Function(int) onItemTap;

  final ScrollController? controller; // Add ScrollController

  const WallpaperGridView({
    super.key,
    required this.wallpapers,
    required this.onItemTap,
    this.controller, // Make it optional
    this.contentType = ContentTypes.IMAGE, // Default content type
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller, // Use the controller
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .68,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        var item = wallpapers[index];
        return WallpaperCard(
          item: item,
          contentType: contentType,
          onTap: () => onItemTap(index),
        );
      },
    );
  }
}
