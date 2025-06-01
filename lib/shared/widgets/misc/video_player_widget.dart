// ignore_for_file: library_private_types_in_public_api, must_be_immutable, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';

import '../../../core/constants/colors.dart';
import '../../../presentation/provider/source_provider.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String imageUrl;
  final bool isShown;
  final bool isLooping;

  const VideoPlayerWidget(
      {super.key,
      required this.videoUrl,
      required this.isShown,
      this.isLooping = false,
      required this.imageUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  late AnimationController _animeController;
  late Animation<double> _animation;
// Flag to track disposal

  @override
  void initState() {
    super.initState();
    checkIsShown();
    _animeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 0.15).animate(_animeController);
  }

  void checkIsShown() {
    print('videoUrl is ${widget.videoUrl}');
    if (widget.isShown == true) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      )..initialize().then((_) {
          setState(() {
            isPlaying = true;
          });
          _controller.play();
          _controller.setVolume(0.0);

          _controller.setLooping(widget.isLooping);
          _controller.addListener(() {
            if (_controller.value.position >= _controller.value.duration) {
              // Video playback complete
              setState(() {
                isPlaying = false;
              });
            }
          });
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    _animeController.dispose();
    // _isAnimeControllerDisposed = true; // Mark as disposed

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return Selector<SourceProvider, bool>(
          selector: (context, provider) => provider.closeVideoPlayer,
          builder: (context, dispose, _) {
            // log('disposedispose is $dispose');
            // if (dispose) {
            //   _controller.dispose();
            //   _isAnimeControllerDisposed = true;
            //   _animeController.dispose();
            // }
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                          height: _controller.value.size.height,
                          width: _controller.value.size.width,
                          child: VideoPlayer(_controller)),
                    ),
                  ),
                ),
                if (isPlaying == true)
                  const SizedBox.shrink()
                else
                  Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: isPlaying == false
                            ? AppColors.primaryColor.withOpacity(0.7)
                            : AppColors.primaryColor,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _controller.play();
                            _controller.addListener(() {
                              setState(() {
                                isPlaying = true;
                              });
                            });
                          },
                          child: Icon(
                            Icons.replay_rounded,
                            size: 40,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ))
              ],
            );
          });
    } else {
      return Stack(
        children: [
          ImageWidget(
            imagePath: widget.imageUrl,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                );
              },
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 30,
              width: 30,
              child: CupertinoActivityIndicator(
                color: AppColors.backgroundColorLight,
              ),
            ),
          )
        ],
      );
    }
  }
}
