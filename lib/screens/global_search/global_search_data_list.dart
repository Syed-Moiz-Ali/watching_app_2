import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/content_item.dart';
import '../../models/content_source.dart';
import '../../services/scrapers/scraper_service.dart';
import '../../services/source_manager.dart';
import '../../widgets/custom_appbar.dart';

class GlobalSearchDataList extends StatefulWidget {
  final String query;
  const GlobalSearchDataList({super.key, required this.query});

  @override
  State<GlobalSearchDataList> createState() => _GlobalSearchDataListState();
}

class _GlobalSearchDataListState extends State<GlobalSearchDataList>
    with TickerProviderStateMixin {
  final SourceManager sourceManager = SourceManager();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool isLoading = true;
  List<ContentSource> sources = [];
  Map<String, Map<String, List<ContentItem>>> allCategoryResults = {};
  String _currentCategory = "videos";
  Map<String, ScraperService> scraperServices = {};
  Map<String, bool> isLoadingMoreMap = {};
  Map<String, String?> errorMap = {};
  Map<String, int> currentPageMap = {};
  Map<String, bool> hasMoreDataMap = {};

  String _currentQuery = '';
  int _currentPlayingIndex = -1;
  String? _currentPlayingSourceId;
  bool isGrid = false;
  bool _isRefreshing = false;
  List<String> categories = ["videos", "movies", "tv_shows", "anime"];

  // Controller for the search field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _currentQuery = widget.query;
    _searchController.text = _currentQuery;

    // Setup animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize data structures
    _initializeDataStructures();

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);

    // Start initial search
    _initializeSearch();
  }

  void _initializeDataStructures() {
    for (String category in categories) {
      allCategoryResults[category] = {};
      isLoadingMoreMap[category] = false;
      errorMap[category] = null;
      currentPageMap[category] = 1;
      hasMoreDataMap[category] = true;
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _animationController.reset();
      setState(() {
        _currentCategory = categories[_tabController.index];
        if (allCategoryResults[_currentCategory]!.isEmpty) {
          loadSourcesAndSearch(_currentCategory);
        } else {
          _animationController.forward();
        }
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !isLoadingMoreMap[_currentCategory]! &&
        hasMoreDataMap[_currentCategory]!) {
      _loadMoreData();
    }
  }

  Future<void> _initializeSearch() async {
    await loadSourcesAndSearch(_currentCategory);
    _animationController.forward();
  }

  Future<void> loadSourcesAndSearch(String category) async {
    setState(() {
      isLoading = true;
      errorMap[category] = null;
    });

    try {
      final loadedSources = await sourceManager.loadSources(category);

      // Setup scrapers for each source
      List<Future> searchFutures = [];

      setState(() {
        sources = loadedSources;
        // Reset current page for all sources in this category
        for (var source in sources) {
          if (source.type == '1') {
            if (scraperServices[source.url] == null) {
              scraperServices[source.url] = ScraperService(source);
            }
            currentPageMap["${category}_${source.url}"] = 1;
            hasMoreDataMap["${category}_${source.url}"] = true;

            // Create a search future for each source
            searchFutures.add(_searchVideosFromSource(source, category));
          }
        }
      });

      // Wait for all searches to complete
      await Future.wait(searchFutures);

      // Mark as not loading after all searches complete
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMap[category] = 'Failed to load sources: $e';
      });
    }
  }

  Future<void> _searchVideosFromSource(
      ContentSource source, String category) async {
    String sourceKey = "${category}_${source.url}";

    try {
      final newVideos = await scraperServices[source.url]!
          .search(_currentQuery, currentPageMap[sourceKey] ?? 1);
      if (mounted) {
        setState(() {
          // Initialize source results map if needed
          if (allCategoryResults[category] == null) {
            allCategoryResults[category] = {};
          }

          // Filter valid videos
          allCategoryResults[category]![source.url] = newVideos.where((item) {
            return item.thumbnailUrl.toString().trim().isNotEmpty &&
                item.thumbnailUrl.toString().trim() != 'NA';
          }).toList();

          // Check if we have more data
          if (newVideos.isEmpty) {
            hasMoreDataMap[sourceKey] = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMap["${category}_${source.url}"] =
              'Failed to load videos from ${source.name}: $e';
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    // Load more data for all sources in current category
    List<Future> loadMoreFutures = [];

    setState(() {
      isLoadingMoreMap[_currentCategory] = true;
    });

    for (var source in sources.where((s) => s.type == '1')) {
      String sourceKey = "${_currentCategory}_${source.url}";

      if (hasMoreDataMap[sourceKey] == true) {
        currentPageMap[sourceKey] = (currentPageMap[sourceKey] ?? 1) + 1;
        loadMoreFutures.add(_loadMoreFromSource(source));
      }
    }

    await Future.wait(loadMoreFutures);

    setState(() {
      isLoadingMoreMap[_currentCategory] = false;
    });
  }

  Future<void> _loadMoreFromSource(ContentSource source) async {
    String sourceKey = "${_currentCategory}_${source.url}";

    try {
      final newVideos = await scraperServices[source.url]!
          .search(_currentQuery, currentPageMap[sourceKey] ?? 1);

      if (mounted) {
        setState(() {
          if (newVideos.isNotEmpty) {
            // Add new videos to existing list
            allCategoryResults[_currentCategory]![source.url]!
                .addAll(newVideos.where((item) {
              return item.thumbnailUrl.toString().trim().isNotEmpty &&
                  item.thumbnailUrl.toString().trim() != 'NA';
            }).toList());
          } else {
            hasMoreDataMap[sourceKey] = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMap[sourceKey] =
              'Failed to load more videos from ${source.name}: $e';
          hasMoreDataMap[sourceKey] = false;
        });
      }
    }
  }

  Future<void> _refreshSearch() async {
    setState(() {
      _isRefreshing = true;
      // Reset pages and flags
      for (var category in categories) {
        for (var source in sources) {
          String sourceKey = "${category}_${source.url}";
          currentPageMap[sourceKey] = 1;
          hasMoreDataMap[sourceKey] = true;
        }
      }
    });

    await loadSourcesAndSearch(_currentCategory);

    setState(() {
      _isRefreshing = false;
    });
  }

  void toggleViewMode() {
    setState(() {
      isGrid = !isGrid;
    });
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isGrid
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildErrorView(String? errorMsg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            errorMsg ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[300]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => loadSourcesAndSearch(_currentCategory),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceHeader(ContentSource source, int resultCount) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (source.icon != null && source.icon!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  source.icon!,
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.video_library, color: Colors.white),
                ),
              ),
            ),
          Expanded(
            child: Text(
              '${source.name} (${resultCount})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              // Navigate to source-specific results
            },
            tooltip: 'View all from ${source.name}',
          ),
        ],
      ),
    );
  }

  Widget _buildContentRow(List<ContentItem> items, String sourceId) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimationLimiter(
      child: isGrid
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    scale: 0.9,
                    child: FadeInAnimation(
                      child: _buildContentItem(items[index], index, sourceId),
                    ),
                  ),
                );
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildContentItem(items[index], index, sourceId),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildContentItem(ContentItem item, int index, String sourceId) {
    final bool isPlaying =
        _currentPlayingIndex == index && _currentPlayingSourceId == sourceId;

    return Hero(
      tag: 'content_${sourceId}_$index',
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentPlayingIndex = index;
            _currentPlayingSourceId = sourceId;
          });
          // Navigate to video player or detail screen
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isPlaying
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isPlaying ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: isPlaying
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: isGrid
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: item.thumbnailUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        if (isPlaying)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.duration ?? '',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.quality ?? 'HD',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? 'No Title',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (item.time != null)
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.time!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 4),
                          if (item.time != null)
                            Row(
                              children: [
                                Icon(Icons.visibility,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.time} views',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 140,
                        height: 90,
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: item.thumbnailUrl ?? '',
                              width: 140,
                              height: 90,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.white),
                              ),
                            ),
                            if (isPlaying)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black54,
                                  child: const Center(
                                    child: Icon(Icons.play_circle_fill,
                                        color: Colors.white, size: 36),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.duration ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 4,
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.quality ?? 'HD',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? 'No Title',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (item.time != null)
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.time!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 4),
                          if (item.time != null)
                            Row(
                              children: [
                                Icon(Icons.visibility,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.time} views',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                item.quality ?? 'Unknown',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Show options menu
                        _showOptionsMenu(context, item);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, ContentItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
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
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to play
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to playlist'),
              onTap: () {
                Navigator.pop(context);
                // Add to playlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                // Download
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Share
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_currentQuery"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or check your spelling',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // _showSearchDialog();
            },
            icon: const Icon(Icons.search),
            label: const Text('Try another search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Completion of the _showSearchDialog() function
  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Search Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  Navigator.pop(context);
                  if (value.isNotEmpty) {
                    setState(() {
                      _currentQuery = value;
                      // Reset all data structures
                      _initializeDataStructures();
                    });
                    loadSourcesAndSearch(_currentCategory);
                  }
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Here you would display recent searches
                    // This is a placeholder - you'd implement recent searches storage
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text('Example search $index'),
                            trailing: const Icon(Icons.north_west),
                            onTap: () {
                              // Set search text and perform search
                              _searchController.text = 'Example search $index';
                              Navigator.pop(context);
                              setState(() {
                                _currentQuery = 'Example search $index';
                                _initializeDataStructures();
                              });
                              loadSourcesAndSearch(_currentCategory);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (_searchController.text.isNotEmpty) {
                      setState(() {
                        _currentQuery = _searchController.text;
                        // Reset all data structures
                        _initializeDataStructures();
                      });
                      loadSourcesAndSearch(_currentCategory);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Main build method that was likely missing from your snippet
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Search: $_currentQuery',
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: toggleViewMode,
            tooltip: isGrid ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search',
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: categories.map((category) {
              return Tab(
                text: category.replaceAll('_', ' ').toUpperCase(),
              );
            }).toList(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshSearch,
              child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: child,
                      );
                    },
                    child: _buildCategoryContent(category),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(String category) {
    // If loading initial data
    if (isLoading && !_isRefreshing) {
      return _buildLoadingShimmer();
    }

    // If there's an error for this category
    if (errorMap[category] != null) {
      return _buildErrorView(errorMap[category]);
    }

    // Get all results for this category
    final categoryResults = allCategoryResults[category];

    // If no results at all (empty or null)
    if (categoryResults == null || categoryResults.isEmpty) {
      return _buildNoResultsView();
    }

    // Count total results for this category
    int totalResults = 0;
    categoryResults.forEach((sourceId, results) {
      totalResults += results.length;
    });

    if (totalResults == 0) {
      return _buildNoResultsView();
    }

    // Build list of content from all sources
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // For each source with results
        ...categoryResults.entries.map((entry) {
          final sourceId = entry.key;
          final results = entry.value;

          if (results.isEmpty) return const SizedBox.shrink();

          // Find the source object
          final source = sources.firstWhere(
            (s) => s.url == sourceId,
            orElse: () => ContentSource(
              name: 'Unknown Source',
              url: sourceId,
              type: '1',
              searchUrl: '',
              decodeType: '',
              nsfw: '',
              getType: '',
              isPreview: '',
              isEmbed: '',
              icon: '',
              pageType: '',
              query: {},
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSourceHeader(source, results.length),
              _buildContentRow(results, sourceId),
            ],
          );
        }).toList(),

        // Show loading indicator at bottom if loading more
        if (isLoadingMoreMap[category] == true)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),

        // Add some padding at the bottom
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
