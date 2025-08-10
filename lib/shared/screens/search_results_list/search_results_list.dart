import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../presentation/provider/search_provider.dart';
import '../../widgets/appbars/app_bar.dart';
import '../../widgets/loading/loading_indicator.dart';
import '../../widgets/loading/pagination_indicator.dart';
import 'tabbed_content_view.dart';

class SearchResultsList extends StatefulWidget {
  const SearchResultsList({
    super.key,
    required this.query,
    required this.category,
  });

  final String query;
  final String category;

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _statsController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _statsAnimation;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTabController();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      ),
    );

    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );
  }

  void _initializeTabController() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<SearchProvider>(context, listen: false);
      provider.setQuery(widget.query);

      await provider.loadSourcesAndSearch(widget.category, widget.query);

      if (mounted) {
        _animationController.forward();
        _fadeController.forward();
        _slideController.forward();
        _statsController.forward();
      }
    });
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _tabController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _statsController.dispose();
    _searchController.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    HapticFeedback.lightImpact();

    _animationController.reset();
    _fadeController.reset();

    final provider = Provider.of<SearchProvider>(context, listen: false);
    provider.setCurrentCategory(provider.categories[_tabController.index]);

    if (provider.allCategoryResults[provider.currentCategory]!.isEmpty) {
      provider
          .loadSourcesAndSearch(provider.currentCategory, provider.currentQuery)
          .then((_) {
        if (mounted) {
          _animationController.forward();
          _fadeController.forward();
        }
      });
    } else {
      _animationController.forward();
      _fadeController.forward();
    }
  }

  void _toggleViewMode(SearchProvider provider) {
    HapticFeedback.lightImpact();
    provider.toggleViewMode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          extendBody: true,
          appBar: CustomAppBar(
            appBarHeight: 80,
            automaticallyImplyLeading: true,
            title: 'Search Results',
            subtitle: provider.currentQuery.isNotEmpty
                ? '"${provider.currentQuery}"'
                : null,
            appBarStyle: AppBarStyle.premium,
            actions: [
              _buildEnhancedViewToggle(provider, theme, isDark),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildEnhancedCategoryContent(provider, theme, isDark),
        );
      },
    );
  }

  Widget _buildEnhancedViewToggle(
      SearchProvider provider, ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => _toggleViewMode(provider),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.isGrid
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.isGrid ? 'List' : 'Grid',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSearchStats(
      SearchProvider provider, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.cardColor.withOpacity(0.9),
            theme.cardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.15),
                  theme.primaryColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.search_rounded,
              color: theme.primaryColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Search info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getResultsCount(provider),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Found',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Category: ${widget.category}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.15),
                  theme.primaryColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.isGrid ? Icons.grid_view : Icons.view_list,
                  size: 14,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.isGrid ? 'Grid' : 'List',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryContent(
      SearchProvider provider, ThemeData theme, bool isDark) {
    final categoryResults = provider.allCategoryResults[widget.category];

    if (categoryResults == null) {
      return _buildEnhancedLoadingState(theme);
    }

    int totalResults = 0;
    categoryResults.forEach((sourceId, results) {
      totalResults += results.length;
    });

    if (categoryResults.isEmpty || totalResults == 0) {
      return _buildEnhancedEmptyState(provider, theme, isDark);
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: TabbedContentView(
            categoryResults: categoryResults,
            sources: provider.sources,
            isGrid: provider.isGrid,
            category: widget.category,
            query: widget.query,
            onLoadMore: (sourceId) {
              return provider.loadMoreContent(widget.category, sourceId);
            },
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingState(ThemeData theme) {
    return Center(child: CustomLoadingIndicator()

        // Container(
        //   padding: const EdgeInsets.all(32),
        //   decoration: BoxDecoration(
        //     color: theme.cardColor.withOpacity(0.8),
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(
        //       color: Colors.grey.withOpacity(0.2),
        //       width: 1,
        //     ),
        //   ),
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.all(20),
        //         decoration: BoxDecoration(
        //           gradient: LinearGradient(
        //             colors: [
        //               theme.primaryColor.withOpacity(0.15),
        //               theme.primaryColor.withOpacity(0.08),
        //             ],
        //           ),
        //           shape: BoxShape.circle,
        //         ),
        //         child: const CustomLoadingIndicator(),
        //       ),
        //       const SizedBox(height: 20),
        //       Text(
        //         'Searching for content...',
        //         style: TextStyle(
        //           fontSize: 16.sp,
        //           fontWeight: FontWeight.w600,
        //           color: theme.textTheme.bodyLarge?.color,
        //         ),
        //       ),
        //       const SizedBox(height: 8),
        //       Text(
        //         'Finding the best results for "${widget.query}"',
        //         style: TextStyle(
        //           fontSize: 12.sp,
        //           color: Colors.grey[600],
        //         ),
        //         textAlign: TextAlign.center,
        //       ),
        //     ],
        //   ),
        // ),
        );
  }

  Widget _buildEnhancedEmptyState(
      SearchProvider provider, ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.cardColor,
              theme.cardColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0.15),
                    theme.primaryColor.withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: theme.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any content for "${widget.query}" in ${widget.category}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords or check your spelling',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getResultsCount(SearchProvider provider) {
    final categoryResults = provider.allCategoryResults[widget.category];
    if (categoryResults == null) return '0 results';

    int totalResults = 0;
    categoryResults.forEach((sourceId, results) {
      totalResults += results.length;
    });

    if (totalResults >= 1000000) {
      return '${(totalResults / 1000000).toStringAsFixed(1)}M results';
    } else if (totalResults >= 1000) {
      return '${(totalResults / 1000).toStringAsFixed(1)}K results';
    }

    return '$totalResults results';
  }
}
