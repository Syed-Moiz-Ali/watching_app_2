import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_reader/manga_reader_screen.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/widgets/action_button.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/widgets/chapter_tile.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/widgets/genre_chip.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/widgets/stat_card.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/widgets/status_chip.dart';
import 'package:watching_app_2/features/manga/presentation/screens/manga_detail/constants/manga_detail_constants.dart';
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
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  bool _isScrolled = false;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        MangaDetailConstants.systemUiOverlayStyle);

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _fadeAnimationController = AnimationController(
      duration: MangaDetailConstants.fadeAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadDetails();
    _fadeAnimationController.forward();
  }

  void _loadDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var provider = context.read<MangaDetailProvider>();
      await provider.loadMangaDetails(widget.item);
    });
  }

  void _onScroll() {
    if (_scrollController.offset > MangaDetailConstants.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <=
            MangaDetailConstants.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<MangaDetailProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          if (provider.mangaDetail == null) {
            return _buildLoadingState();
          }

          final details = provider.mangaDetail!;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: MangaDetailConstants.contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleAndStatus(details),
                        const SizedBox(
                            height: MangaDetailConstants.sectionSpacing),
                        _buildStats(details),
                        const SizedBox(
                            height: MangaDetailConstants.sectionSpacing),
                        _buildGenres(details),
                        const SizedBox(
                            height: MangaDetailConstants.sectionSpacing),
                        _buildActionButtons(details),
                        const SizedBox(
                            height: MangaDetailConstants.sectionSpacingLarge),
                        _buildDescription(details),
                        const SizedBox(
                            height: MangaDetailConstants.sectionSpacingLarge),
                        _buildChaptersSection(details),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: MangaDetailConstants.appBarHeight,
      pinned: true,
      elevation: 0,
      backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
      leading: _buildAppBarButton(
          Icons.arrow_back_ios_new, () => Navigator.pop(context)),
      actions: [
        _buildAppBarButton(Icons.favorite_border, () {}),
        _buildAppBarButton(Icons.share, () {}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  SMA.formatImage(
                      image: widget.item.thumbnailUrl,
                      baseUrl: widget.item.source.url),
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: MangaDetailConstants.buttonMargin,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(_isScrolled ? 0 : 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon,
            color: _isScrolled ? Colors.black : Colors.white, size: 18),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTitleAndStatus(ContentItem details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextWidget(
            text: widget.item.title,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: MangaDetailConstants.chipSpacing),
        StatusChip(status: details.detailContent!.status!),
      ],
    );
  }

  Widget _buildStats(ContentItem details) {
    return Row(
      children: [
        StatCard(
          label: 'Chapters',
          value: '${details.detailContent!.chapter!.length}',
          icon: Icons.menu_book_outlined,
        ),
        const SizedBox(width: MangaDetailConstants.statSpacing),
        const StatCard(label: 'Rating', value: '4.8', icon: Icons.star_outline),
        const SizedBox(width: MangaDetailConstants.statSpacing),
        const StatCard(
            label: 'Views', value: '2.1M', icon: Icons.visibility_outlined),
      ],
    );
  }

  Widget _buildGenres(ContentItem details) {
    if (details.detailContent!.genre == null) return const SizedBox.shrink();
    return Wrap(
      spacing: MangaDetailConstants.chipSpacing,
      runSpacing: MangaDetailConstants.chipSpacing,
      children: details.detailContent!.genre!
          .split(', ')
          .take(5)
          .map((genre) => GenreChip(genre: genre.trim()))
          .toList(),
    );
  }

  Widget _buildActionButtons(ContentItem details) {
    return Row(
      children: [
        ActionButton(
          label: 'Read Now',
          icon: Icons.play_arrow,
          isPrimary: true,
          onPressed: () {
            if (details.detailContent!.chapter!.isNotEmpty) {
              NH.navigateTo(MangaReaderScreen(
                  item: widget.item,
                  chapter: details.detailContent!.chapter!.first));
            }
          },
        ),
        const SizedBox(width: MangaDetailConstants.buttonSpacing),
        ActionButton(
            label: 'Download', icon: Icons.download_outlined, onPressed: () {}),
      ],
    );
  }

  Widget _buildDescription(ContentItem details) {
    if (details.detailContent!.discription == null)
      return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextWidget(
              text: 'Synopsis',
            ),
            TextButton(
              onPressed: () =>
                  setState(() => _showDescription = !_showDescription),
              child: TextWidget(
                text: _showDescription ? 'Show Less' : 'Show More',
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        const SizedBox(height: MangaDetailConstants.textSpacing),
        AnimatedCrossFade(
          firstChild: TextWidget(
            text: details.detailContent!.discription!,
            fontSize: 13.sp,
            maxLine: 3,
          ),
          secondChild: TextWidget(
            text: details.detailContent!.discription!,
            fontSize: 13.sp,
          ),
          crossFadeState: _showDescription
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: MangaDetailConstants.crossFadeDuration,
        ),
      ],
    );
  }

  Widget _buildChaptersSection(ContentItem details) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextWidget(
              text: 'Chapters',
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.sort, size: 16),
              label: TextWidget(
                text: 'Sort',
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        const SizedBox(height: MangaDetailConstants.textSpacing),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.detailContent!.chapter!.length > 10
              ? 10
              : details.detailContent!.chapter!.length,
          itemBuilder: (context, index) =>
              ChapterTile(item: widget.item, details: details, index: index),
        ),
        if (details.detailContent!.chapter!.length > 10) ...[
          const SizedBox(height: MangaDetailConstants.textSpacing),
          Center(
            child: TextButton(
              onPressed: () {},
              child: TextWidget(
                text:
                    'View All ${details.detailContent!.chapter!.length} Chapters',
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(
                height: MangaDetailConstants.appBarHeight, color: Colors.white),
            Expanded(
              child: Padding(
                padding: MangaDetailConstants.contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 24,
                        width: double.infinity,
                        color: Colors.white),
                    const SizedBox(height: MangaDetailConstants.sectionSpacing),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: Container(
                            height: 80,
                            margin: EdgeInsets.only(
                                right: index < 2
                                    ? MangaDetailConstants.statSpacing
                                    : 0),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: MangaDetailConstants.sectionSpacing),
                    ...List.generate(
                      5,
                      (index) => Container(
                        height: 60,
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            bottom: MangaDetailConstants.listSpacing),
                        color: Colors.white,
                      ),
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

  Widget _buildErrorState(MangaDetailProvider provider) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: MangaDetailConstants.contentPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 16),
              TextWidget(
                text: 'Something went wrong',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: provider.error!,
                textAlign: TextAlign.center,
                fontSize: 14.sp,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => provider.loadMangaDetails(widget.item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const TextWidget(text: 'Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
