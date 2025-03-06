import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../data/models/content_item.dart';
import 'video_card.dart';

class VideoGridView extends StatelessWidget {
  final List<ContentItem> videos;
  final bool isGrid;
  final int currentPlayingIndex;
  final Function(int) onItemTap;
  final Function(int) onHorizontalDragStart;
  final Function(int) onHorizontalDragEnd;
  final ScrollController? controller; // Add ScrollController
  final String contentType;

  const VideoGridView(
      {super.key,
      required this.videos,
      this.isGrid = false,
      required this.currentPlayingIndex,
      required this.onItemTap,
      required this.onHorizontalDragStart,
      required this.onHorizontalDragEnd,
      this.controller, // Make it optional
      this.contentType = 'video' // Make it optional
      });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.builder(
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
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 600),
            columnCount: isGrid ? 2 : 1,
            child: ScaleAnimation(
              scale: 0.85,
              child: FadeInAnimation(
                child: VideoCard(
                  item: item,
                  isPlaying: isPlaying,
                  isGrid: isGrid,
                  onTap: () => onItemTap(index),
                  onHorizontalDragStart: () => onHorizontalDragStart(index),
                  onHorizontalDragEnd: () => onHorizontalDragEnd(index),
                  contentType: contentType,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
