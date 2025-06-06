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

class _VideoPlayerState extends State<VideoPlayer>
    with SingleTickerProviderStateMixin {
  // bool isLoading = true;
  bool isFullscreen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    // Add listener for fullscreen
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final provider =
    //       Provider.of<WebviewControllerProvider>(context, listen: false);
    //   _setupFullscreenDetection(provider);
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<WebviewProvider>();

    return Scaffold(
      appBar: isFullscreen
          ? null
          : CustomAppBar(
              title: widget.item.title,
              automaticallyImplyLeading: true,
              styleType: TextStyleType.body,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    provider.loadVideos(widget.item);
                    provider.webViewController.reload();
                  },
                ),
              ],
            ),
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: CustomPadding(
              allSidesFactor: .02,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildMainContent(provider)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(WebviewProvider provider) {
    if (provider.error != null) {
      return _buildErrorMessage(provider);
    }

    if (provider.firstVideoUrl == null) {
      return const Center(
        child: TextWidget(
          text: 'No video available',
          styleType: TextStyleType.subheading2,
        ),
      );
    }
    // Provider.of<SimilarContentProvider>(context);
    return Column(children: [
      ClipRRect(
        borderRadius:
            isFullscreen ? BorderRadius.zero : BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isFullscreen ? double.infinity : 50.h,
          decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.2),
            //     blurRadius: 10,
            //     offset: const Offset(0, 5),
            //   ),
            // ],
            // border: Border.all(),
            borderRadius:
                isFullscreen ? BorderRadius.zero : BorderRadius.circular(12),
          ),
          child: provider.isLoading
              ? const Center(
                  child: CustomLoadingIndicator(),
                )
              : WebViewWidget(
                  controller: provider.webViewController,
                ),
        ),
      ),
      // if (isFullscreen) ...[
      // Expanded(
      //   // height: 50.h,
      //   child: SimilarContentSection(
      //       similarContents: similarProvider.similarContents),
      //   // Column(
      //   //   children: List.generate(
      //   //     similarProvider.similarContents.length,
      //   //     (index) {
      //   //       var content = similarProvider.similarContents[index];
      //   //       return Container(
      //   //         child: TextWidget(text: content.title),
      //   //       );
      //   //     },
      //   //   ),
      //   // ),
      // ),
      const CustomGap(heightFactor: .08),
    ]);
  }

  Widget _buildErrorMessage(WebviewProvider provider) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(5.w),
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50.sp,
            ).animate().shake(),
            SizedBox(height: 2.h),
            const TextWidget(
              text: 'Error',
              styleType: TextStyleType.heading2,
              color: Colors.red,
            ),
            SizedBox(height: 1.h),
            TextWidget(
              text: provider.error ?? 'Unknown error occurred!',
              styleType: TextStyleType.body,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                provider.webViewController.reload();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const TextWidget(
                text: 'Try Again',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 400.ms).scale(begin: const Offset(0, 0.8)),
    );
  }
}
