import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class AdvancedTikTokVideoPlayer extends StatefulWidget {
  final ContentItem item;

  const AdvancedTikTokVideoPlayer({super.key, required this.item});

  @override
  State<AdvancedTikTokVideoPlayer> createState() =>
      _AdvancedTikTokVideoPlayerState();
}

class _AdvancedTikTokVideoPlayerState extends State<AdvancedTikTokVideoPlayer>
    with TickerProviderStateMixin {
  // Controllers
  late VideoPlayerController _controller;

  // State variables
  Timer? _controlsTimer;
  Timer? _progressTimer;
  bool _isVideoLoaded = false;
  bool _isDoubleTapped = false;
  bool _isLiked = false;
  bool _isMuted = false;
  bool _showControls = false;
  bool _isBuffering = false;
  bool _showVolumeSlider = false;
  double _videoProgress = 0.0;
  double _tapPositionX = 0.0;
  double _tapPositionY = 0.0;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;

  // Video information
  String _videoAuthor = '';
  String _videoDescription = '';
  int _likeCount = 0;
  int _commentCount = 0;
  int _shareCount = 0;
  int _viewCount = 0;

  // Advanced features
  bool _isSlowMotion = false;
  bool _isAutoPlay = true;
  bool _showStats = false;
  List<double> _volumeLevels = [];
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _setupMockData();
    _startVolumeMonitoring();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        widget.item.source.cdn != null
            ? widget.item.source.cdn! + widget.item.videoUrl!
            : widget.item.videoUrl ?? ''));

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isVideoLoaded = true;
          _volume = _controller.value.volume;
        });

        if (_isAutoPlay) {
          _controller.play();
          _startProgressListener();
        }

        // Add haptic feedback
        HapticFeedback.lightImpact();
      }
    }).catchError((error) {
      debugPrint('Video initialization error: $error');
    });

    _controller.setLooping(true);

    _controller.addListener(() {
      if (!mounted) return;

      final isBuffering = _controller.value.isBuffering;
      if (isBuffering != _isBuffering) {
        setState(() => _isBuffering = isBuffering);
      }
    });
  }

  void _setupMockData() {
    _videoAuthor =
        '@${widget.item.title?.split(' ').first.toLowerCase() ?? 'creator'}';
    _videoDescription = 'Amazing content! #trending #viral #fyp';
    _likeCount = math.Random().nextInt(100000) + 1000;
    _commentCount = math.Random().nextInt(10000) + 100;
    _shareCount = math.Random().nextInt(5000) + 50;
    _viewCount = _likeCount * (math.Random().nextInt(20) + 5);
  }

  void _startProgressListener() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_controller.value.isInitialized || !mounted) {
        timer.cancel();
        return;
      }

      final position = _controller.value.position;
      final duration = _controller.value.duration;

      if (duration.inMilliseconds > 0) {
        setState(() {
          _videoProgress = position.inMilliseconds / duration.inMilliseconds;
        });
      }
    });
  }

  void _startVolumeMonitoring() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_volumeLevels.length >= 50) {
        _volumeLevels.removeAt(0);
      }
      _volumeLevels.add(_volume + math.Random().nextDouble() * 0.3);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controlsTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        if (_progressTimer?.isActive != true) {
          _startProgressListener();
        }
      }
    });

    HapticFeedback.selectionClick();
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    final size = MediaQuery.of(context).size;
    _tapPositionX = details.localPosition.dx;
    _tapPositionY = details.localPosition.dy;

    setState(() {
      _isDoubleTapped = true;
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    HapticFeedback.heavyImpact();

    // Auto-hide double tap effect
    Timer(800.ms, () {
      if (mounted) setState(() => _isDoubleTapped = false);
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : _volume);
    });
    HapticFeedback.selectionClick();
  }

  void _changePlaybackSpeed() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;

    setState(() {
      _playbackSpeed = speeds[nextIndex];
      _isSlowMotion = _playbackSpeed < 1.0;
    });

    _controller.setPlaybackSpeed(_playbackSpeed);
    HapticFeedback.selectionClick();
  }

  void _seekVideo(double value) {
    final duration = _controller.value.duration;
    final newPosition =
        Duration(milliseconds: (duration.inMilliseconds * value).round());
    _controller.seekTo(newPosition);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTapDown: _handleDoubleTap,
      onDoubleTap: () {},
      onLongPress: () {
        HapticFeedback.heavyImpact();
        setState(() => _showStats = !_showStats);
      },
      child: VisibilityDetector(
        key: Key(widget.item.videoUrl ?? ''),
        onVisibilityChanged: (visibilityInfo) {
          if (!_isAutoPlay) return;

          if (visibilityInfo.visibleFraction == 0) {
            _controller.pause();
          } else if (visibilityInfo.visibleFraction > 0.8) {
            if (!_controller.value.isPlaying) {
              _controller.play();
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _isVideoLoaded ? _buildVideoContent() : _buildLoadingState(),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),

        // Buffering indicator
        if (_isBuffering)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(
                    color: AppColors.primaryColor,
                    radius: 20,
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: 1000.ms),
                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'Buffering...',
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                  ).animate().fadeIn().slideY(begin: 0.3),
                ],
              ),
            ),
          ),

        // Double tap heart effect
        if (_isDoubleTapped)
          Positioned(
            left: _tapPositionX - 40,
            top: _tapPositionY - 40,
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 80,
            )
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.2, 1.2),
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(0.8, 0.8),
                  duration: 300.ms,
                )
                .fadeOut(duration: 300.ms),
          ),

        // Multiple heart particles
        if (_isDoubleTapped)
          ...List.generate(6, (index) {
            final angle = (index * 60.0) * (math.pi / 180);
            final radius = 60.0 + (index * 10);
            return Positioned(
              left: _tapPositionX + math.cos(angle) * radius - 15,
              top: _tapPositionY + math.sin(angle) * radius - 15,
              child: Icon(
                Icons.favorite,
                color: Colors.red.withOpacity(0.7),
                size: 30,
              )
                  .animate(delay: (index * 50).ms)
                  .scale(begin: const Offset(0.0, 0.0))
                  .fadeOut(duration: 800.ms),
            );
          }),

        // Play/Pause overlay
        if (!_controller.value.isPlaying && !_isBuffering)
          Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 50,
                  color: Colors.black,
                ),
              ).animate().scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  ),
            ),
          ),

        // Gradient overlays
        _buildGradientOverlay(
            Alignment.topCenter, Alignment.bottomCenter, 120, true),
        _buildGradientOverlay(
            Alignment.bottomCenter, Alignment.topCenter, 150, false),

        // Progress indicator
        _buildProgressIndicator(),

        // Control overlay
        if (_showControls) _buildControlOverlay(),

        // Stats overlay
        if (_showStats) _buildStatsOverlay(),

        // Volume slider
        if (_showVolumeSlider) _buildVolumeSlider(),

        // Right side interactions
        _buildRightSideActions(),

        // Bottom content info
        _buildBottomContent(),

        // Slow motion indicator
        if (_isSlowMotion)
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.slow_motion_video, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  TextWidget(
                    text: '${_playbackSpeed}x',
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ).animate().slideX(begin: -1.0, duration: 300.ms).fadeIn(),
          ),
      ],
    );
  }

  Widget _buildGradientOverlay(
      Alignment begin, Alignment end, double height, bool isTop) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: _videoProgress,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, Colors.pink],
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlOverlay() {
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  TextWidget(
                    text: _formatDuration(position),
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryColor,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: Slider(
                        value: _videoProgress,
                        onChanged: _seekVideo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextWidget(
                    text: _formatDuration(duration),
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildStatsOverlay() {
    return Positioned(
      top: 100,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Resolution',
                '${_controller.value.size.width.toInt()}x${_controller.value.size.height.toInt()}'),
            _buildStatRow('FPS', '30'),
            _buildStatRow('Bitrate', '2.5 Mbps'),
            _buildStatRow('Codec', 'H.264'),
            _buildStatRow('Views', _formatCount(_viewCount)),
          ],
        ),
      ).animate().slideX(begin: 1.0, duration: 300.ms).fadeIn(),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          TextWidget(
            text: '$label: ',
            color: Colors.white.withOpacity(0.7),
            fontSize: 10.sp,
          ),
          TextWidget(
            text: value,
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Positioned(
      right: 80,
      bottom: 200,
      child: Container(
        height: 120,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: (value) {
                      setState(() => _volume = value);
                      _controller.setVolume(_isMuted ? 0.0 : value);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ).animate().slideX(begin: 1.0, duration: 300.ms).fadeIn(),
    );
  }

  Widget _buildRightSideActions() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            count: _formatCount(_likeCount),
            color: _isLiked ? Colors.red : Colors.white,
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
                _likeCount += _isLiked ? 1 : -1;
              });
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            count: _formatCount(_commentCount),
            onTap: _showCommentsModal,
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: Icons.share,
            count: _formatCount(_shareCount),
            onTap: _showShareOptions,
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            onTap: () {
              if (_isMuted) {
                _toggleMute();
              } else {
                setState(() => _showVolumeSlider = !_showVolumeSlider);
                Timer(3.seconds, () {
                  if (mounted) setState(() => _showVolumeSlider = false);
                });
              }
            },
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: Icons.speed,
            onTap: _changePlaybackSpeed,
          ),
          const SizedBox(height: 20),
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              return FavoriteButton(
                item: widget.item,
                contentType: ContentTypes.TIKTOK,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? count,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color ?? Colors.white,
              size: 26,
            ),
            if (count != null) ...[
              const SizedBox(height: 4),
              TextWidget(
                text: count,
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: const CustomIconWidget(
                    imageUrl: "assets/images/icon.png",
                  ),
                ),
              ).animate().scale(begin: const Offset(0.0, 0.0), delay: 300.ms),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: _videoAuthor,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: _videoDescription,
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13.sp,
                      maxLine: 2,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.visibility,
                            color: Colors.white.withOpacity(0.7), size: 16),
                        const SizedBox(width: 4),
                        TextWidget(
                          text: '${_formatCount(_viewCount)} views',
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      )
          .animate()
          .slideY(begin: 1.0, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail with blur effect
        ImageWidget(
          imagePath: widget.item.source.cdn != null
              ? widget.item.source.cdn! + widget.item.thumbnailUrl
              : widget.item.thumbnailUrl,
          fit: BoxFit.cover,
        ),

        // Blurred overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),

        // Loading content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: CupertinoActivityIndicator(
                  color: AppColors.primaryColor,
                  radius: 20,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2000.ms)
                  .then(),
              const SizedBox(height: 20),
              TextWidget(
                text: 'Loading amazing content...',
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ],
    );
  }

  void _showCommentsModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextWidget(
                    text: 'Comments',
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  TextWidget(
                    text: _formatCount(_commentCount),
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14.sp,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryColor,
                        child: TextWidget(
                          text: 'U${index + 1}',
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'user${index + 1}',
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 4),
                            TextWidget(
                              text:
                                  'This is an amazing video! Love the content 🔥',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13.sp,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                TextWidget(
                                  text: '${math.Random().nextInt(24)}h',
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11.sp,
                                ),
                                const SizedBox(width: 16),
                                TextWidget(
                                  text: 'Reply',
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                TextWidget(
                                  text: '${math.Random().nextInt(100)}',
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: 'Share Video',
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.copy, 'Copy Link'),
                _buildShareOption(Icons.share, 'Share'),
                _buildShareOption(Icons.download, 'Save'),
                _buildShareOption(Icons.report, 'Report'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.selectionClick();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: label,
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.8),
                    AppColors.primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),

            // Main video player
            _buildVideoPlayer(),

            // Back button
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ).animate().slideX(begin: -1.0, duration: 300.ms).fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}
