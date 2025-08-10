// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/features/tiktok/widgets/tiktok_gridview.dart';
import 'package:watching_app_2/features/wallpapers/presentation/widgets/wallpaper_grid_view.dart';
import 'package:watching_app_2/shared/widgets/misc/tabbar.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../data/models/tab_model.dart';
import '../../../presentation/provider/favorites_provider.dart';
import '../../../core/navigation/routes.dart';
import '../../../presentation/provider/navigation_provider.dart';
import '../../widgets/appbars/app_bar.dart';
import '../../../features/videos/presentation/widgets/video_grid_view.dart';
import '../../widgets/misc/padding.dart';
import 'empty_favorites.dart';
import 'filters_bottom_sheet.dart';

/// Main Favorites page displaying user's favorite content across different categories
class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> _isGridView = ValueNotifier(true);

  // Favorites data
  List<ContentItem> _allFavorites = [];

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _initializeFavoritesProvider();
  }

  void _initializeTabController() {
    _tabController = TabController(
      length: ContentTypes.ALL_TYPES.length,
      vsync: this,
    );
  }

  void _initializeFavoritesProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _isGridView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        return FutureBuilder<List<ContentItem>>(
          future: provider.getAllFavorites(),
          builder: (context, snapshot) {
            return _buildScaffold(snapshot);
          },
        );
      },
    );
  }

  Widget _buildScaffold(AsyncSnapshot<List<ContentItem>> snapshot) {
    if (snapshot.hasError) {
      return _buildErrorState(snapshot.error.toString());
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingState();
    }

    _allFavorites = snapshot.data ?? [];

    return Scaffold(
      appBar: _buildAppBar(_allFavorites.length.toString()),
      body: _buildTabBarView(),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: _buildSimpleAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            TextWidget(text: 'Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const TextWidget(text: 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: _buildSimpleAppBar(),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  PreferredSize _buildSimpleAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      child: const CustomAppBar(
        title: 'My Favorites',
        appBarStyle: AppBarStyle.standard,
      ),
    );
  }

  PreferredSize _buildAppBar(String length) {
    return PreferredSize(
      preferredSize: Size.fromHeight(15.h),
      child: CustomAppBar(
        title: 'My Favorites ($length)',
        appBarStyle: AppBarStyle.standard,
        actions: _buildAppBarActions(),
        bottom: _buildTabBar(),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      _buildViewToggleButton(),
      _buildSearchButton(),
    ];
  }

  Widget _buildViewToggleButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isGridView,
      builder: (context, isGrid, child) {
        return IconButton(
          icon: Icon(
            isGrid ? Icons.view_list : Icons.grid_view,
          ),
          onPressed: () => _isGridView.value = !isGrid,
          tooltip: isGrid ? 'List View' : 'Grid View',
        );
      },
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: _handleSearch,
      tooltip: 'Search Favorites',
    );
  }

  void _handleSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: TextWidget(text: 'Search functionality coming soon!')),
    );
  }

  PreferredSize _buildTabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(10.h),
      child: CustomTabBarHorizontal(
        tabController: _tabController,
        tabContents: _buildTabContents(),
        onTabChanged: (index) => _tabController.animateTo(index),
      ),
    );
  }

  List<TabContent> _buildTabContents() {
    return ContentTypes.ALL_TYPES.map((contentType) {
      final count = _getFavoritesCountForType(contentType);
      return TabContent(
        title: contentType,
        icon: _getIconForType(contentType),
        length: count.toString(),
      );
    }).toList();
  }

  int _getFavoritesCountForType(String contentType) {
    final category = ContentTypes.TYPE_TO_CATEGORY2[contentType];
    return _allFavorites.where((item) => item.source.type == category).length;
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: ContentTypes.ALL_TYPES.map((type) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isGridView,
          builder: (context, isGrid, child) {
            return FavoritesTabView(
              contentType: type,
              isGrid: isGrid,
              favorites: _allFavorites,
              key: ValueKey('${type}_$isGrid'),
            );
          },
        );
      }).toList(),
    );
  }

  IconData _getIconForType(String type) {
    const iconMap = {
      ContentTypes.VIDEO: Icons.video_library_rounded,
      ContentTypes.TIKTOK: Icons.music_video_rounded,
      ContentTypes.IMAGE: Icons.image_rounded,
      ContentTypes.MANGA: Icons.book_rounded,
      ContentTypes.ANIME: Icons.movie_rounded,
    };
    return iconMap[type] ?? Icons.favorite_rounded;
  }
}

/// Individual tab view for displaying favorites of a specific content type
class FavoritesTabView extends StatefulWidget {
  final String contentType;
  final bool isGrid;
  final List<ContentItem> favorites;

  const FavoritesTabView({
    super.key,
    required this.contentType,
    required this.isGrid,
    required this.favorites,
  });

  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView>
    with AutomaticKeepAliveClientMixin {
  // Video player state
  int _currentPlayingIndex = -1;

  // Filtered data
  late List<ContentItem> _categoryFavorites;
  List<ContentItem> _filteredFavorites = [];
  bool _hasActiveFilters = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _updateFavoritesList();
  }

  @override
  void didUpdateWidget(covariant FavoritesTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldUpdateFavorites(oldWidget)) {
      _updateFavoritesList();
    }
  }

  bool _shouldUpdateFavorites(FavoritesTabView oldWidget) {
    return widget.favorites != oldWidget.favorites ||
        widget.contentType != oldWidget.contentType;
  }

  void _updateFavoritesList() {
    _categoryFavorites = _getFavoritesForCategory();
    _updateFilteredList();
  }

  List<ContentItem> _getFavoritesForCategory() {
    final category = ContentTypes.TYPE_TO_CATEGORY2[widget.contentType];
    return widget.favorites
        .where((item) => item.source.type == category)
        .toList();
  }

  void _updateFilteredList() {
    if (!_hasActiveFilters || _filteredFavorites.isEmpty) {
      _filteredFavorites = List.from(_categoryFavorites);
    } else {
      _updateFilteredListWithNewItems(_categoryFavorites);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_filteredFavorites.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      body: _buildContentView(),
      floatingActionButton: _buildFilterButton(),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedEmptyState(
      contentType: widget.contentType,
      onExplore: _navigateToExplore,
    );
  }

  void _navigateToExplore() {
    final navProvider = context.read<NavigationProvider>();
    navProvider.setIndex(2);
  }

  Widget _buildContentView() {
    switch (widget.contentType) {
      case ContentTypes.IMAGE:
      case ContentTypes.TIKTOK:
      case ContentTypes.MANGA:
        return _buildWallpaperGrid(widget.contentType);
      // case ContentTypes.TIKTOK:
      //   return _buildTiktokGrid();
      default:
        return _buildVideoGrid();
    }
  }

  Widget _buildWallpaperGrid(String contentType) {
    return WallpaperGridView(
      wallpapers: _filteredFavorites,
      contentType: contentType,
      onItemTap: (index) => _handleWallpaperTap(index, contentType),
    );
  }

  Widget _buildVideoGrid() {
    return VideoGridView(
      videos: _filteredFavorites,
      isGrid: widget.isGrid,
      contentType: widget.contentType,
      currentPlayingIndex: _currentPlayingIndex,
      onHorizontalDragStart: _handleVideoPlay,
      onHorizontalDragEnd: _handleVideoPlay,
      onItemTap: _handleVideoTap,
    );
  }

  void _handleWallpaperTap(int index, String contentType) {
    if (contentType == ContentTypes.TIKTOK) {
      NH.navigateTo(TiktokGridView(
        tiktok: _filteredFavorites,
        onItemTap: _handleTiktokTap,
        initalPage: index,
      ));
    } else {
      NH.nameNavigateTo(
        AppRoutes.wallpaperDetail,
        arguments: {'item': _filteredFavorites[index]},
      );
    }
  }

  void _handleTiktokTap(int index) {
    log('TikTok item tapped: $index');
  }

  void _handleVideoPlay(int index) {
    if (mounted) {
      setState(() => _currentPlayingIndex = index);
    }
  }

  void _handleVideoTap(int index) {
    NH.nameNavigateTo(
      AppRoutes.detail,
      arguments: {'item': _filteredFavorites[index]},
    );
  }

  Widget _buildFilterButton() {
    return CustomPadding(
      bottomFactor: 0.08,
      child: PremiumFilterButton(
        onPressed: _showFilters,
        hasActiveFilters: _hasActiveFilters,
        tooltip: 'Toggle filters',
      ),
    );
  }

  void _showFilters() {
    MinimalistFiltersBottomSheet.show(
      context,
      contentType: widget.contentType,
      items: _categoryFavorites,
      onFiltersApplied: _applyFilters,
    );
  }

  void _applyFilters(List<ContentItem> filteredItems) {
    if (mounted) {
      setState(() {
        _filteredFavorites = filteredItems;
        _hasActiveFilters = true;
      });
    }
  }

  void _updateFilteredListWithNewItems(List<ContentItem> newFullList) {
    final filteredUrls =
        _filteredFavorites.map((item) => item.contentUrl).toSet();

    // Add new items that match current filters
    for (final item in newFullList) {
      if (_itemMatchesCurrentFilters(item) &&
          !filteredUrls.contains(item.contentUrl)) {
        _filteredFavorites.add(item);
      }
    }

    // Remove items that are no longer in the full list
    final fullListUrls = newFullList.map((item) => item.contentUrl).toSet();

    _filteredFavorites.removeWhere(
      (item) => !fullListUrls.contains(item.contentUrl),
    );
  }

  bool _itemMatchesCurrentFilters(ContentItem item) {
    return true;
  }
}

/// Ultra-premium animated filter button with sophisticated animations and modern design
class PremiumFilterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool hasActiveFilters;
  final bool isEnabled;
  final String? tooltip;

  const PremiumFilterButton({
    super.key,
    required this.onPressed,
    required this.hasActiveFilters,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  State<PremiumFilterButton> createState() => _PremiumFilterButtonState();
}

class _PremiumFilterButtonState extends State<PremiumFilterButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.hasActiveFilters) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumFilterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasActiveFilters != oldWidget.hasActiveFilters) {
      if (widget.hasActiveFilters) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Tooltip(
            message: widget.tooltip ??
                (widget.hasActiveFilters ? 'Clear Filters' : 'Apply Filters'),
            preferBelow: false,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                width: 68, // More compact
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor
                          .withOpacity(0.9 + (0.1 * _glowAnimation.value)),
                      AppColors.primaryColor
                          .withOpacity(0.7 + (0.1 * _glowAnimation.value)),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20), // More refined radius
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor
                          .withOpacity(0.3 + (0.2 * _glowAnimation.value)),
                      blurRadius: 12 + (8 * _glowAnimation.value),
                      offset: const Offset(0, 4),
                      spreadRadius: widget.hasActiveFilters
                          ? 2 * _glowAnimation.value
                          : 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced animated icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: widget.hasActiveFilters ? 1.0 : 0.0),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.25,
                child: Icon(
                  widget.hasActiveFilters
                      ? Icons.filter_list_off_rounded
                      : Icons.tune_rounded,
                  size: 24,
                  color: Colors.white.withOpacity(widget.isEnabled ? 1.0 : 0.5),
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // Enhanced text
          Text(
            widget.hasActiveFilters ? "Filtered" : "Filter",
            style: TextStyle(
              color: Colors.white.withOpacity(widget.isEnabled ? 1.0 : 0.5),
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
