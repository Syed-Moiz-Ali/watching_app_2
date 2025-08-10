import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/navigation/routes.dart';

import '../../../../core/enums/enums.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../data/models/content_item.dart';
import '../../../../data/models/content_source.dart';
import '../../../../data/scrapers/scraper_service.dart';
import '../../../../shared/widgets/appbars/app_bar.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/loading/loading_indicator.dart';
import '../../../../shared/widgets/loading/pagination_indicator.dart';
import '../../../../shared/widgets/misc/text_widget.dart';
import '../widgets/wallpaper_grid_view.dart';

class Wallpapers extends StatefulWidget {
  final ContentSource source;

  const Wallpapers({super.key, required this.source});

  @override
  State<Wallpapers> createState() => _WallpapersState();
}

class _WallpapersState extends State<Wallpapers> with TickerProviderStateMixin {
  late ScraperService scraperService;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;

  List<ContentItem> wallpapers = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;
  bool isGrid = false;
  int _currentPage = 1;
  String _currentQuery = '';
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    scraperService = ScraperService(widget.source);
    _currentQuery = widget.source.query.entries.first.value;
    _scrollController.addListener(_scrollListener);
    loadWallpapers();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && !isLoading && _hasMoreData) {
        loadMoreWallpapers();
      }
    }
  }

  Future<void> loadWallpapers({String? selectedQuery}) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = 1;
      _hasMoreData = true;
    });

    if (selectedQuery != null) {
      _currentQuery = selectedQuery;
    }

    try {
      final newWallpapers =
          await scraperService.getContent(_currentQuery, _currentPage);
      setState(() {
        wallpapers = newWallpapers.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;

        if (newWallpapers.isEmpty) {
          _hasMoreData = false;
        }
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        error = 'Failed to load wallpapers: $e';
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreWallpapers() async {
    if (!_hasMoreData || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    _slideController.forward();

    try {
      final nextPage = _currentPage + 1;
      final newWallpapers =
          await scraperService.getContent(_currentQuery, nextPage);

      final filteredWallpapers = newWallpapers.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      setState(() {
        if (filteredWallpapers.isNotEmpty) {
          wallpapers.addAll(filteredWallpapers);
          _currentPage = nextPage;
        } else {
          _hasMoreData = false;
        }
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load more wallpapers: $e';
        isLoadingMore = false;
      });
    } finally {
      _slideController.reverse();
    }
  }

  Future<void> searchWallpaper(String value) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = 1;
      _currentQuery = value;
      _hasMoreData = true;
    });

    _fadeController.reset();

    try {
      final newWallpapers = await scraperService.search(value, _currentPage);
      setState(() {
        wallpapers = newWallpapers.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;

        if (newWallpapers.isEmpty) {
          _hasMoreData = false;
        }
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        error = 'Failed to load wallpapers: $e';
        isLoading = false;
      });
    }
  }

  void _toggleViewMode() {
    setState(() => isGrid = !isGrid);
    _buttonController.forward().then((_) => _buttonController.reverse());
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: widget.source.name,
        isShowSearchbar: true,
        onSearch: (value) {
          searchWallpaper(value);
        },
      ),
      body: Stack(
        children: [
          // Enhanced background with subtle gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.scaffoldBackgroundColor.withOpacity(0.98),
                  theme.primaryColor.withOpacity(0.02),
                ],
              ),
            ),
          ),

          // Main content
          _buildMainContent(theme, isDark),

          // Enhanced loading overlay
          if (isLoading) _buildLoadingOverlay(theme),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        source: widget.source,
        onSelected: (query) => loadWallpapers(selectedQuery: query),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, bool isDark) {
    if (error != null) {
      return _buildErrorState(theme);
    }

    if (wallpapers.isEmpty && !isLoading) {
      return _buildEmptyState(theme);
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Column(
            children: [
              // Enhanced header info with modern design
              // _buildHeaderInfo(theme, isDark),

              // Wallpaper grid
              Expanded(
                child: WallpaperGridView(
                  wallpapers: wallpapers,
                  controller: _scrollController,
                  onItemTap: (index) {
                    HapticFeedback.lightImpact();
                    NH.nameNavigateTo(AppRoutes.wallpaperDetail,
                        arguments: {'item': wallpapers[index]});
                  },
                ),
              ),

              // Enhanced pagination loading
              _buildPaginationLoader(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderInfo(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.cardColor.withOpacity(0.8),
            theme.cardColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          // Enhanced icon container
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
              Icons.wallpaper_rounded,
              color: theme.primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 16),

          // Content info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: '${wallpapers.length} wallpapers',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
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
                            Icons.hd_rounded,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'HD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_currentQuery.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Search: "$_currentQuery"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Quality indicator
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
                  Icons.verified_rounded,
                  size: 14,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: 11,
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

  Widget _buildPaginationLoader(ThemeData theme) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        if (!isLoadingMore) return const SizedBox.shrink();

        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0.12),
                    theme.primaryColor.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Loading more wallpapers...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withOpacity(0.9),
      child: const Center(
        child: CustomLoadingIndicator(
          loadingText: "Loading wallpapers...",
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
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
            color: Colors.red.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.15),
                    Colors.red.withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'Failed to load wallpapers',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => loadWallpapers(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
              color: Colors.black.withOpacity(0.08),
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
                Icons.wallpaper_outlined,
                color: theme.primaryColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No wallpapers found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _currentQuery.isNotEmpty
                  ? 'Try searching with different keywords or browse categories'
                  : 'No wallpapers available at the moment. Check back later!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (_currentQuery.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  _currentQuery = widget.source.query.entries.first.value;
                  loadWallpapers();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
