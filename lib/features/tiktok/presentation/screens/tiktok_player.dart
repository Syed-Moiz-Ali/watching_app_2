import 'dart:async';
import 'dart:developer';
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

class TikTokVideoPlayer extends StatefulWidget {
  final ContentItem item;

  const TikTokVideoPlayer({Key? key, required this.item}) : super(key: key);

  @override
  State<TikTokVideoPlayer> createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer>
    with SingleTickerProviderStateMixin {
  // Controllers
  late VideoPlayerController _controller;
  late AnimationController _animationController;

  // Animations
  late Animation<double> _controlsAnimation;
  late Animation<double> _playPauseAnimation;
  late Animation<double> _heartAnimation;

  // State variables
  Timer? _controlsTimer;
  bool _isMuted = false;
  bool _isVideoLoaded = false;
  bool _isDoubleTapped = false;
  bool _isLiked = false;
  double _videoProgress = 0.0;
  double _tapPosition = 0.0;

  // Video information
  String _videoAuthor = '';
  String _videoDescription = '';
  int _likeCount = 0;
  int _commentCount = 0;
  int _shareCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Controls fade animation
    _controlsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Play/Pause scale animation
    _playPauseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

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
    _commentCount = (500 + DateTime.now().second * 10);
    _shareCount = (200 + DateTime.now().second * 5);

    // Initialize video controller
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.item.videoUrl ?? ''))
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
    _animationController.forward(from: 0);
  }

  void _handleDoubleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
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

  void _handleSeek(double value) {
    final duration = _controller.value.duration;
    final position = duration * value;
    _controller.seekTo(position);
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
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
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
                      child: Container(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: _videoProgress,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.secondaryColor),
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
                                  child: CustomIconWidget(
                                    imageUrl: "assets/images/icon.png",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _videoAuthor,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _videoDescription,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
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
            imagePath: widget.item.thumbnailUrl,
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
              const CupertinoActivityIndicator(
                color: AppColors.secondaryColor,
                radius: 16,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Text(
          _formatDuration(_controller.value.position),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.secondaryColor,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              thumbColor: AppColors.secondaryColor,
              overlayColor: AppColors.secondaryColor.withOpacity(0.3),
            ),
            child: Slider(
              value: _controller.value.position.inSeconds.toDouble(),
              min: 0.0,
              max: _controller.value.duration.inSeconds.toDouble(),
              onChanged: (value) {
                _controller.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
        ),
        Text(
          _formatDuration(_controller.value.duration),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    double size = 28,
  }) {
    return ScaleTransition(
      scale: _playPauseAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            onPressed();
            _animationController.forward(from: 0);
          },
          icon: Icon(icon, color: iconColor, size: size),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
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
              const SizedBox(height: 16),
              const Text(
                'Comments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '@user${index + 100}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${index + 1}h ago',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'This is such an amazing video! ${index == 0 ? 'I can\'t believe how cool this is!' : ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${42 - index * 7}',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.reply,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reply',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
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
              const Text(
                'Share to',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                        child: const Center(
                          child: Text(
                            'Save video',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
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
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
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
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
