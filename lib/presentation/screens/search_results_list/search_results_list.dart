import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/presentation/widgets/misc/padding.dart';
import 'package:watching_app_2/presentation/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';
import '../../provider/search_provider.dart';
import '../../widgets/appbars/app_bar.dart';
import '../../widgets/loading/pagination_indicator.dart';
import 'progress_indicator.dart';
import 'tabbed_content_view.dart';

class SearchResultsList extends StatefulWidget {
  const SearchResultsList({super.key, required this.query});

  final String query;

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Set initial query and start search
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<SearchProvider>(context, listen: false);
      provider.setQuery(widget.query);
      await provider
          .loadSourcesAndSearch("videos", widget.query)
          .then((_) => _animationController.forward());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _animationController.reset();
      final provider = Provider.of<SearchProvider>(context, listen: false);
      provider.setCurrentCategory(provider.categories[_tabController.index]);

      if (provider.allCategoryResults[provider.currentCategory]!.isEmpty) {
        provider
            .loadSourcesAndSearch(
                provider.currentCategory, provider.currentQuery)
            .then((_) => _animationController.forward());
      } else {
        _animationController.forward();
      }
    }
  }

  Widget _buildLoadingShimmer(SearchProvider provider) {
    List<String> sourceNames = provider.sources
        .where((source) => source.type == '1')
        .map((source) => source.name)
        .toList();

    return RealtimeProgressIndicator(
      sourceNames: sourceNames,
      activeSourceIndex: provider.activeSourceIndex,
      isGrid: provider.isGrid,
    );
  }

  Widget _buildErrorView(String? errorMsg, SearchProvider provider) {
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
            onTap: () => provider.loadSourcesAndSearch(
                provider.currentCategory, provider.currentQuery),
            text: 'Try Again',
            width: .4,
            fontSize: 17.sp,
            borderRadius: 100.w,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView(SearchProvider provider) {
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
            text: 'No results found for "${provider.currentQuery}"',
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: 'Try different keywords or check your spelling',
            color: Colors.grey[600],
            fontSize: 15.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(SearchProvider provider) {
    final categoryResults =
        provider.allCategoryResults[provider.currentCategory];
    if (categoryResults == null) {
      return const Center(
        child: PaginationLoadingIndicator(
          loadingText: 'loading videos',
        ),
      );
    }
    int totalResults = 0;
    categoryResults.forEach((sourceId, results) {
      totalResults += results.length;
    });

    return
        // provider.isLoading
        //     ? _buildLoadingShimmer(provider)
        //     : provider.errorMap[provider.currentCategory] != null
        //         ? _buildErrorView(
        //             provider.errorMap[provider.currentCategory], provider)
        //         :
        categoryResults.isEmpty || totalResults == 0
            ? Center(
                child: PaginationLoadingIndicator(
                  loadingText: 'loading ${widget.query} videos',
                ),
              )
            : TabbedContentView(
                categoryResults: categoryResults,
                sources: provider.sources,
                isGrid: provider.isGrid,
                query: widget.query,
                onLoadMore: (sourceId) {
                  return provider.loadMoreContent(
                      provider.currentCategory, sourceId);
                  // return true;
                },
              );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          extendBody: true,
          appBar: CustomAppBar(
            automaticallyImplyLeading: true,
            title: 'Search: ${provider.currentQuery}',
            actions: [
              IconButton(
                icon: Icon(provider.isGrid ? Icons.view_list : Icons.grid_view),
                onPressed: () => provider.toggleViewMode(),
                tooltip: provider.isGrid ? 'List View' : 'Grid View',
              ),
            ],
          ),
          body: _buildCategoryContent(provider),
        );
      },
    );
  }
}
