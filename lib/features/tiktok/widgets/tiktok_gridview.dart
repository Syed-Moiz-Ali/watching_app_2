import 'package:flutter/material.dart';

import '../../../../data/models/content_item.dart';
import '../presentation/screens/tiktok_player.dart';

class TiktokGridView extends StatefulWidget {
  final List<ContentItem> tiktok;
  final int initalPage;
  final Function(int) onItemTap;

  final PageController? controller; // Add ScrollController

  const TiktokGridView({
    super.key,
    required this.tiktok,
    required this.onItemTap,
    this.controller, // Make it optional
    this.initalPage = 0,
  });

  @override
  State<TiktokGridView> createState() => _TiktokGridViewState();
}

class _TiktokGridViewState extends State<TiktokGridView> {
  @override
  Widget build(BuildContext context) {
    // PageController _scrollController =
    //     PageController(viewportFraction: 1, initialPage: widget.initalPage);

    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: widget.controller ??
          PageController(viewportFraction: 1, initialPage: widget.initalPage),
      itemCount: widget.tiktok.length,
      itemBuilder: (context, index) {
        var item = widget.tiktok[index];
        return AdvancedTikTokVideoPlayer(
          item: item,
          // onTap: () => onItemTap(index),
        );
      },
    );
  }
}
