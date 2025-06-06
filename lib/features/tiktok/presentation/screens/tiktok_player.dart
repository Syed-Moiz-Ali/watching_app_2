import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/shared/widgets/misc/icon.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';

import '../../../../data/models/content_item.dart';
import '../../../../presentation/provider/favorites_provider.dart';
import '../../../../shared/screens/favorites/favorite_button.dart';
import '../../../../shared/widgets/misc/text_widget.dart';

class TikTokVideoPlayer extends StatefulWidget {
  final ContentItem item;

  const TikTokVideoPlayer({super.key, required this.item});

  @override
  State<TikTokVideoPlayer> createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer>
    with SingleTickerProviderStateMixin {
  // Controllers
  late VideoPlayerController _controller;
  late AnimationController _animationController;

  // Animations
  late Animation<double> _heartAnimation;

  // State variables
  Timer? _controlsTimer;
  bool _isVideoLoaded = false;
  bool _isDoubleTapped = false;
  bool _isLiked = false;
  double _videoProgress = 0.0;
  double _tapPosition = 0.0;

  // Video information
  String _videoAuthor = '';
  String _videoDescription = '';
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Controls fade animation

    // Play/Pause scale animation

    // Heart animation for double tap
    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Set mock data for demo
    _videoAuthor = '@browsex';
    _videoDescription = 'Check out this amazing video! #trending #viral';
    _likeCount = (10000 + DateTime.now().second * 100);

    // Initialize video controller
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        widget.item.source.cdn != null
            ? widget.item.source.cdn! + widget.item.videoUrl!
            : widget.item.videoUrl ?? ''))
      ..initialize().then((_) {
        setState(() {
          _isVideoLoaded = true;
          _controller.play();
          _animationController.forward();
          _startProgressListener();
        });
      })
      ..setLooping(true);

    _controller.addListener(() {
      if (!_controller.value.isInitialized) return;
      setState(() {
        _isVideoLoaded = _controller.value.isInitialized;
      });
    });
  }

  void _startProgressListener() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_controller.value.isInitialized && mounted) {
        final position = _controller.value.position;
        final duration = _controller.value.duration;

        if (duration.inMilliseconds > 0) {
          setState(() {
            _videoProgress = position.inMilliseconds / duration.inMilliseconds;
          });
        }
      }

      if (!mounted) timer.cancel();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
    _animationController.forward(from: 0);
  }

  void _handleDoubleTap(TapDownDetails details) {
    _tapPosition = details.localPosition.dx;

    setState(() {
      _isDoubleTapped = true;
      _isLiked = true;
    });

    _animationController.forward(from: 0);

    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isDoubleTapped = false;
        });
      }
    });
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTapDown: _handleDoubleTap,
      onDoubleTap: () {
        setState(() {
          _likeCount = _isLiked ? _likeCount - 1 : _likeCount + 1;
          _isLiked = !_isLiked;
        });
      },
      child: VisibilityDetector(
        key: Key(widget.item.videoUrl ?? ''),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0) {
            _controller.pause();
          } else if (visibilityInfo.visibleFraction == 1) {
            _controller.play();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _isVideoLoaded
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video player with fade transition
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _controller.value.isInitialized ? 1.0 : 0.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                    ),

                    // Double tap heart animation
                    if (_isDoubleTapped)
                      Positioned(
                        left: _tapPosition - 40,
                        top: MediaQuery.of(context).size.height / 2 - 40,
                        child: AnimatedBuilder(
                          animation: _heartAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _heartAnimation.value,
                              child: Opacity(
                                opacity: 1.0 - _heartAnimation.value * 0.5,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 80,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Play icon overlay with scale animation
                    if (!_controller.value.isPlaying)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          // shape: BoxShape.circle,
                        ),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween(begin: 0.1, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 40.sp,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Top gradient overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Video progress indicator
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: _videoProgress,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                        ),
                      ),
                    ),

                    // Right side interaction icons
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        children: [
                          // _buildInteractionButton(
                          //   icon: _isLiked
                          //       ? Icons.favorite
                          //       : Icons.favorite_border,
                          //   count: _formatCount(_likeCount),
                          //   color: _isLiked ? Colors.red : Colors.white,
                          //   onTap: () {
                          //     setState(() {
                          //       _isLiked = !_isLiked;
                          //       _likeCount =
                          //           _isLiked ? _likeCount + 1 : _likeCount - 1;
                          //     });
                          //   },
                          // ),
                          // const SizedBox(height: 16),
                          // _buildInteractionButton(
                          //   icon: Icons.chat_bubble_outline,
                          //   count: _formatCount(_commentCount),
                          //   onTap: () {
                          //     // Show comments modal
                          //     _showCommentsModal();
                          //   },
                          // ),
                          // const SizedBox(height: 16),
                          // _buildInteractionButton(
                          //   icon: Icons.share,
                          //   count: _formatCount(_shareCount),
                          //   onTap: () {
                          //     // Show share options
                          //     _showShareOptions();
                          //   },
                          // ),
                          // const SizedBox(height: 16),
                          // _buildAnimatedIconButton(
                          //   icon: _isMuted
                          //       ? Icons.volume_off_rounded
                          //       : Icons.volume_up_rounded,
                          //   onPressed: _toggleMute,
                          // ),
                          // const SizedBox(height: 16),
                          Consumer<FavoritesProvider>(
                            builder: (context, provider, child) {
                              return Transform.scale(
                                scale: 1.2,
                                child: FavoriteButton(
                                  item: widget.item,
                                  contentType: ContentTypes.TIKTOK,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Video information
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  color: Colors.grey.shade800,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: const CustomIconWidget(
                                    imageUrl: "assets/images/icon.png",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: _videoAuthor,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                    const SizedBox(height: 4),
                                    TextWidget(
                                      text: _videoDescription,
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : _buildLoadingState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail with blur effect
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageWidget(
            imagePath: widget.item.source.cdn != null
                ? widget.item.source.cdn! + widget.item.thumbnailUrl
                : widget.item.thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ),

        // Blurred overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),

        // Loading overlay with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // Loading indicator
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(
                color: AppColors.primaryColor,
                radius: 16,
              ),
              const SizedBox(height: 16),
              TextWidget(
                text: 'Loading video...',
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              TextWidget(
                text: 'Share to',
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(Icons.copy, 'Copy link'),
                  _buildShareOption(Icons.mail, 'Email'),
                  _buildShareOption(Icons.more_horiz, 'More'),
                  _buildShareOption(Icons.send, 'Direct'),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                            child: TextWidget(
                          text: 'Save video',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        TextWidget(
          text: label,
          color: Colors.white,
          fontSize: 12.sp,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white),
            ),
            onPressed: () {
              // Show more options
              _showMoreOptions();
            },
          ),
        ],
      ),
      body: _buildVideoPlayer(),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(Icons.flag, 'Report video', onTap: () {
                Navigator.pop(context);
                // Show report dialog
              }),
              _buildOptionTile(Icons.do_not_disturb_alt, 'Not interested',
                  onTap: () {
                Navigator.pop(context);
                // Show feedback saved message
              }),
              _buildOptionTile(Icons.download, 'Download video', onTap: () {
                Navigator.pop(context);
                // Show download progress
              }),
              _buildOptionTile(Icons.share, 'Share', onTap: () {
                Navigator.pop(context);
                _showShareOptions();
              }),
              _buildOptionTile(Icons.info_outline, 'About this content',
                  onTap: () {
                Navigator.pop(context);
                // Show content info
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(IconData icon, String label,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: TextWidget(
        text: label,
        color: Colors.white,
      ),
      onTap: onTap,
    );
  }
}
