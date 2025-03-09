import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../data/models/content_item.dart';
import '../../../../presentation/provider/manga_detail_provider.dart';
import '../../../../shared/widgets/loading/loading_indicator.dart';
import '../../../../shared/widgets/misc/image.dart';

class MangaReaderScreen extends StatefulWidget {
  final ContentItem item;
  const MangaReaderScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isUIVisible = true;
  bool _isVerticalReading = false;
  bool _isRightToLeft = true;
  bool _isFullscreen = false;
  double _brightness = 1.0;
  bool _isAutoScroll = false;
  double _autoScrollSpeed = 1.0;
  Color _pageBackgroundColor = Colors.black;
  double _pageMargin = 0.0;

  // Reading progress tracking
  int _lastReadPage = 0;
  DateTime _startReadingTime = DateTime.now();

  late AnimationController _animationController;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Enter immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MangaDetailProvider>().loadChapterDetails(widget.item);
      _loadReaderSettings();
      _startAutoScrollTimerIfEnabled();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _verticalScrollController.dispose();

    // Exit immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Save reading progress
    _saveReadingProgress();
    super.dispose();
  }

  Future<void> _loadReaderSettings() async {
    // In a real app, this would load from shared preferences
    // For this example, we'll just use default values
    setState(() {
      _isRightToLeft = true;
      _isVerticalReading = false;
      _brightness = 1.0;
      _pageBackgroundColor = Colors.black;
      _pageMargin = 0.0;
      _lastReadPage = 0;
    });
  }

  Future<void> _saveReaderSettings() async {
    // In a real app, this would save to shared preferences
  }

  Future<void> _saveReadingProgress() async {
    final readDuration = DateTime.now().difference(_startReadingTime);
    final pageCount = _getPageCount(context);
    final readPercentage =
        pageCount > 0 ? (_currentPage + 1) / pageCount * 100 : 0;

    // In a real app, this would save to a database or shared preferences
    print('Reading session stats:');
    print('- Duration: ${readDuration.inMinutes} minutes');
    print('- Progress: ${readPercentage.toStringAsFixed(1)}%');
    print('- Last page: ${_currentPage + 1} of $pageCount');
  }

  void _toggleUI() {
    setState(() {
      _isUIVisible = !_isUIVisible;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleReadingDirection() {
    setState(() {
      _isRightToLeft = !_isRightToLeft;
      if (!_isVerticalReading) {
        _pageController.jumpToPage(_getPageCount(context) - _currentPage - 1);
      }
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();
    _saveReaderSettings();
  }

  void _toggleReadingOrientation() {
    setState(() {
      _isVerticalReading = !_isVerticalReading;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();
    _saveReaderSettings();
  }

  void _resetZoom(TransformationController controller) {
    final animation =
        Tween<double>(begin: controller.value.getMaxScaleOnAxis(), end: 1.0)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeOutExpo));

    _animationController.reset();
    animation.addListener(() {
      controller.value = Matrix4.identity()..scale(animation.value);
    });
    _animationController.forward();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _startAutoScrollTimerIfEnabled() {
    if (_isAutoScroll && _isVerticalReading) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_isAutoScroll && _verticalScrollController.hasClients) {
          final maxScrollExtent =
              _verticalScrollController.position.maxScrollExtent;
          const duration = Duration(minutes: 20); // Adjust based on speed

          _verticalScrollController.animateTo(
            maxScrollExtent,
            duration: duration ~/ _autoScrollSpeed.toInt(),
            curve: Curves.linear,
          );
        }
      });
    }
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScroll = !_isAutoScroll;
      if (_isAutoScroll && _isVerticalReading) {
        _startAutoScrollTimerIfEnabled();
      } else if (!_isAutoScroll && _verticalScrollController.hasClients) {
        _verticalScrollController.jumpTo(_verticalScrollController.offset);
      }
    });
  }

  void _adjustBrightness(double value) {
    setState(() {
      _brightness = value;
    });
    _saveReaderSettings();
  }

  void _setAutoScrollSpeed(double value) {
    setState(() {
      _autoScrollSpeed = value;
    });

    if (_isAutoScroll && _isVerticalReading) {
      _verticalScrollController.jumpTo(_verticalScrollController.offset);
      _startAutoScrollTimerIfEnabled();
    }

    _saveReaderSettings();
  }

  void _setPageMargin(double value) {
    setState(() {
      _pageMargin = value;
    });
    _saveReaderSettings();
  }

  void _setPageBackgroundColor(Color color) {
    setState(() {
      _pageBackgroundColor = color;
    });
    _saveReaderSettings();
  }

  int _getPageCount(BuildContext context) {
    final provider = context.read<MangaDetailProvider>();
    return provider.chapterDetail != null
        ? (json.decode(provider.chapterDetail!.chapterImages) as List).length
        : 0;
  }

  void _goToPage(int page) {
    if (!_isVerticalReading) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      // For vertical reading, we'd need to calculate the offset
      // This is a simplified version
      final scrollPercentage = page / _getPageCount(context);
      final targetOffset =
          _verticalScrollController.position.maxScrollExtent * scrollPercentage;

      _verticalScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _shareCurrentPage() {
    // In a real app, this would use a sharing plugin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing page...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _bookmarkCurrentPage() {
    final pageCount = _getPageCount(context);
    final progress = pageCount > 0 ? (_currentPage + 1) / pageCount * 100 : 0;

    // In a real app, this would save to shared preferences or a database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Page ${_currentPage + 1} bookmarked (${progress.toStringAsFixed(0)}%)'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Open bookmarks view
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _pageBackgroundColor,
      body: GestureDetector(
        // onTap: _toggleUI,
        onDoubleTap: () {}, // Prevent double tap from accidentally toggling UI
        child: Consumer<MangaDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomLoadingIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading chapter...',
                      style: TextStyle(color: Colors.red.withOpacity(0.7)),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),
              );
            }

            if (provider.chapterDetail == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load chapter',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      onPressed: () {
                        context
                            .read<MangaDetailProvider>()
                            .loadChapterDetails(widget.item);
                      },
                    ),
                  ],
                ).animate().fade(duration: 400.ms),
              );
            }

            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Stack(
                children: [
                  // Brightness overlay
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(1 - _brightness),
                    ),
                  ),

                  // Main reader area
                  Positioned.fill(
                    child: _isVerticalReading
                        ? _buildVerticalReader(provider)
                        : _buildHorizontalReader(provider),
                  ),

                  // UI overlay (controls, info, etc.)
                  AnimatedOpacity(
                    opacity: _isUIVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _isUIVisible ? _buildUIOverlay(provider) : null,
                  ),

                  // Page turn indicators (only visible when UI is hidden)
                  if (!_isUIVisible && !_isVerticalReading)
                    _buildPageTurnIndicators(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageTurnIndicators() {
    return Row(
      children: [
        // Left side tap area indicator
        GestureDetector(
          onTap: () {
            _isRightToLeft
                ? _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  )
                : _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
          },
          child: Container(
            width: 50,
            color: Colors.transparent,
            child: Center(
              child: AnimatedOpacity(
                opacity: 0.4,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isRightToLeft
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        // Right side tap area indicator
        GestureDetector(
          onTap: () {
            _isRightToLeft
                ? _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  )
                : _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
          },
          child: Container(
            width: 50,
            color: Colors.transparent,
            child: Center(
              child: AnimatedOpacity(
                opacity: 0.4,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isRightToLeft
                      ? Icons.arrow_back_ios
                      : Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalReader(MangaDetailProvider provider) {
    final pages = List.from(json.decode(provider.chapterDetail!.chapterImages));
    return PageView.builder(
      controller: _pageController,
      // reverse: _isRightToLeft,
      physics: const BouncingScrollPhysics(),
      itemCount: pages.length,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
        HapticFeedback.selectionClick();
      },
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: _pageMargin),
          child: GestureDetector(
            // onDoubleTap: () => _resetZoom(controller),
            child: Hero(
              tag: 'manga_page_${pages[index]['image']}',
              child: CustomImageWidget(
                imagePath: pages[index]['image'],
                fit: BoxFit.contain,
                // loadingBuilder: (context, child, loadingProgress) {
                //   if (loadingProgress == null) return child;
                //   return Center(
                //     child: CircularProgressIndicator(
                //       value: loadingProgress.expectedTotalBytes != null
                //           ? loadingProgress.cumulativeBytesLoaded /
                //               loadingProgress.expectedTotalBytes!
                //           : null,
                //       strokeWidth: 2,
                //       color: Colors.blue,
                //     ),
                //   );
                // },
                // errorBuilder: (context, error, stackTrace) {
                //   return Center(
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                //         const SizedBox(height: 16),
                //         Text('Failed to load image',
                //             style: TextStyle(color: Colors.grey[400])),
                //         TextButton.icon(
                //           icon: const Icon(Icons.refresh),
                //           label: const Text('Retry'),
                //           onPressed: () {
                //             setState(() {}); // Force rebuild
                //           },
                //         ),
                //       ],
                //     ),
                //   );
                // },
              ),
            ),
          ),
        ).animate().fadeIn(duration: 200.ms);
      },
    );
  }

  Widget _buildVerticalReader(MangaDetailProvider provider) {
    final pages = List.from(json.decode(provider.chapterDetail!.chapterImages));
    return ListView.builder(
      controller: _verticalScrollController,
      physics: _isAutoScroll
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        // final controller = TransformationController();
        final effectiveIndex = index;
        final imagePath = pages[effectiveIndex]['image'];

        return Container(
          child: Column(
            children: [
              // Optional page number indicator
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 4),
              //   child: Text(
              //     'Page ${effectiveIndex + 1}',
              //     style: TextStyle(
              //       color: Colors.grey[400],
              //       fontSize: 12,
              //     ),
              //   ),
              // ),

              // Image
              GestureDetector(
                // onDoubleTap: () => _resetZoom(controller),
                child: CustomImageWidget(
                  imagePath: imagePath,
                  fit: BoxFit.fitWidth,
                  borderRadius: BorderRadius.zero,
                  // loadingBuilder: (context, child, loadingProgress) {
                  //   if (loadingProgress == null) return child;
                  //   return SizedBox(
                  //     height: MediaQuery.of(context).size.width * 1.5, // Aspect ratio placeholder
                  //     child: Center(
                  //       child: CircularProgressIndicator(
                  //         value: loadingProgress.expectedTotalBytes != null
                  //             ? loadingProgress.cumulativeBytesLoaded /
                  //                 loadingProgress.expectedTotalBytes!
                  //             : null,
                  //         strokeWidth: 2,
                  //         color: Colors.blue,
                  //       ),
                  //     ),
                  //   );
                  // },
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
            duration: 300.ms,
            delay: Duration(milliseconds: (50 * index % 3).toInt()));
      },
    );
  }

  Widget _buildUIOverlay(MangaDetailProvider provider) {
    final pageCount = _getPageCount(context);
    return Stack(
      children: [
        // Top bar with gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back',
                      ),

                      // Title
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                provider.chapterDetail!.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.item.title != null)
                                Text(
                                  widget.item.title!,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Settings button
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => _showSettingsBottomSheet(context),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom bar with controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page slider
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _goToPage(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentPage + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Colors.blue[300],
                                inactiveTrackColor: Colors.grey[800],
                                thumbColor: Colors.blue,
                                overlayColor: Colors.blue.withOpacity(0.3),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _currentPage.toDouble(),
                                min: 0,
                                max: pageCount > 0
                                    ? (pageCount - 1).toDouble()
                                    : 1,
                                divisions: pageCount > 0 ? pageCount - 1 : 1,
                                onChanged: _isVerticalReading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _currentPage = value.toInt();
                                          _pageController
                                              .jumpToPage(_currentPage);
                                        });
                                      },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _goToPage(pageCount - 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$pageCount',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Reading direction
                          IconButton(
                            icon: Icon(
                              _isRightToLeft
                                  ? Icons.format_textdirection_r_to_l
                                  : Icons.format_textdirection_l_to_r,
                              color: Colors.white,
                            ),
                            onPressed: _toggleReadingDirection,
                            tooltip: _isRightToLeft
                                ? 'Right to Left'
                                : 'Left to Right',
                          ),

                          // Previous page
                          IconButton(
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.white),
                            onPressed: () {
                              _isRightToLeft
                                  ? _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                    )
                                  : _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                    );
                            },
                            tooltip: 'Previous Page',
                          ),

                          // Bookmark
                          IconButton(
                            icon: const Icon(Icons.bookmark_border,
                                color: Colors.white),
                            onPressed: _bookmarkCurrentPage,
                            tooltip: 'Bookmark Page',
                          ),

                          // Next page
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white),
                            onPressed: () {
                              _isRightToLeft
                                  ? _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                    )
                                  : _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                    );
                            },
                            tooltip: 'Next Page',
                          ),

                          // Reading mode
                          IconButton(
                            icon: Icon(
                              _isVerticalReading
                                  ? Icons.view_day
                                  : Icons.view_carousel,
                              color: Colors.white,
                            ),
                            onPressed: _toggleReadingOrientation,
                            tooltip: _isVerticalReading
                                ? 'Vertical Mode'
                                : 'Paged Mode',
                          ),
                        ],
                      ),

                      // Additional controls for vertical reading
                      if (_isVerticalReading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Auto-scroll toggle
                              IconButton(
                                icon: Icon(
                                  _isAutoScroll
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: _isAutoScroll
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                                onPressed: _toggleAutoScroll,
                                tooltip: _isAutoScroll
                                    ? 'Pause Auto-scroll'
                                    : 'Auto-scroll',
                              ),

                              // Auto-scroll speed
                              if (_isAutoScroll)
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: Colors.blue[300],
                                      inactiveTrackColor: Colors.grey[800],
                                      thumbColor: Colors.blue,
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6),
                                    ),
                                    child: Slider(
                                      value: _autoScrollSpeed,
                                      min: 0.5,
                                      max: 3.0,
                                      divisions: 5,
                                      onChanged: _setAutoScrollSpeed,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Chapter navigation controls (left edge)
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 80,
          left: 0,
          child: AnimatedOpacity(
            opacity: 0.8,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      // In a real app, this would navigate to previous chapter
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Previous chapter'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    tooltip: 'Previous Chapter',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Chapter navigation controls (right edge)
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 80,
          right: 0,
          child: AnimatedOpacity(
            opacity: 0.8,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      // In a real app, this would navigate to next chapter
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Next chapter'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    tooltip: 'Next Chapter',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Quick actions floating button (mid-right)
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.blue.withOpacity(0.7),
            onPressed: () => _showQuickActionsSheet(context),
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Quick actions grid
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickActionItem(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      Navigator.pop(context);
                      _shareCurrentPage();
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.fullscreen,
                    label: 'Fullscreen',
                    onTap: () {
                      Navigator.pop(context);
                      _toggleFullscreen();
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.bookmark_add,
                    label: 'Bookmark',
                    onTap: () {
                      Navigator.pop(context);
                      _bookmarkCurrentPage();
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.settings_brightness,
                    label: 'Brightness',
                    onTap: () {
                      Navigator.pop(context);
                      _showBrightnessSlider(context);
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.info_outline,
                    label: 'Chapter Info',
                    onTap: () {
                      Navigator.pop(context);
                      _showChapterInfoDialog(context);
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.comment,
                    label: 'Comments',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comments feature coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showBrightnessSlider(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Screen Brightness',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.brightness_low, color: Colors.grey),
                    Expanded(
                      child: Slider(
                        value: _brightness,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (value) {
                          setDialogState(() {
                            _adjustBrightness(value);
                          });
                        },
                      ),
                    ),
                    const Icon(Icons.brightness_high, color: Colors.white),
                  ],
                ),
                Text(
                  '${(_brightness * 100).toInt()}%',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('DONE', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterInfoDialog(BuildContext context) {
    final provider = context.read<MangaDetailProvider>();
    if (provider.chapterDetail == null) return;

    final pageCount = _getPageCount(context);
    final progress = pageCount > 0 ? (_currentPage + 1) / pageCount * 100 : 0;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            provider.chapterDetail!.title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Series', widget.item.title ?? 'Unknown'),
              _infoRow(
                  'Chapter', provider.chapterDetail!.chapterCount ?? 'N/A'),
              _infoRow('Pages', pageCount.toString()),
              _infoRow('Progress', '${progress.toStringAsFixed(1)}%'),
              _infoRow('Current Page', '${_currentPage + 1} of $pageCount'),
              // if (provider.chapterDetail!.uploadDate != null)
              //   _infoRow('Released', provider.chapterDetail!.uploadDate!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label + ':',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Settings content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Reading Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Reading Direction
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reading Direction',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(value: false, label: Text('L→R')),
                                ButtonSegment(value: true, label: Text('R→L')),
                              ],
                              selected: {_isRightToLeft},
                              onSelectionChanged: (newSelection) {
                                setModalState(() => setState(
                                    () => _isRightToLeft = newSelection.first));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Reading Mode
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reading Mode',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                    value: false,
                                    label: Text('Paged'),
                                    icon: Icon(Icons.view_carousel)),
                                ButtonSegment(
                                    value: true,
                                    label: Text('Vertical'),
                                    icon: Icon(Icons.view_day)),
                              ],
                              selected: {_isVerticalReading},
                              onSelectionChanged: (newSelection) {
                                setModalState(() => setState(() =>
                                    _isVerticalReading = newSelection.first));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Page Background Color
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Page Background',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _colorOption(
                                    Colors.black, 'Black', setModalState),
                                _colorOption(Colors.grey[900]!, 'Dark Grey',
                                    setModalState),
                                _colorOption(
                                    Colors.grey[800]!, 'Grey', setModalState),
                                _colorOption(const Color(0xFF1A1A2E), 'Navy',
                                    setModalState),
                                _colorOption(const Color(0xFF2D2D2D),
                                    'Charcoal', setModalState),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Page Margins
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Page Margins',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  '${_pageMargin.toInt()} px',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Colors.blue[300],
                                inactiveTrackColor: Colors.grey[800],
                                thumbColor: Colors.blue,
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _pageMargin,
                                min: 0,
                                max: 40,
                                divisions: 8,
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      _pageMargin = value;
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Auto-scroll (for vertical mode)
                        if (_isVerticalReading)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Auto-scroll Speed',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Switch(
                                    value: _isAutoScroll,
                                    onChanged: (value) {
                                      setModalState(() {
                                        setState(() {
                                          _isAutoScroll = value;
                                          if (_isAutoScroll) {
                                            _startAutoScrollTimerIfEnabled();
                                          }
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_isAutoScroll) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.speed,
                                        color: Colors.grey, size: 20),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: Colors.blue[300],
                                          inactiveTrackColor: Colors.grey[800],
                                          thumbColor: Colors.blue,
                                          trackHeight: 4,
                                        ),
                                        child: Slider(
                                          value: _autoScrollSpeed,
                                          min: 0.5,
                                          max: 3.0,
                                          divisions: 5,
                                          onChanged: (value) {
                                            setModalState(() {
                                              _setAutoScrollSpeed(value);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.speed,
                                        color: Colors.white, size: 20),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        const SizedBox(height: 32),

                        // Theme Settings
                        const Text(
                          'Display Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Brightness
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Brightness',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.brightness_low,
                                    color: Colors.grey),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: Colors.blue[300],
                                      inactiveTrackColor: Colors.grey[800],
                                      thumbColor: Colors.blue,
                                      trackHeight: 4,
                                    ),
                                    child: Slider(
                                      value: _brightness,
                                      min: 0.1,
                                      max: 1.0,
                                      divisions: 9,
                                      onChanged: (value) {
                                        setModalState(() {
                                          _adjustBrightness(value);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const Icon(Icons.brightness_high,
                                    color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Advanced Settings
                        const Text(
                          'Advanced Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Keep Screen On
                        SwitchListTile(
                          title: const Text(
                            'Keep Screen On',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Prevent device from sleeping while reading',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12),
                          ),
                          value:
                              true, // This would be a state variable in a real app
                          onChanged: (value) {
                            // In a real app, this would use a plugin to keep the screen on
                            setModalState(() {
                              // setState(() => _keepScreenOn = value);
                            });
                          },
                          activeColor: Colors.blue,
                        ),

                        SwitchListTile(
                          title: const Text(
                            'Volume Button Navigation',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Use volume buttons to navigate between pages',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12),
                          ),
                          value:
                              false, // This would be a state variable in a real app
                          onChanged: (value) {
                            setModalState(() {
                              // setState(() => _volumeButtonNavigation = value);
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ],
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

  Widget _colorOption(Color color, String label, StateSetter setModalState) {
    final isSelected = _pageBackgroundColor.value == color.value;

    return InkWell(
      onTap: () {
        setModalState(() {
          setState(() {
            _setPageBackgroundColor(color);
          });
        });
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
