// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/enums/enums.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/shared/widgets/appbars/app_bar.dart';
import 'package:watching_app_2/shared/widgets/loading/loading_indicator.dart';

import '../../../../core/constants/colors.dart';
import '../../../../data/models/content_item.dart';
import '../../../../data/models/content_source.dart';
import '../../../../data/scrapers/scraper_service.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/loading/pagination_indicator.dart';
import '../../../../shared/widgets/misc/text_widget.dart';
import '../widgets/video_grid_view.dart';

class Videos extends StatefulWidget {
  final ContentSource source;

  const Videos({super.key, required this.source});

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> with TickerProviderStateMixin {
  late ScraperService scraperService;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _toggleController;

  List<ContentItem> videos = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;
  int _currentPlayingIndex = -1;
  bool isGrid = false;
  int _currentPage = 1;
  String _currentQuery = '';
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scraperService = ScraperService(widget.source);
      _currentQuery = widget.source.query.entries.first.value;
      _scrollController.addListener(_scrollListener);
      loadVideos();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _toggleController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && !isLoading && _hasMoreData) {
        loadMoreVideos();
      }
    }
  }

  Future<void> loadVideos({String? selectedQuery}) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = widget.source.pageIncriment.isNotEmpty
          ? int.parse(widget.source.pageIncriment)
          : 1;
      _hasMoreData = true;
    });

    if (selectedQuery != null) {
      _currentQuery = selectedQuery;
    }

    try {
      final newVideos =
          await scraperService.getContent(_currentQuery, _currentPage);
      setState(() {
        videos = newVideos.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;

        if (newVideos.isEmpty) {
          _hasMoreData = false;
        }
      });

      // Trigger fade animation for content
      _fadeController.forward();
    } catch (e) {
      setState(() {
        error = 'Failed to load videos: $e';
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreVideos() async {
    if (!_hasMoreData || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    _slideController.forward();

    try {
      final nextPage = widget.source.pageIncriment.isNotEmpty
          ? _currentPage + int.parse(widget.source.pageIncriment)
          : _currentPage + 1;
      final newVideos =
          await scraperService.getContent(_currentQuery, nextPage);

      final filteredVideos = newVideos.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      setState(() {
        if (filteredVideos.isNotEmpty) {
          videos.addAll(filteredVideos);
          _currentPage = nextPage;
        } else {
          _hasMoreData = false;
        }
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load more videos: $e';
        isLoadingMore = false;
      });
    } finally {
      _slideController.reverse();
    }
  }

  Future<void> searchVideos(String value) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = widget.source.pageIncriment.isNotEmpty
          ? int.parse(widget.source.pageIncriment)
          : 1;
      _currentQuery = value;
      _hasMoreData = true;
    });

    _fadeController.reset();

    try {
      final newVideos = await scraperService.search(value, _currentPage);
      setState(() {
        videos = newVideos.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;

        if (newVideos.isEmpty) {
          _hasMoreData = false;
        }
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        error = 'Failed to load videos: $e';
        isLoading = false;
      });
    }
  }

  void _toggleViewMode() {
    setState(() => isGrid = !isGrid);
    _toggleController.forward().then((_) => _toggleController.reverse());
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: widget.source.name,
        isShowSearchbar: true,
        onSearch: (value) {
          searchVideos(value);
        },
      ),
      body: Stack(
        children: [
          // Enhanced background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
                  AppColors.primaryColor.withOpacity(0.02),
                ],
              ),
            ),
          ),

          // Main content
          _buildMainContent(),

          // Enhanced toggle button
          _buildEnhancedToggleButton(),

          // Enhanced loading overlay
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        source: widget.source,
        onSelected: (query) => loadVideos(selectedQuery: query),
      ),
    );
  }

  Widget _buildMainContent() {
    if (error != null) {
      return _buildErrorState();
    }

    if (videos.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Column(
            children: [
              // Enhanced header info
              // _buildHeaderInfo(),

              // Video grid
              Expanded(
                child: VideoGridView(
                  controller: _scrollController,
                  videos: videos,
                  isGrid: isGrid,
                  currentPlayingIndex: _currentPlayingIndex,
                  onItemTap: (index) {
                    HapticFeedback.lightImpact();
                    NH.nameNavigateTo(AppRoutes.detail,
                        arguments: {"item": videos[index]});
                  },
                  onHorizontalDragStart: (index) => setState(() {
                    _currentPlayingIndex = index;
                  }),
                  onHorizontalDragEnd: (index) => setState(() {
                    _currentPlayingIndex = index;
                  }),
                ),
              ),

              // Enhanced pagination loading
              _buildPaginationLoader(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.video_library_outlined,
              color: AppColors.primaryColor,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: '${videos.length} videos found',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                if (_currentQuery.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  TextWidget(
                    text: 'Search: "$_currentQuery"',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ],
              ],
            ),
          ),

          // View mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGrid ? Icons.grid_view : Icons.view_list,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 4),
                TextWidget(
                  text: isGrid ? 'Grid' : 'List',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationLoader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        if (!isLoadingMore) return const SizedBox.shrink();

        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextWidget(
                    text: 'Loading more videos...',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedToggleButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: AnimatedBuilder(
        animation: _toggleController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_toggleController.value * 0.1),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: _toggleViewMode,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isGrid
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        key: ValueKey(isGrid),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: const Center(
        child: CustomLoadingIndicator(
          loadingText: "Loading videos...",
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            TextWidget(
              text: 'Something went wrong',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextWidget(
              text: error ?? 'Unknown error occurred',
              fontSize: 14,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
              maxLine: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => loadVideos(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_outlined,
                color: AppColors.primaryColor,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            TextWidget(
              text: 'No videos found',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextWidget(
              text: _currentQuery.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'No videos available at the moment',
              fontSize: 14,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_currentQuery.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  _currentQuery = widget.source.query.entries.first.value;
                  loadVideos();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
