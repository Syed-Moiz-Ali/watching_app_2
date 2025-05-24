import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/constants/manga_reader_constants.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/widgets/control_button.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/widgets/control_hub.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/widgets/page_turn_indicator.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/widgets/quick_action_item.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/widgets/settings_tile.dart';
import 'package:watching_app_2/presentation/provider/manga_detail_provider.dart';

import '../../../../../core/constants/colors.dart';

class MangaReaderScreen extends StatefulWidget {
  final ContentItem item;
  final Chapter chapter;

  const MangaReaderScreen(
      {super.key, required this.item, required this.chapter});

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  final ScrollController _verticalScrollController = ScrollController();
  final DateTime _startReadingTime = DateTime.now();
  int _currentPage = 0;
  bool _isUIVisible = true;
  bool _isVerticalReading = true;
  bool _isRightToLeft = false;
  bool _isFullscreen = false;
  double _brightness = 1.0;
  bool _isAutoScroll = false;
  double _autoScrollSpeed = 1.0;
  double _pageMargin = 0.0;
  bool _isLightTheme = false;
  bool _isOffline = false;
  String _themeMode = MangaReaderConstants.nightTheme;
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: MangaReaderConstants.animationDuration,
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        MangaReaderConstants.allowedOrientations);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MangaDetailProvider>()
          .loadChapterDetails(widget.item, widget.chapter);
      _loadReaderSettings();
      _startAutoScrollTimerIfEnabled();
      _fetchRecommendations();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _verticalScrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _saveReadingProgress();
    super.dispose();
  }

  Future<void> _loadReaderSettings() async {
    setState(() {
      _isRightToLeft = true;
      _isVerticalReading = false;
      _brightness = 1.0;
      _pageMargin = 0.0;
      _themeMode = MangaReaderConstants.nightTheme;
    });
  }

  Future<void> _saveReaderSettings() async {
    // Placeholder for saving to shared preferences
  }

  Future<void> _saveReadingProgress() async {
    final readDuration = DateTime.now().difference(_startReadingTime);
    final pageCount = _getPageCount(context);
    final readPercentage =
        pageCount > 0 ? (_currentPage + 1) / pageCount * 100 : 0;

    if (kDebugMode) {
      print('Reading session stats:');
      print('- Duration: ${readDuration.inMinutes} minutes');
      print('- Progress: ${readPercentage.toStringAsFixed(1)}%');
      print('- Last page: ${_currentPage + 1} of $pageCount');
    }
  }

  void _fetchRecommendations() {
    if (kDebugMode) {
      print('Fetching manga recommendations for ${widget.item.title}');
    }
  }

  void _toggleUI() {
    setState(() => _isUIVisible = !_isUIVisible);
    HapticFeedback.lightImpact();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    SystemChrome.setEnabledSystemUIMode(
      _isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void _toggleReadingDirection() {
    setState(() {
      _isRightToLeft = !_isRightToLeft;
      if (!_isVerticalReading) {
        _pageController.jumpToPage(_getPageCount(context) - _currentPage - 1);
      }
    });
    HapticFeedback.mediumImpact();
    _saveReaderSettings();
  }

  void _toggleReadingOrientation() {
    setState(() => _isVerticalReading = !_isVerticalReading);
    HapticFeedback.mediumImpact();
    _saveReaderSettings();
  }

  void _toggleTheme() {
    setState(() {
      _isLightTheme = !_isLightTheme;
    });
    _saveReaderSettings();
  }

  void _setThemeMode(String mode) {
    setState(() => _themeMode = mode);
    _saveReaderSettings();
  }

  void _resetZoom(TransformationController controller) {
    final animation =
        Tween<double>(begin: controller.value.getMaxScaleOnAxis(), end: 1.0)
            .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );
    _animationController.reset();
    animation.addListener(() {
      controller.value = Matrix4.identity()..scale(animation.value);
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _startAutoScrollTimerIfEnabled() {
    if (_isAutoScroll &&
        _isVerticalReading &&
        _verticalScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_isAutoScroll) {
          final maxScrollExtent =
              _verticalScrollController.position.maxScrollExtent;
          _verticalScrollController.animateTo(
            maxScrollExtent,
            duration: Duration(seconds: (15 / _autoScrollSpeed).toInt()),
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
    setState(() => _brightness = value);
    _saveReaderSettings();
  }

  void _setAutoScrollSpeed(double value) {
    setState(() => _autoScrollSpeed = value);
    if (_isAutoScroll && _isVerticalReading) {
      _verticalScrollController.jumpTo(_verticalScrollController.offset);
      _startAutoScrollTimerIfEnabled();
    }
    _saveReaderSettings();
  }

  void _setPageMargin(double value) {
    setState(() => _pageMargin = value);
    _saveReaderSettings();
  }

  void _toggleOfflineMode() {
    setState(() => _isOffline = !_isOffline);
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Downloading chapter for offline reading...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  void _addNote(String note) {
    setState(() => _notes.add('Page ${_currentPage + 1}: $note'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note added for page ${_currentPage + 1}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  int _getPageCount(BuildContext context) {
    final provider = context.read<MangaDetailProvider>();
    return provider.chapterDetail?.length ?? 0;
  }

  void _goToPage(int page) {
    if (!_isVerticalReading) {
      _pageController.animateToPage(
        page,
        duration: MangaReaderConstants.pageTransitionDuration,
        curve: Curves.easeInOutCubic,
      );
    } else {
      final scrollPercentage = page / _getPageCount(context);
      final targetOffset =
          _verticalScrollController.position.maxScrollExtent * scrollPercentage;
      _verticalScrollController.animateTo(
        targetOffset,
        duration: MangaReaderConstants.scrollTransitionDuration,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _shareCurrentPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing page with custom overlay...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _bookmarkCurrentPage() {
    final pageCount = _getPageCount(context);
    final progress = pageCount > 0 ? (_currentPage + 1) / pageCount * 100 : 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Page ${_currentPage + 1} bookmarked (${progress.toStringAsFixed(0)}%)'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryColor,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleUI,
        onDoubleTap: () {},
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Previous chapter'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primaryColor,
              ),
            );
          } else if (details.primaryVelocity! < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Next chapter'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primaryColor,
              ),
            );
          }
        },
        child: Stack(
          children: [
            if (_themeMode == MangaReaderConstants.nightTheme)
              Positioned.fill(child: _buildNightBackground()),
            Positioned.fill(child: _buildBrightnessOverlay()),
            Positioned.fill(child: _buildReader(context)),
            if (_isUIVisible) _buildUIOverlay(context),
            if (!_isUIVisible && !_isVerticalReading)
              PageTurnIndicator(
                  isRightToLeft: _isRightToLeft,
                  pageController: _pageController),
          ],
        ),
      ),
    );
  }

  Widget _buildNightBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundColorDark.withOpacity(0.8),
            AppColors.backgroundColorDark.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightnessOverlay() {
    return Container(color: Colors.black.withOpacity(1 - _brightness));
  }

  Widget _buildReader(BuildContext context) {
    return _isVerticalReading
        ? _buildVerticalReader(context)
        : _buildHorizontalReader(context);
  }

  Widget _buildHorizontalReader(BuildContext context) {
    final provider = context.watch<MangaDetailProvider>();
    return PageView.builder(
      controller: _pageController,
      reverse: _isRightToLeft,
      physics: const BouncingScrollPhysics(),
      itemCount: provider.chapterDetail?.length ?? 0,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
        HapticFeedback.selectionClick();
      },
      itemBuilder: (context, index) {
        final controller = TransformationController();
        return InteractiveViewer(
          transformationController: controller,
          maxScale: MangaReaderConstants.maxScale,
          minScale: MangaReaderConstants.minScale,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: _pageMargin),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(MangaReaderConstants.borderRadius),
              boxShadow: MangaReaderConstants.boxShadow,
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(MangaReaderConstants.borderRadius),
              child: CachedNetworkImage(
                imageUrl: provider.chapterDetail![index].chapterImage!,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: MangaReaderConstants.fadeDuration).scale(
            curve: Curves.easeOutBack,
            duration: MangaReaderConstants.animationDuration);
      },
    );
  }

  Widget _buildVerticalReader(BuildContext context) {
    final provider = context.watch<MangaDetailProvider>();
    return ListView.builder(
      controller: _verticalScrollController,
      physics: _isAutoScroll
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      cacheExtent: MediaQuery.of(context).size.height * 3,
      itemCount: provider.chapterDetail?.length ?? 0,
      itemBuilder: (context, index) {
        final controller = TransformationController();
        return InteractiveViewer(
          transformationController: controller,
          maxScale: MangaReaderConstants.maxScale,
          minScale: MangaReaderConstants.minScale,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: _pageMargin),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(MangaReaderConstants.borderRadius),
                  boxShadow: MangaReaderConstants.boxShadow,
                ),
                child: CachedNetworkImage(
                  imageUrl: provider.chapterDetail![index].chapterImage!,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => SizedBox(
                    height: MediaQuery.of(context).size.width * 1.5,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: MangaReaderConstants.fadeDuration).slideY(
            begin: 0.1,
            end: 0,
            duration: MangaReaderConstants.animationDuration);
      },
    );
  }

  Widget _buildUIOverlay(BuildContext context) {
    final provider = context.watch<MangaDetailProvider>();
    final pageCount = _getPageCount(context);
    return Stack(
      children: [
        _buildTopBar(context),
        _buildBottomBar(context, pageCount),
        Positioned(
          right: MangaReaderConstants.controlHubRightMargin,
          bottom: MangaReaderConstants.controlHubBottomMargin,
          child: ControlHub(onPressed: () => _showQuickActionsSheet(context)),
        ),
      ],
    ).animate().fadeIn(duration: MangaReaderConstants.fadeDuration);
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: MangaReaderConstants.topBarPadding,
            decoration: BoxDecoration(
              color: _isLightTheme
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.backgroundColorDark.withOpacity(0.3),
              borderRadius: MangaReaderConstants.topBarBorderRadius,
              border:
                  Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ControlButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                    color: _isLightTheme ? Colors.black87 : Colors.white,
                  ),
                  Expanded(child: _buildTitleSection()),
                  ControlButton(
                    icon: Icons.settings_outlined,
                    onPressed: () => _showSettingsBottomSheet(context),
                    tooltip: 'Settings',
                    color: _isLightTheme ? Colors.black87 : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: MangaReaderConstants.fadeDuration)
          .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.item.title ?? 'Manga Title',
          style: MangaReaderConstants.titleStyle
              .copyWith(color: _isLightTheme ? Colors.black87 : Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          widget.chapter.chapterName ?? 'Chapter',
          style: MangaReaderConstants.subtitleStyle.copyWith(
              color: _isLightTheme
                  ? Colors.black54
                  : AppColors.backgroundColorLight),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, int pageCount) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: MangaReaderConstants.bottomBarPadding,
            decoration: BoxDecoration(
              color: _isLightTheme
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.backgroundColorDark.withOpacity(0.3),
              borderRadius: MangaReaderConstants.bottomBarBorderRadius,
              border:
                  Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProgressBar(context, pageCount),
                  const SizedBox(height: MangaReaderConstants.spacing),
                  _buildControlButtons(),
                  if (_isVerticalReading) _buildAutoScrollControls(),
                ],
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: MangaReaderConstants.fadeDuration)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildProgressBar(BuildContext context, int pageCount) {
    return Row(
      children: [
        Text(
          '${_currentPage + 1}',
          style: MangaReaderConstants.pageNumberStyle
              .copyWith(color: _isLightTheme ? Colors.black87 : Colors.white),
        ),
        const SizedBox(width: MangaReaderConstants.spacing),
        Expanded(child: _buildProgressIndicator(context, pageCount)),
        const SizedBox(width: MangaReaderConstants.spacing),
        Text(
          '$pageCount',
          style: MangaReaderConstants.pageCountStyle.copyWith(
              color: _isLightTheme
                  ? Colors.black54
                  : AppColors.backgroundColorLight),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context, int pageCount) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: _isLightTheme ? Colors.grey[300] : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Container(
          height: 6,
          width: pageCount > 0
              ? MediaQuery.of(context).size.width *
                  0.8 *
                  (_currentPage + 1) /
                  pageCount
              : 0,
          decoration: BoxDecoration(
            gradient: MangaReaderConstants.progressGradient,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ControlButton(
          icon: _isRightToLeft
              ? Icons.arrow_back_ios_new
              : Icons.arrow_forward_ios,
          onPressed: _toggleReadingDirection,
          tooltip: _isRightToLeft ? 'Right to Left' : 'Left to Right',
          color: _isLightTheme ? Colors.black87 : Colors.white,
        ),
        ControlButton(
          icon: Icons.bookmark_border,
          onPressed: _bookmarkCurrentPage,
          tooltip: 'Bookmark Page',
          color: _isLightTheme ? Colors.black87 : Colors.white,
        ),
        ControlButton(
          icon: _isVerticalReading ? Icons.view_day : Icons.view_carousel,
          onPressed: _toggleReadingOrientation,
          tooltip: _isVerticalReading ? 'Vertical Mode' : 'Paged Mode',
          color: _isLightTheme ? Colors.black87 : Colors.white,
        ),
      ],
    );
  }

  Widget _buildAutoScrollControls() {
    return Padding(
      padding: const EdgeInsets.only(top: MangaReaderConstants.spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ControlButton(
            icon: _isAutoScroll ? Icons.pause : Icons.play_arrow,
            onPressed: _toggleAutoScroll,
            tooltip: _isAutoScroll ? 'Pause Auto-scroll' : 'Auto-scroll',
            isActive: _isAutoScroll,
            color: _isLightTheme ? Colors.black87 : Colors.white,
            activeColor: AppColors.primaryColor,
          ),
          if (_isAutoScroll)
            Expanded(
              child: SliderTheme(
                data: MangaReaderConstants.sliderTheme,
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
    );
  }

  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: MangaReaderConstants.sheetPadding,
          decoration: BoxDecoration(
            color: _isLightTheme
                ? Colors.white.withOpacity(0.9)
                : AppColors.backgroundColorDark.withOpacity(0.9),
            borderRadius: MangaReaderConstants.sheetBorderRadius,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: _isLightTheme ? Colors.grey[400] : Colors.grey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: MangaReaderConstants.spacing),
              Wrap(
                spacing: MangaReaderConstants.spacing,
                runSpacing: MangaReaderConstants.spacing,
                alignment: WrapAlignment.center,
                children: [
                  QuickActionItem(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: _shareCurrentPage,
                    isLightTheme: _isLightTheme,
                  ),
                  QuickActionItem(
                    icon: Icons.fullscreen,
                    label: 'Fullscreen',
                    onTap: _toggleFullscreen,
                    isLightTheme: _isLightTheme,
                  ),
                  QuickActionItem(
                    icon: Icons.brightness_6,
                    label: 'Brightness',
                    onTap: () => _showBrightnessSlider(context),
                    isLightTheme: _isLightTheme,
                  ),
                  QuickActionItem(
                    icon: Icons.info_outline,
                    label: 'Info',
                    onTap: () => _showChapterInfoDialog(context),
                    isLightTheme: _isLightTheme,
                  ),
                  QuickActionItem(
                    icon: Icons.download,
                    label: 'Offline',
                    onTap: _toggleOfflineMode,
                    isLightTheme: _isLightTheme,
                  ),
                  QuickActionItem(
                    icon: Icons.note_add,
                    label: 'Add Note',
                    onTap: () => _showNoteDialog(context),
                    isLightTheme: _isLightTheme,
                  ),
                ],
              ),
              const SizedBox(height: MangaReaderConstants.spacing),
            ],
          ),
        ),
      ),
    );
  }

  void _showBrightnessSlider(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: _isLightTheme
              ? Colors.white.withOpacity(0.9)
              : AppColors.backgroundColorDark.withOpacity(0.9),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(MangaReaderConstants.borderRadius)),
          content: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Screen Brightness',
                    style: MangaReaderConstants.dialogTitleStyle.copyWith(
                        color: _isLightTheme ? Colors.black87 : Colors.white)),
                const SizedBox(height: MangaReaderConstants.spacing),
                Row(
                  children: [
                    Icon(
                      Icons.brightness_low,
                      color: _isLightTheme
                          ? Colors.black54
                          : AppColors.backgroundColorLight,
                      size: 24,
                    ),
                    Expanded(
                      child: Slider(
                        value: _brightness,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (value) =>
                            setDialogState(() => _adjustBrightness(value)),
                        activeColor: AppColors.primaryColor,
                        inactiveColor: _isLightTheme
                            ? Colors.grey[300]
                            : AppColors.primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.brightness_high,
                      color: _isLightTheme ? Colors.black87 : Colors.white,
                      size: 24,
                    ),
                  ],
                ),
                Text(
                  '${(_brightness * 100).toInt()}%',
                  style: MangaReaderConstants.subtitleStyle.copyWith(
                      color: _isLightTheme
                          ? Colors.black54
                          : AppColors.backgroundColorLight),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('DONE', style: MangaReaderConstants.actionTextStyle),
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: _isLightTheme
              ? Colors.white.withOpacity(0.9)
              : AppColors.backgroundColorDark.withOpacity(0.9),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(MangaReaderConstants.borderRadius)),
          title: Text(
            widget.item.title ?? 'Manga Title',
            style: MangaReaderConstants.dialogTitleStyle
                .copyWith(color: _isLightTheme ? Colors.black87 : Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Series', widget.item.title ?? 'Unknown'),
                _buildInfoRow(
                    'Chapter', widget.chapter.chapterName ?? 'Unknown'),
                _buildInfoRow('Pages', pageCount.toString()),
                _buildInfoRow('Progress', '${progress.toStringAsFixed(1)}%'),
                _buildInfoRow(
                    'Current Page', '${_currentPage + 1} of $pageCount'),
                if (_notes.isNotEmpty) ...[
                  const SizedBox(height: MangaReaderConstants.spacing),
                  Text('Notes',
                      style: MangaReaderConstants.sectionTitleStyle.copyWith(
                          color:
                              _isLightTheme ? Colors.black87 : Colors.white)),
                  ..._notes.map((note) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(note,
                            style: MangaReaderConstants.subtitleStyle.copyWith(
                                color: _isLightTheme
                                    ? Colors.black54
                                    : AppColors.backgroundColorLight)),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CLOSE', style: MangaReaderConstants.actionTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: _isLightTheme
              ? Colors.white.withOpacity(0.9)
              : AppColors.backgroundColorDark.withOpacity(0.9),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(MangaReaderConstants.borderRadius)),
          title: Text('Add Note',
              style: MangaReaderConstants.dialogTitleStyle.copyWith(
                  color: _isLightTheme ? Colors.black87 : Colors.white)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your note...',
              hintStyle: MangaReaderConstants.subtitleStyle.copyWith(
                  color: _isLightTheme ? Colors.black54 : Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color:
                        _isLightTheme ? Colors.grey[300]! : Colors.grey[700]!),
              ),
            ),
            style: MangaReaderConstants.textStyle
                .copyWith(color: _isLightTheme ? Colors.black87 : Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('CANCEL', style: MangaReaderConstants.cancelTextStyle),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addNote(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text('SAVE', style: MangaReaderConstants.actionTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: MangaReaderConstants.subtitleStyle.copyWith(
                    color: _isLightTheme
                        ? Colors.black54
                        : AppColors.backgroundColorLight)),
          ),
          Expanded(
              child: Text(value,
                  style: MangaReaderConstants.textStyle.copyWith(
                      color: _isLightTheme ? Colors.black87 : Colors.white))),
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
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: _isLightTheme
                  ? Colors.white.withOpacity(0.9)
                  : AppColors.backgroundColorDark.withOpacity(0.9),
              borderRadius: MangaReaderConstants.sheetBorderRadius,
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _isLightTheme ? Colors.grey[400] : Colors.grey[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: MangaReaderConstants.sheetPadding,
                    children: [
                      Text('Reading Settings',
                          style: MangaReaderConstants.sectionTitleStyle
                              .copyWith(
                                  color: _isLightTheme
                                      ? Colors.black87
                                      : Colors.white)),
                      const SizedBox(height: MangaReaderConstants.spacing),
                      SettingsTile(
                        title: 'Reading Direction',
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('L→R')),
                            ButtonSegment(value: true, label: Text('R→L')),
                          ],
                          selected: {_isRightToLeft},
                          onSelectionChanged: (newSelection) {
                            setState(() => _isRightToLeft = newSelection.first);
                          },
                          style: MangaReaderConstants.segmentedButtonStyle
                              .copyWith(
                            backgroundColor: WidgetStatePropertyAll(
                                _isLightTheme
                                    ? Colors.grey[200]
                                    : AppColors.primaryColor),
                            foregroundColor: WidgetStatePropertyAll(
                                _isLightTheme ? Colors.black87 : Colors.white),
                          ),
                        ),
                      ),
                      SettingsTile(
                        title: 'Reading Mode',
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                                value: false,
                                label: Text('Paged'),
                                icon: Icon(Icons.view_carousel, size: 20)),
                            ButtonSegment(
                                value: true,
                                label: Text('Vertical'),
                                icon: Icon(Icons.view_day, size: 20)),
                          ],
                          selected: {_isVerticalReading},
                          onSelectionChanged: (newSelection) {
                            setState(
                                () => _isVerticalReading = newSelection.first);
                          },
                          style: MangaReaderConstants.segmentedButtonStyle
                              .copyWith(
                            backgroundColor: WidgetStatePropertyAll(
                                _isLightTheme
                                    ? Colors.grey[200]
                                    : AppColors.primaryColor),
                            foregroundColor: WidgetStatePropertyAll(
                                _isLightTheme ? Colors.black87 : Colors.white),
                          ),
                        ),
                      ),
                      SettingsTile(
                        title: 'Theme',
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'Night', label: Text('Night')),
                            ButtonSegment(
                                value: 'Sakura', label: Text('Sakura')),
                            ButtonSegment(value: 'Ocean', label: Text('Ocean')),
                          ],
                          selected: {_themeMode},
                          onSelectionChanged: (newSelection) {
                            _setThemeMode(newSelection.first);
                          },
                          style: MangaReaderConstants.segmentedButtonStyle
                              .copyWith(
                            backgroundColor: WidgetStatePropertyAll(
                                _isLightTheme
                                    ? Colors.grey[200]
                                    : AppColors.primaryColor),
                            foregroundColor: WidgetStatePropertyAll(
                                _isLightTheme ? Colors.black87 : Colors.white),
                          ),
                        ),
                      ),
                      SettingsTile(
                        title: 'Light Theme',
                        child: Switch(
                          value: _isLightTheme,
                          onChanged: (value) => _toggleTheme(),
                          activeColor: AppColors.primaryColor,
                          inactiveTrackColor: _isLightTheme
                              ? Colors.grey[300]
                              : AppColors.primaryColor,
                        ),
                      ),
                      SettingsTile(
                        title: 'Page Margins',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Slider(
                                value: _pageMargin,
                                min: 0,
                                max: 40,
                                divisions: 8,
                                onChanged: _setPageMargin,
                                activeColor: AppColors.primaryColor,
                                inactiveColor: _isLightTheme
                                    ? Colors.grey[300]
                                    : AppColors.primaryColor,
                              ),
                            ),
                            Text(
                              '${_pageMargin.toInt()} px',
                              style: MangaReaderConstants.subtitleStyle
                                  .copyWith(
                                      color: _isLightTheme
                                          ? Colors.black54
                                          : AppColors.backgroundColorLight),
                            ),
                          ],
                        ),
                      ),
                      SettingsTile(
                        title: 'Brightness',
                        child: Row(
                          children: [
                            Icon(
                              Icons.brightness_low,
                              color: _isLightTheme
                                  ? Colors.black54
                                  : AppColors.backgroundColorLight,
                              size: 24,
                            ),
                            Expanded(
                              child: Slider(
                                value: _brightness,
                                min: 0.1,
                                max: 1.0,
                                divisions: 9,
                                onChanged: _adjustBrightness,
                                activeColor: AppColors.primaryColor,
                                inactiveColor: _isLightTheme
                                    ? Colors.grey[300]
                                    : AppColors.primaryColor,
                              ),
                            ),
                            Icon(
                              Icons.brightness_high,
                              color:
                                  _isLightTheme ? Colors.black87 : Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      if (_isVerticalReading)
                        SettingsTile(
                          title: 'Auto-scroll',
                          child: Column(
                            children: [
                              Switch(
                                value: _isAutoScroll,
                                onChanged: (value) {
                                  setState(() {
                                    _isAutoScroll = value;
                                    if (_isAutoScroll) {
                                      _startAutoScrollTimerIfEnabled();
                                    }
                                  });
                                },
                                activeColor: AppColors.primaryColor,
                                inactiveTrackColor: _isLightTheme
                                    ? Colors.grey[300]
                                    : AppColors.primaryColor,
                              ),
                              if (_isAutoScroll)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.speed,
                                      color: _isLightTheme
                                          ? Colors.black54
                                          : AppColors.backgroundColorLight,
                                      size: 24,
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _autoScrollSpeed,
                                        min: 0.5,
                                        max: 3.0,
                                        divisions: 5,
                                        onChanged: _setAutoScrollSpeed,
                                        activeColor: AppColors.primaryColor,
                                        inactiveColor: _isLightTheme
                                            ? Colors.grey[300]
                                            : AppColors.greyColor,
                                      ),
                                    ),
                                    Icon(
                                      Icons.speed,
                                      color: _isLightTheme
                                          ? Colors.black87
                                          : Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      SettingsTile(
                        title: 'High Contrast Mode',
                        child: Switch(
                          value: false,
                          onChanged: (value) {},
                          activeColor: AppColors.primaryColor,
                          inactiveTrackColor: _isLightTheme
                              ? Colors.grey[300]
                              : AppColors.primaryColor,
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
    );
  }
}
