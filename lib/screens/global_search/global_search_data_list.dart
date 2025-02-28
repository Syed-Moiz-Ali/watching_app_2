import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/widgets/text_widget.dart';

import '../../models/content_item.dart';
import '../../models/content_source.dart';
import '../../services/scrapers/scraper_service.dart';
import '../../services/source_manager.dart';
import '../../widgets/custom_appbar.dart';
import 'realtime_progress_indicator.dart';
import 'tabbed_content_view.dart';

class GlobalSearchDataList extends StatefulWidget {
  final String query;
  const GlobalSearchDataList({super.key, required this.query});

  @override
  State<GlobalSearchDataList> createState() => _GlobalSearchDataListState();
}

class _GlobalSearchDataListState extends State<GlobalSearchDataList>
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
          errorMap["${category}_${source.url}"] =
              'Failed to load videos from ${source.name}: $e';
        });
      }
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
          TextWidget(
            text: errorMsg ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            color: Colors.red[300],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => loadSourcesAndSearch(_currentCategory),
            icon: const Icon(Icons.refresh),
            label: const TextWidget(text: 'Try Again'),
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
              TextWidget(
                text: 'Search Content',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
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
                    TextWidget(
                      text: 'Recent Searches',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
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
                            title: TextWidget(text: 'Example search $index'),
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
                  child: TextWidget(
                    text: 'Search',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
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
