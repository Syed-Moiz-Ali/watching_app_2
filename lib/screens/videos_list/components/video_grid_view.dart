import 'package:flutter/material.dart';

import '../../../models/content_item.dart';
import 'video_card.dart';

class VideoGridView extends StatelessWidget {
  final List<ContentItem> videos;
  final bool isGrid;
  final int currentPlayingIndex;
  final Function(int) onItemTap;
  final Function(int) onHorizontalDragStart;
  final Function(int) onHorizontalDragEnd;
  final ScrollController? controller; // Add ScrollController

  const VideoGridView({
    super.key,
    required this.videos,
    required this.isGrid,
    required this.currentPlayingIndex,
    required this.onItemTap,
    required this.onHorizontalDragStart,
    required this.onHorizontalDragEnd,
    this.controller, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller, // Use the controller
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isGrid ? 2 : 1,
        childAspectRatio: isGrid ? .68 : .9,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        var item = videos[index];
        final isPlaying = index == currentPlayingIndex;
        return VideoCard(
          item: item,
          isPlaying: isPlaying,
          isGrid: isGrid,
          onTap: () => onItemTap(index),
          onHorizontalDragStart: () => onHorizontalDragStart(index),
          onHorizontalDragEnd: () => onHorizontalDragEnd(index),
        );
      },
    );
  }
}
