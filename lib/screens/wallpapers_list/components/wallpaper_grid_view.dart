import 'package:flutter/material.dart';
import 'package:watching_app_2/screens/wallpapers_list/components/wallpaper_card.dart';

import '../../../models/content_item.dart';

class WallpaperGridView extends StatelessWidget {
  final List<ContentItem> wallpapers;

  final Function(int) onItemTap;

  final ScrollController? controller; // Add ScrollController

  const WallpaperGridView({
    super.key,
    required this.wallpapers,
    required this.onItemTap,
    this.controller, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller, // Use the controller
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
          onTap: () => onItemTap(index),
        );
      },
    );
  }
}
