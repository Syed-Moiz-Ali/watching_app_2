// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/manga_reader_screen.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/widgets/chapter_tile.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/widgets/status_chip.dart';
import 'package:watching_app_2/presentation/provider/manga_detail_provider.dart';
import '../../../../../shared/widgets/misc/text_widget.dart';

class MangaDetailScreen extends StatefulWidget {
  final ContentItem item;

  const MangaDetailScreen({super.key, required this.item});

  @override
  _MangaDetailScreenState createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen>
    with TickerProviderStateMixin {
  // Constants
  static const double _appBarHeight = 350.0;
  static const double _scrollThreshold = 200.0;
  static const EdgeInsets _contentPadding = EdgeInsets.all(20.0);
  static const double _sectionSpacing = 16.0;
  static const double _sectionSpacingLarge = 24.0;
  static const double _chipSpacing = 8.0;
  static const double _buttonSpacing = 12.0;
  static const double _statSpacing = 12.0;
  static const double _textSpacing = 8.0;
  static const EdgeInsets _buttonMargin = EdgeInsets.all(8.0);
  static const Duration _fadeAnimationDuration = Duration(milliseconds: 800);
  static const Duration _crossFadeDuration = Duration(milliseconds: 300);
  static const Duration _pulseAnimationDuration = Duration(milliseconds: 1200);

  // Animation Controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers and State
  late ScrollController _scrollController;
  late PageController _pageController;
  bool _isScrolled = false;
  bool _showDescription = false;
  bool _isFavorite = false;
  bool _showAllChapters = false;
  String _sortOrder = 'Latest';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
    _loadDetails();
  }

  void _initializeAnimations() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _fadeAnimationController = AnimationController(
      duration: _fadeAnimationDuration,
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: _pulseAnimationDuration,
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fadeAnimationController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
          parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _pageController = PageController();
  }

  void _loadDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var provider = context.read<MangaDetailProvider>();
      await provider.loadMangaDetails(widget.item);
      _fadeAnimationController.forward();
      _slideAnimationController.forward();
      _pulseAnimationController.repeat(reverse: true);
    });
  }

  void _onScroll() {
    if (_scrollController.offset > _scrollThreshold && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= _scrollThreshold && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _slideAnimationController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<MangaDetailProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          if (provider.isLoading == true) {
            return _buildLoadingState();
          }

          final details = provider.mangaDetail!;

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildEnhancedAppBar(),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildHeroSection(details),
                        _buildContentSections(details),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEnhancedAppBar() {
    return SliverAppBar(
      expandedHeight: _appBarHeight,
      pinned: true,
      elevation: 0,
      backgroundColor:
          _isScrolled ? Colors.white.withOpacity(0.95) : Colors.transparent,
      leading: _buildGlassButton(
        Icons.arrow_back_ios_new,
        () => Navigator.pop(context),
      ),
      actions: [
        _buildGlassButton(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          () => setState(() => _isFavorite = !_isFavorite),
          color: _isFavorite ? Colors.red : null,
        ),
        _buildGlassButton(Icons.share, _showShareBottomSheet),
        _buildGlassButton(Icons.more_vert, _showMoreOptions),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildParallaxBackground(),
            _buildGradientOverlay(),
            _buildFloatingInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxBackground() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  SMA.formatImage(
                    image: widget.item.thumbnailUrl,
                    baseUrl: widget.item.source.url,
                  ),
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildFloatingInfo() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            // backdropFilter: null, // Note: BackdropFilter would be used here in real app
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  SMA.formatImage(
                    image: widget.item.thumbnailUrl,
                    baseUrl: widget.item.source.url,
                  ),
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
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
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      maxLine: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        TextWidget(
                          text: '4.8 • 2.1M reads',
                          fontSize: 12.sp,
                          color: Colors.white70,
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
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onPressed,
      {Color? color}) {
    return Container(
      margin: _buttonMargin,
      decoration: BoxDecoration(
        color: (_isScrolled
            ? Colors.black.withOpacity(0.05)
            : Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isScrolled
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: color ?? (_isScrolled ? Colors.black87 : Colors.white),
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHeroSection(ContentItem details) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndStatus(details),
          const SizedBox(height: _sectionSpacing),
          _buildEnhancedStats(details),
          const SizedBox(height: _sectionSpacing),
          _buildGenres(details),
          const SizedBox(height: _sectionSpacingLarge),
          _buildEnhancedActionButtons(details),
        ],
      ),
    );
  }

  Widget _buildContentSections(ContentItem details) {
    return Column(
      children: [
        _buildDescription(details),
        const SizedBox(height: _sectionSpacing),
        _buildReadingProgress(),
        const SizedBox(height: _sectionSpacing),
        _buildChaptersSection(details),
        const SizedBox(height: 100), // Bottom padding for FAB
      ],
    );
  }

  Widget _buildTitleAndStatus(ContentItem details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: widget.item.title,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                maxLine: 2,
              ),
              if (widget.item.source.name.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextWidget(
                    text: widget.item.source.name,
                    fontSize: 11.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: _chipSpacing),
        StatusChip(status: details.detailContent!.status!),
      ],
    );
  }

  Widget _buildEnhancedStats(ContentItem details) {
    final stats = [
      {
        'label': 'Chapters',
        'value': '${details.detailContent!.chapter!.length}',
        'icon': Icons.menu_book_outlined,
        'color': Colors.blue,
      },
      {
        'label': 'Rating',
        'value': '4.8',
        'icon': Icons.star_outline,
        'color': Colors.amber,
      },
      {
        'label': 'Views',
        'value': '2.1M',
        'icon': Icons.visibility_outlined,
        'color': Colors.green,
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: stat == stats.last ? 0 : _statSpacing,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (stat['color'] as Color).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                  size: 24,
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: stat['value'] as String,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
                TextWidget(
                  text: stat['label'] as String,
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenres(ContentItem details) {
    if (details.detailContent!.genre == null) return const SizedBox.shrink();

    return Wrap(
      spacing: _chipSpacing,
      runSpacing: _chipSpacing,
      children: details.detailContent!.genre!
          .split(', ')
          .take(6)
          .map((genre) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.1),
                      Colors.blue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: TextWidget(
                  text: genre.trim(),
                  fontSize: 11.sp,
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildEnhancedActionButtons(ContentItem details) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                if (details.detailContent!.chapter!.isNotEmpty) {
                  NH.navigateTo(MangaReaderScreen(
                    item: widget.item,
                    chapter: details.detailContent!.chapter!.first,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const TextWidget(
                text: 'Read Now',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: _buttonSpacing),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: Icon(Icons.download_outlined, color: Colors.grey.shade700),
              label: TextWidget(
                text: 'Download',
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ContentItem details) {
    if (details.detailContent!.discription == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextWidget(
                text: 'Synopsis',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showDescription = !_showDescription),
                icon: Icon(
                  _showDescription ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: TextWidget(
                  text: _showDescription ? 'Show Less' : 'Show More',
                  fontSize: 13.sp,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: _textSpacing),
          AnimatedCrossFade(
            firstChild: TextWidget(
              text: details.detailContent!.discription!,
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              // height: 1.5,
              maxLine: 3,
            ),
            secondChild: TextWidget(
              text: details.detailContent!.discription!,
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              // height: 1.5,
            ),
            crossFadeState: _showDescription
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: _crossFadeDuration,
          ),
        ],
      ),
    );
  }

  Widget _buildReadingProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bookmark, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(
                  text: 'Continue Reading',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
                const SizedBox(height: 4),
                TextWidget(
                  text: 'Chapter 45 • 67% completed',
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.67,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersSection(ContentItem details) {
    final chaptersToShow = _showAllChapters
        ? details.detailContent!.chapter!.length
        : (details.detailContent!.chapter!.length > 10
            ? 10
            : details.detailContent!.chapter!.length);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextWidget(
                text: 'Chapters',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              PopupMenuButton<String>(
                initialValue: _sortOrder,
                onSelected: (value) => setState(() => _sortOrder = value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'Latest', child: TextWidget(text: 'Latest First')),
                  const PopupMenuItem(
                      value: 'Oldest', child: TextWidget(text: 'Oldest First')),
                  const PopupMenuItem(
                      value: 'A-Z', child: TextWidget(text: 'A-Z')),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: _sortOrder,
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _textSpacing),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chaptersToShow,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ChapterTile(
                  item: widget.item, details: details, index: index),
            ),
          ),
          if (details.detailContent!.chapter!.length > 10) ...[
            const SizedBox(height: _textSpacing),
            Center(
              child: TextButton(
                onPressed: () =>
                    setState(() => _showAllChapters = !_showAllChapters),
                child: TextWidget(
                  text: _showAllChapters
                      ? 'Show Less'
                      : 'View All ${details.detailContent!.chapter!.length} Chapters',
                  fontSize: 14.sp,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Quick action - maybe jump to latest chapter
      },
      backgroundColor: AppColors.primaryColor,
      elevation: 8,
      label: const TextWidget(
        text: 'Read',
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      icon: const Icon(Icons.flash_on, color: Colors.white),
    );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const TextWidget(
              text: 'Share Manga',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.link, 'Copy Link'),
                _buildShareOption(Icons.message, 'Message'),
                _buildShareOption(Icons.share, 'More'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        TextWidget(
          text: label,
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const TextWidget(
              text: 'More Options',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.bookmark_add_outlined,
              title: 'Add to Library',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionTile(
              icon: Icons.download_outlined,
              title: 'Download All',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionTile(
              icon: Icons.report_outlined,
              title: 'Report Issue',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 20),
      ),
      title: TextWidget(
        text: title,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _appBarHeight,
            pinned: true,
            backgroundColor: Colors.white.withOpacity(0.95),
            leading: _buildGlassButton(
              Icons.arrow_back_ios_new,
              () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: _contentPadding,
              child: Column(
                children: [
                  _buildLoadingCard(),
                  const SizedBox(height: _sectionSpacing),
                  _buildLoadingCard(),
                  const SizedBox(height: _sectionSpacing),
                  _buildLoadingCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 16,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(MangaDetailProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextWidget(
          text: 'Error',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      body: Center(
        child: Container(
          margin: _contentPadding,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              const TextWidget(
                text: 'Something went wrong',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: provider.error ?? 'Unknown error occurred',
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.loadMangaDetails(widget.item);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const TextWidget(
                    text: 'Try Again',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
