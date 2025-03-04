import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/core/global/app_global.dart';
import 'package:watching_app_2/core/navigation/navigator.dart';
import 'package:watching_app_2/models/content_item.dart';
import 'package:watching_app_2/screens/detail_screen/detail_screen.dart';
import 'package:watching_app_2/widgets/custom_image_widget.dart';
import 'package:watching_app_2/widgets/text_widget.dart';

import '../../../routes.dart';

class SimilarContentSection extends StatefulWidget {
  final List<ContentItem> similarContents;

  const SimilarContentSection({
    super.key,
    required this.similarContents,
  });

  @override
  State<SimilarContentSection> createState() => _SimilarContentSectionState();
}

class _SimilarContentSectionState extends State<SimilarContentSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Similar Content Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.2, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: _controller,
              child: TextWidget(
                text: 'Similar Content',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        // Content Grid
        SizedBox(
          height: 32.h,
          // height: 35.h, // Fixed height for the horizontal list
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              itemCount: widget.similarContents.length,
              itemBuilder: (context, index) {
                final content = widget.similarContents[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 100 * index),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w, vertical: 1.h),
                        child: GestureDetector(
                            onTap: () {
                              // var provider =
                              //     Provider.of<WebviewControllerProvider>(
                              //         context,
                              //         listen: false);
                              // provider.loadVideos(content);
                              // NH.navigateTo(DetailScreen(item: content));
                              NH.nameNavigateTo(AppRoutes.detail,
                                  arguments: {'item': content});
                            },
                            child: SimilarContentCard(
                                content: content, index: index)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SimilarContentCard extends StatefulWidget {
  final ContentItem content;
  final int index;

  const SimilarContentCard({
    super.key,
    required this.content,
    required this.index,
  });

  @override
  State<SimilarContentCard> createState() => _SimilarContentCardState();
}

class _SimilarContentCardState extends State<SimilarContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
    isHovering ? _hoverController.forward() : _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final contentMargin = EdgeInsets.only(
      bottom: 1.h + (_isHovering ? -0.5.h : 0),
    );

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuint,
        margin: contentMargin,
        width: 55.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: _isHovering ? 12 : 8,
              offset: _isHovering ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Thumbnail
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  SizedBox(
                    height: 20.h,
                    width: double.infinity,
                    child: Hero(
                      tag: 'content-${widget.content.contentUrl}',
                      child: CustomImageWidget(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        imagePath: SMA.formatImage(
                            image: widget.content.thumbnailUrl,
                            baseUrl: widget.content.source.url),
                        fit: BoxFit.cover,
                        // placeholder: (context, url) => Shimmer.fromColors(
                        //   baseColor: Colors.grey[300]!,
                        //   highlightColor: Colors.grey[100]!,
                        //   child: Container(color: Colors.white),
                        // ),
                        // errorWidget: (context, url, error) => Container(
                        //   color: Colors.grey[200],
                        //   child: Icon(Icons.broken_image,
                        //       size: 8.w, color: Colors.grey),
                        // ),
                      ),
                    ),
                  ),

                  // Content details
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TextWidget(
                          text: widget.content.title,
                          // style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,

                          // ),
                          maxLine: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Source & Time
                      ],
                    ),
                  ),
                ],
              ),

              // Duration badge
              Positioned(
                top: 1.h,
                right: 1.h,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextWidget(
                    text: widget.content.duration,
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Quality badge
              Positioned(
                top: 1.h,
                left: 1.h,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getQualityColor(widget.content.quality),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextWidget(
                    text: widget.content.quality,
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Play overlay (appears on hover)
              AnimatedOpacity(
                opacity: _isHovering ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_isHovering ? 2.w : 1.5.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 8.w,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toUpperCase()) {
      case 'HD':
        return Colors.green;
      case '4K':
        return Colors.purple;
      case 'FHD':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
