import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/presentation/widgets/misc/padding.dart';
import 'package:watching_app_2/presentation/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';

import '../../../data/models/content_item.dart';
import '../../../data/models/content_source.dart';
import '../../../data/scrapers/scraper_service.dart';
import '../../../core/services/source_manager.dart';
import '../../widgets/appbars/app_bar.dart';
import 'progress_indicator.dart';
import 'tabbed_content_view.dart';

class SearchResultsList extends StatefulWidget {
  final String query;
  const SearchResultsList({super.key, required this.query});

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList>
    with TickerProviderStateMixin {
  final SourceManager sourceManager = SourceManager();
  late TabController _tabController;
  late AnimationController _animationController;

  bool isLoading = true;
  List<ContentSource> sources = [];
  Map<String, Map<String, List<ContentItem>>> allCategoryResults = {};
  String _currentCategory = "videos";
  Map<String, ScraperService> scraperServices = {};
  Map<String, bool> isLoadingMoreMap = {};
  Map<String, String?> errorMap = {};
  Map<String, int> currentPageMap = {};
  Map<String, bool> hasMoreDataMap = {};
  int _activeSourceIndex = 0;

  String _currentQuery = '';
  bool isGrid = false;
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

    // Initialize data structures
    _initializeDataStructures();

    // Add scroll listener for pagination

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

  Future<void> _initializeSearch() async {
    await loadSourcesAndSearch(_currentCategory);
    _animationController.forward();
  }

  Future<void> loadSourcesAndSearch(String category) async {
    setState(() {
      isLoading = true;
      errorMap[category] = null;
      _activeSourceIndex = 0;
    });

    try {
      final loadedSources = await sourceManager.loadSources(category);

      // Setup scrapers for each source
      // List<Future> searchFutures = [];

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
          }
        }
      });

      // Filter sources that are type '1'
      final activeSources =
          sources.where((source) => source.type == '1').toList();

      // Search each source sequentially to track progress
      for (int i = 0; i < activeSources.length; i++) {
        setState(() {
          _activeSourceIndex = i;
        });
        await _searchVideosFromSource(activeSources[i], category);
      }

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
          allCategoryResults[category]![source.searchUrl] =
              newVideos.where((item) {
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
          // Instead of just setting error, initialize empty list for this source
          errorMap["${category}_${source.url}"] =
              'Failed to load videos from ${source.name}: $e';
          if (allCategoryResults[category] == null) {
            allCategoryResults[category] = {};
          }
          // Set empty list for failed source but don't stop execution
          allCategoryResults[category]![source.searchUrl] = [];
          hasMoreDataMap[sourceKey] = false;
        });
      }
      // Don't rethrow the error - allow execution to continue
    }
  }

  void toggleViewMode() {
    setState(() {
      isGrid = !isGrid;
    });
  }

  Widget _buildLoadingShimmer() {
    // Extract current source names for display
    List<String> sourceNames = sources
        .where((source) => source.type == '1')
        .map((source) => source.name)
        .toList();

    return RealtimeProgressIndicator(
      sourceNames: sourceNames,
      activeSourceIndex: _activeSourceIndex,
      isGrid: isGrid,
    );
  }

  Widget _buildErrorView(String? errorMsg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          CustomPadding(
            horizontalFactor: .04,
            child: TextWidget(
              text: errorMsg ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              maxLine: 4,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onTap: () => loadSourcesAndSearch(_currentCategory),
            text: 'Try Again',
            width: .4,
            fontSize: 17.sp,
            borderRadius: 100.w,
          ),
        ],
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
          TextWidget(
            text: 'No results found for "$_currentQuery"',
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: 'Try different keywords or check your spelling',
            color: Colors.grey[600],
            fontSize: 15.sp,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // _showSearchDialog();
            },
            icon: const Icon(Icons.search),
            label: const TextWidget(text: 'Try another search'),
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

// Main build method that was likely missing from your snippet
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: 'Search: $_currentQuery',
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: toggleViewMode,
            tooltip: isGrid ? 'List View' : 'Grid View',
          ),
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: _showSearchDialog,
          //   tooltip: 'Search',
          // ),
        ],
      ),
      body: _buildCategoryContent(_currentCategory),
    );
  }

  Widget _buildCategoryContent(String category) {
    // If loading initial data
    final categoryResults = allCategoryResults[category];
    // Count total results for this category
    int totalResults = 0;
    categoryResults!.forEach((sourceId, results) {
      setState(() {
        totalResults += results.length;
      });
    });

    return isLoading
        ? _buildLoadingShimmer()
        : errorMap[category] != null
            ? _buildErrorView(errorMap[category])
            :

            // If no results at all (empty or null)
            categoryResults.isEmpty || totalResults == 0
                ? _buildNoResultsView()
                : TabbedContentView(
                    categoryResults: categoryResults,
                    sources: sources,
                    isGrid: isGrid,
                    query: widget.query,
                  );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
