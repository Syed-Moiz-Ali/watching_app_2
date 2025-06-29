import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/enums/enums.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/presentation/provider/webview_provider.dart';
import 'package:watching_app_2/shared/widgets/appbars/app_bar.dart';
import 'package:watching_app_2/shared/widgets/loading/loading_indicator.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/misc/gap.dart';
import '../../widgets/misc/text_widget.dart';

class VideoPlayer extends StatefulWidget {
  final ContentItem item;

  const VideoPlayer({super.key, required this.item});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  bool isFullscreen = false;
  bool _showControls = true;
  bool _isHovering = false;

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });

    if (isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<WebviewProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: isFullscreen ? null : _buildMinimalAppBar(provider),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: _buildContent(provider),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMinimalAppBar(WebviewProvider provider) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: TextWidget(
          text: widget.item.title,
          styleType: TextStyleType.body,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.3),
      actions: [
        Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              provider.loadVideos(widget.item);
              provider.webViewController.reload();
            },
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
      ],
    );
  }

  Widget _buildContent(WebviewProvider provider) {
    if (provider.error != null) {
      return _buildErrorState(provider);
    }

    if (provider.firstVideoUrl == null) {
      return _buildNoVideoState();
    }

    return Column(
      children: [
        Expanded(
          child: _buildVideoPlayer(provider),
        ),
        if (!isFullscreen) _buildVideoInfo(),
      ],
    );
  }

  Widget _buildVideoPlayer(WebviewProvider provider) {
    return Container(
      margin: isFullscreen ? EdgeInsets.zero : EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        borderRadius:
            isFullscreen ? BorderRadius.zero : BorderRadius.circular(20),
        boxShadow: isFullscreen
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius:
            isFullscreen ? BorderRadius.zero : BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video player
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: provider.isLoading
                  ? _buildLoadingState()
                  : WebViewWidget(
                      controller: provider.webViewController,
                    ),
            ),

            // Overlay controls
            // if (!provider.isLoading) _buildVideoOverlay(provider),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, curve: Curves.easeOut)
        .then(delay: 200.ms)
        .shimmer(
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.1),
        );
  }

  Widget _buildVideoOverlay(WebviewProvider provider) {
    return Positioned.fill(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: (_showControls || _isHovering) ? 1.0 : 0.0,
              child: Stack(
                children: [
                  // Fullscreen button
                  Positioned(
                    top: 2.h,
                    right: 3.w,
                    child: _buildControlButton(
                      icon: isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      onPressed: _toggleFullscreen,
                    ).animate().fadeIn(delay: 100.ms),
                  ),

                  // Play/Pause overlay (center)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 8.w,
                      ),
                    )
                        .animate()
                        .scale(begin: const Offset(0.8, 0.8))
                        .fadeIn(duration: 400.ms),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.movie_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: widget.item.title,
                  styleType: TextStyleType.subheading2,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 0.5.h),
                TextWidget(
                  text: "Now Playing",
                  styleType: TextStyleType.body2,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const CustomLoadingIndicator(),
            ),
            SizedBox(height: 3.h),
            TextWidget(
              text: "Loading video...",
              styleType: TextStyleType.body,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Widget _buildNoVideoState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(6.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_off_rounded,
                size: 12.w,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 3.h),
            const TextWidget(
              text: 'No Video Available',
              styleType: TextStyleType.heading2,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 1.h),
            TextWidget(
              text: 'This content is currently unavailable',
              styleType: TextStyleType.body,
              color: Colors.white.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.9, 0.9))
          .then(delay: 200.ms)
          .shake(hz: 2, curve: Curves.easeInOut),
    );
  }

  Widget _buildErrorState(WebviewProvider provider) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(6.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 12.w,
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: 3.h),
            TextWidget(
              text: 'Something went wrong',
              styleType: TextStyleType.heading2,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 1.h),
            TextWidget(
              text: provider.error ?? 'An unexpected error occurred',
              styleType: TextStyleType.body,
              color: Colors.white.withOpacity(0.8),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => provider.webViewController.reload(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 1.8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const TextWidget(
                  text: 'Try Again',
                  styleType: TextStyleType.body,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.9, 0.9))
          .then(delay: 100.ms)
          .shake(hz: 3, curve: Curves.easeInOut),
    );
  }
}
