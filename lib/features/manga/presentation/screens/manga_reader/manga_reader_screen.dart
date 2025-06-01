import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../data/models/content_item.dart';
import '../../../../../presentation/provider/manga_detail_provider.dart';
import '../../../../../shared/widgets/loading/loading_indicator.dart';
import '../../../../../shared/widgets/misc/text_widget.dart';

class MangaReaderScreen extends StatefulWidget {
  final ContentItem item;
  final Chapter chapter;

  const MangaReaderScreen({
    super.key,
    required this.item,
    required this.chapter,
  });

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen>
    with TickerProviderStateMixin {
  bool _isUIVisible = true;
  int _currentPage = 0;
  bool _isAutoScroll = false;
  double _autoScrollSpeed = 1.0;
  late AnimationController _autoScrollAnimationController;
  late AnimationController _uiAnimationController;
  late AnimationController _pageTransitionController;
  late AnimationController _fabAnimationController;
  late Animation<double> _uiSlideAnimation;
  late Animation<double> _uiOpacityAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _fabSlideAnimation;
  final ScrollController _scrollController = ScrollController();

  // Enhanced UI state
  bool _isMenuExpanded = false;
  bool _showPageIndicator = false;
  double _brightness = 1.0;
  PageController? _pageController;
  bool _isPageView = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSystemUI();
    _loadChapterDetails();
    _autoScrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_handleAutoScroll);
    _scrollController.addListener(_onScrollUpdate);

    // Auto-hide UI after 3 seconds
    _autoHideUI();
  }

  void _initializeAnimations() {
    // UI Animation Controller
    _uiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _uiSlideAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _uiAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _uiOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _uiAnimationController,
      curve: Curves.easeOut,
    ));

    // Page Transition Controller
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // FAB Animation Controller
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _initializeSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  void _autoHideUI() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isUIVisible && mounted) {
        _toggleUI();
      }
    });
  }

  void _onScrollUpdate() {
    if (_scrollController.hasClients) {
      final provider = context.read<MangaDetailProvider>();
      if (provider.chapterDetail != null) {
        final totalPages = provider.chapterDetail!.length;
        final scrollProgress = _scrollController.offset /
            _scrollController.position.maxScrollExtent;
        final newPage =
            (scrollProgress * totalPages).round().clamp(0, totalPages - 1);

        if (newPage != _currentPage) {
          setState(() {
            _currentPage = newPage;
            _showPageIndicator = true;
          });

          // Auto-hide page indicator
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showPageIndicator = false;
              });
            }
          });
        }
      }
    }
  }

  void _loadChapterDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<MangaDetailProvider>()
          .loadChapterDetails(widget.item, widget.chapter);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _uiAnimationController.dispose();
    _pageTransitionController.dispose();
    _fabAnimationController.dispose();
    _autoScrollAnimationController.dispose();
    _pageController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _handleAutoScroll() {
    if (!_isAutoScroll || !_scrollController.hasClients) return;

    final newOffset = _scrollController.offset + (_autoScrollSpeed * 1.5);
    if (newOffset >= _scrollController.position.maxScrollExtent) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      _stopAutoScroll();
    } else {
      _scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 50),
        curve: Curves.linear,
      );
    }
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScroll = !_isAutoScroll;
    });
    if (_isAutoScroll) {
      _autoScrollAnimationController.repeat();
      _fabAnimationController.forward();
    } else {
      _autoScrollAnimationController.stop();
      _fabAnimationController.reverse();
    }
    HapticFeedback.mediumImpact();
  }

  void _stopAutoScroll() {
    setState(() {
      _isAutoScroll = false;
    });
    _autoScrollAnimationController.stop();
    _fabAnimationController.reverse();
  }

  void _adjustAutoScrollSpeed(double value) {
    setState(() {
      _autoScrollSpeed = value;
    });
    HapticFeedback.selectionClick();
  }

  void _toggleUI() {
    setState(() {
      _isUIVisible = !_isUIVisible;
    });

    if (_isUIVisible) {
      _uiAnimationController.forward();
      _autoHideUI();
    } else {
      _uiAnimationController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  void _toggleReadingMode() {
    setState(() {
      _isPageView = !_isPageView;
    });

    if (_isPageView) {
      _pageController = PageController(initialPage: _currentPage);
    } else {
      _pageController?.dispose();
      _pageController = null;
    }

    HapticFeedback.mediumImpact();
  }

  void _handleTapNavigation(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.localPosition.dx;
    final leftZone = screenWidth * 0.3;
    final rightZone = screenWidth * 0.7;

    if (_isPageView && _pageController != null) {
      if (tapPosition < leftZone) {
        _pageController!.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (tapPosition > rightZone) {
        _pageController!.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _toggleUI();
      }
    } else {
      if (_scrollController.hasClients) {
        if (tapPosition < leftZone) {
          _scrollController.animateTo(
            (_scrollController.offset -
                    MediaQuery.of(context).size.height * 0.8)
                .clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        } else if (tapPosition > rightZone) {
          _scrollController.animateTo(
            (_scrollController.offset +
                    MediaQuery.of(context).size.height * 0.8)
                .clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        } else {
          _toggleUI();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<MangaDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }
          if (provider.chapterDetail == null ||
              provider.chapterDetail!.isEmpty) {
            return _buildErrorState(provider);
          }
          return Stack(
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.matrix([
                  _brightness,
                  0,
                  0,
                  0,
                  0,
                  0,
                  _brightness,
                  0,
                  0,
                  0,
                  0,
                  0,
                  _brightness,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: _buildReaderContent(provider),
              ),
              // if (_isUIVisible) _buildUIOverlay(provider),
              _buildPageIndicator(provider),
              if (_isUIVisible) ...[
                _buildTopBar(),
                _buildBottomBar(provider),
              ],
              _buildFloatingControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomLoadingIndicator(),
          const SizedBox(height: 16),
          TextWidget(
            text: 'Loading chapter...',
            fontSize: 14.sp,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MangaDetailProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white54,
                  size: 64,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          TextWidget(
            text: 'Unable to load chapter',
            fontSize: 16.sp,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: provider.error ?? 'Please try again',
            fontSize: 12.sp,
            color: Colors.white54,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context
                  .read<MangaDetailProvider>()
                  .loadChapterDetails(widget.item, widget.chapter);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            child: const TextWidget(text: 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUIOverlay(MangaDetailProvider provider) {
    return AnimatedBuilder(
      animation: _uiAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _uiOpacityAnimation.value,
          child: Stack(
            children: [
              _buildTopBar(),
              _buildBottomBar(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding:
            const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: widget.item.title,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    maxLine: 1,
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    text: widget.chapter.chapterName ?? 'Chapter',
                    fontSize: 13.sp,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  _isPageView ? Icons.view_stream : Icons.view_agenda,
                  color: Colors.white,
                ),
                onPressed: _toggleReadingMode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(MangaDetailProvider provider) {
    final totalPages = provider.chapterDetail?.length ?? 0;
    final progress = totalPages > 0 ? (_currentPage + 1) / totalPages : 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced Progress bar
              Container(
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                      // Glowing effect
                      Positioned.fill(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page counter with enhanced styling
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextWidget(
                      text: '${_currentPage + 1} / $totalPages',
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Control buttons
                  Row(
                    children: [
                      _buildControlButton(
                        icon: _isAutoScroll
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        isActive: _isAutoScroll,
                        onPressed: _toggleAutoScroll,
                      ),
                      const SizedBox(width: 8),
                      _buildControlButton(
                        icon: Icons.skip_previous,
                        onPressed: () {
                          // Navigate to previous chapter
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildControlButton(
                        icon: Icons.skip_next,
                        onPressed: () {
                          // Navigate to next chapter
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Brightness and Speed Controls
              if (_isAutoScroll || _showBrightnessControl) ...[
                const SizedBox(height: 12),
                _buildAdvancedControls(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _showBrightnessControl => _brightness != 1.0;

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryColor.withOpacity(0.2)
            : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: AppColors.primaryColor.withOpacity(0.5))
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? AppColors.primaryColor : Colors.white70,
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildAdvancedControls() {
    return Column(
      children: [
        if (_isAutoScroll) ...[
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: Colors.white30,
                    thumbColor: AppColors.primaryColor,
                    overlayColor: AppColors.primaryColor.withOpacity(0.2),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _autoScrollSpeed,
                    min: 0.5,
                    max: 3.0,
                    divisions: 5,
                    onChanged: _adjustAutoScrollSpeed,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextWidget(
                  text: '${_autoScrollSpeed.toStringAsFixed(1)}x',
                  color: Colors.white70,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
        if (_showBrightnessControl) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.brightness_6, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.amber,
                    inactiveTrackColor: Colors.white30,
                    thumbColor: Colors.amber,
                    overlayColor: Colors.amber.withOpacity(0.2),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _brightness,
                    min: 0.3,
                    max: 1.2,
                    onChanged: (value) {
                      setState(() {
                        _brightness = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPageIndicator(MangaDetailProvider provider) {
    final totalPages = provider.chapterDetail?.length ?? 0;

    return Positioned(
      // duration: const Duration(milliseconds: 300),
      // curve: Curves.easeOutCubic,
      top: 20,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextWidget(
          text: '${_currentPage + 1}/$totalPages',
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFloatingControls() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brightness control FAB
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.black.withOpacity(0.7),
            foregroundColor: Colors.white,
            onPressed: () {
              setState(() {
                _brightness = _brightness == 1.0 ? 0.6 : 1.0;
              });
            },
            child: Icon(
              _brightness < 1.0 ? Icons.brightness_low : Icons.brightness_high,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          // Auto-scroll FAB (shows when active)
          if (_isAutoScroll)
            FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primaryColor.withOpacity(0.9),
              foregroundColor: Colors.white,
              onPressed: _toggleAutoScroll,
              child: const Icon(Icons.pause, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(MangaDetailProvider provider) {
    return Container(
      height: 100.h,
      child: GestureDetector(
        onTapDown: _handleTapNavigation,
        child: _isPageView
            ? _buildPageViewReader(provider)
            : _buildScrollViewReader(provider),
      ),
    );
  }

  Widget _buildPageViewReader(MangaDetailProvider provider) {
    return PageView.builder(
      controller: _pageController,
      itemCount: provider.chapterDetail?.length ?? 0,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildMangaPage(provider, index);
      },
    );
  }

  Widget _buildScrollViewReader(MangaDetailProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      physics: _isAutoScroll
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      itemCount: provider.chapterDetail?.length ?? 0,
      itemBuilder: (context, index) {
        return _buildMangaPage(provider, index);
      },
    );
  }

  Widget _buildMangaPage(MangaDetailProvider provider, int index) {
    return Hero(
      tag: 'manga_page_$index',
      child: InteractiveViewer(
        maxScale: 3.0,
        minScale: 1.0,
        child: CachedNetworkImage(
          imageUrl: provider.chapterDetail![index].chapterImage!,
          fit: BoxFit.fitWidth,
          placeholder: (context, url) => Container(
            height: MediaQuery.of(context).size.width * 1.4,
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                  ),
                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'Loading page ${index + 1}...',
                    fontSize: 12.sp,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: MediaQuery.of(context).size.width * 1.4,
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'Failed to load page ${index + 1}',
                    fontSize: 12.sp,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Retry loading this specific page
                      setState(() {});
                    },
                    child: TextWidget(
                      text: 'Retry',
                      color: AppColors.primaryColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
