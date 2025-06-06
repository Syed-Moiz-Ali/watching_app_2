// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

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
    FiltersBottomSheet.show(
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
  // UI State
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;

    setState(() => _isPressed = true);

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;

    setState(() => _isPressed = false);

    widget.onPressed();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;

    setState(() => _isPressed = false);
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (!widget.isEnabled) return;
    setState(() => _isHovered = true);
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (!widget.isEnabled) return;
    setState(() => _isHovered = false);
  }

  @override
  Widget build(BuildContext context) {
    // Start shimmer animation if not active

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: Tooltip(
        message: widget.tooltip ??
            (widget.hasActiveFilters ? 'Clear Filters' : 'Apply Filters'),
        preferBelow: false,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Container(
            width: 25.w,
            height: 5.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // Primary shadow
                BoxShadow(
                  color: (AppColors.primaryColor).withOpacity(0.3),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
                // Glow effect for active state
                if (widget.hasActiveFilters)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Main button container
                  _buildMainContainer(),

                  // Shimmer effect overlay

                  // Ripple effect

                  // Content
                  _buildContent(),

                  // Disabled overlay
                  if (!widget.isEnabled) _buildDisabledOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (AppColors.primaryColor).withOpacity(0.9),
            AppColors.primaryColor,
            (AppColors.primaryColor).withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: Colors.transparent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: widget.hasActiveFilters ? 1.0 : 0.0),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.5, // Subtle rotation
                child: Icon(
                  widget.hasActiveFilters
                      ? Icons.filter_list_off_rounded
                      : Icons.filter_list_rounded,
                  size: 18.sp,
                  color: AppColors.backgroundColorLight.withOpacity(
                    widget.isEnabled ? 1.0 : 0.5,
                  ),
                ),
              );
            },
          ),

          // Animated Gap
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.02, end: _isPressed ? 0.015 : 0.02),
            builder: (context, value, child) {
              return SizedBox(width: value * 100.w);
            },
          ),

          // Animated Text
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: AppColors.backgroundColorLight.withOpacity(
                widget.isEnabled ? 1.0 : 0.5,
              ),
              fontWeight:
                  widget.hasActiveFilters ? FontWeight.w600 : FontWeight.w500,
              fontSize: _isPressed ? 13.sp : 14.sp,
            ),
            child: TextWidget(
              text: widget.hasActiveFilters ? "Filtered" : "Filter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
