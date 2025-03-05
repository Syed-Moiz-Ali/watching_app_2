import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/core/navigation/navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/presentation/widgets/misc/custom_image_widget.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';

import '../../../data/models/content_item.dart';

class ContentItemWidget extends StatefulWidget {
  final ContentItem item;
  final int index;
  final String sourceId;
  final bool isGrid;

  const ContentItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.sourceId,
    this.isGrid = false,
  });

  @override
  State<ContentItemWidget> createState() => _ContentItemWidgetState();
}

class _ContentItemWidgetState extends State<ContentItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: _buildContentItem(),
        ),
      ),
    );
  }

  Widget _buildContentItem() {
    return Hero(
      tag: 'content_${widget.sourceId}_${widget.index}',
      child: GestureDetector(
        onTap: () {
          setState(() {
            _controller.reverse().then((_) {
              _controller.forward();
              // NH.navigateTo(DetailScreen(item: widget.item));
              NH.nameNavigateTo(AppRoutes.detail,
                  arguments: {'item': widget.item});
            });
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          margin: EdgeInsets.symmetric(
              vertical: widget.isGrid ? 0 : 8,
              horizontal: widget.isGrid ? 0 : 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(color: AppColors.greyColor)

              // boxShadow: [
              //   BoxShadow(
              //     color: _isPlaying
              //         ? Theme.of(context).primaryColor.withOpacity(0.2)
              //         : Colors.black.withOpacity(0.1),
              //     blurRadius: _isPlaying ? 20 : 12,
              //     offset: const Offset(0, 1),
              //     spreadRadius: _isPlaying ? 1 : 0,
              //   ),
              // ],
              ),
          child: widget.isGrid ? _buildGridItem() : _buildListItem(),
        ),
      ),
    );
  }

  Widget _buildGridItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageStack(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              // const SizedBox(height: 8),
              // _buildInfoRow(Icons.person, widget.item.time, Colors.grey[600]!),
              // const SizedBox(height: 6),
              // _buildInfoRow(Icons.visibility, '${widget.item.time} views',
              //     Colors.grey[600]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageStack(width: MediaQuery.of(context).size.width * 0.35),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      Icons.person, widget.item.time, Colors.grey[600]!),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.visibility, '${widget.item.time} views',
                      Colors.grey[600]!),
                ],
              ),
            ),
          ),
          _buildMoreButton(),
        ],
      ),
    );
  }

  Widget _buildImageStack({double? width}) {
    return ClipRRect(
      borderRadius: widget.isGrid
          ? BorderRadius.vertical(top: Radius.circular(4.w))
          : BorderRadius.horizontal(left: Radius.circular(4.w)),
      child: SizedBox(
        width: width ?? double.infinity,
        height: widget.isGrid ? 15.h : 20.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomImageWidget(
              borderRadius: widget.isGrid
                  ? BorderRadius.vertical(top: Radius.circular(4.w))
                  : BorderRadius.horizontal(left: Radius.circular(4.w)),
              imagePath: widget.item.thumbnailUrl,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: _buildBadge(widget.item.duration, Colors.black87),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: _buildBadge(
                  widget.item.quality, Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return TextWidget(
      text: widget.item.title,
      maxLine: 2,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreButton() {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => _showEnhancedMenu(context),
    );
  }

  void _showEnhancedMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            ...[
              (Icons.play_arrow, 'Play', () {}),
              (Icons.playlist_add, 'Add to Playlist', () {}),
              (Icons.download, 'Download', () {}),
              (Icons.share, 'Share', () {}),
            ].map((item) => _buildMenuItem(item.$1, item.$2, item.$3)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child:
                  Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
