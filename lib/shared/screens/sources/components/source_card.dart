import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/core/constants/colors.dart';

import '../../../../presentation/provider/source_provider.dart';
import '../../../../features/videos/presentation/screens/videos.dart';

class SourceCard extends StatefulWidget {
  final ContentSource source;

  const SourceCard({required this.source, super.key});

  @override
  State<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<SourceCard> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greyColor),
          // boxShadow: [AppColors.shadow]
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            var provider = context.read<SourceProvider>();
            provider.selectedQuery = widget.source.query.entries.first.value;
            provider.updateState();
            if (widget.source.type == '1') {
              NH.nameNavigateTo(AppRoutes.videoList,
                  arguments: {"source": widget.source});
              // NH.navigateTo(VideoListScreen(source: widget.source));
            } else if (widget.source.type == '3') {
              // NH.navigateTo(WallpapersList(source: widget.source));
              NH.nameNavigateTo(AppRoutes.wallpapers,
                  arguments: {"source": widget.source});
            } else if (widget.source.type == '4') {
              NH.navigateTo(Manga(source: widget.source));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: CustomImageWidget(
                    imagePath: widget.source.icon,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: widget.source.name,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      const SizedBox(height: 6),
                      TextWidget(
                        text: 'Type: ${widget.source.type}',
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (widget.source.nsfw == '1')
                            Icon(
                              Icons.lock_outline,
                              size: 18.sp,
                              color: AppColors.errorColor,
                            ),
                          const SizedBox(width: 6),
                          if (widget.source.nsfw == '1')
                            TextWidget(
                              text: 'NSFW',
                              fontSize: 14.sp,
                              color: AppColors.errorColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18.sp,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
