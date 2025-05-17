// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/features/tiktok/widgets/tiktok_gridview.dart';
import 'package:watching_app_2/features/wallpapers/presentation/widgets/wallpaper_grid_view.dart';
import 'package:watching_app_2/shared/widgets/misc/gap.dart';

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

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> _isGridView = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with number of content types
    _tabController = TabController(
      length: ContentTypes.ALL_TYPES.length,
      vsync: this,
    );

    // Initialize the favorites provider
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
    Theme.of(context);

    List<TabContent> tabList = ContentTypes.ALL_TYPES.map((entry) {
      return TabContent(
        title: entry,
        icon: _getIconForType(entry),
      );
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(15.h),
        child: CustomAppBar(
          title: 'My Favorites',
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: _isGridView,
              builder: (context, isGrid, child) {
                return IconButton(
                  icon: Icon(
                    isGrid ? Icons.view_list : Icons.grid_view,
                  ),
                  onPressed: () {
                    _isGridView.value = !isGrid;
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Implement search functionality
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10.h),
            child: CustomTabBar(
              tabController: _tabController,
              tabContents: tabList,
              onTabChanged: (index) {
                _tabController.animateTo(index);
              },
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ContentTypes.ALL_TYPES.map((type) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isGridView,
            builder: (context, isGrid, child) {
              return FavoritesTabView(
                contentType: type,
                isGrid: isGrid,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case ContentTypes.VIDEO:
        return Icons.video_library_rounded;
      case ContentTypes.TIKTOK:
        return Icons.music_video_rounded;
      case ContentTypes.IMAGE:
        return Icons.image_rounded;
      case ContentTypes.MANGA:
        return Icons.book_rounded;
      case ContentTypes.ANIME:
        return Icons.movie_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }
}

class FavoritesTabView extends StatefulWidget {
  final String contentType;
  final bool isGrid;

  const FavoritesTabView({
    super.key,
    required this.contentType,
    required this.isGrid,
  });

  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView>
    with AutomaticKeepAliveClientMixin {
  int _currentPlayingIndex = -1;
  List<ContentItem> favorites = []; // Original list
  List<ContentItem> filteredFavorites = []; // Filtered list
  // Track if filters are applied
  bool _filtersApplied = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        // log("widget.contentType is ${widget.contentType}");
        return StreamBuilder<List<ContentItem>>(
          stream: favoritesProvider.watchFavoritesByType(widget.contentType),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: TextWidget(text: 'Error: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              favorites = snapshot.data ?? [];

              // Only update filteredFavorites if no filters are applied
              // or if this is the first data load
              if (!_filtersApplied || filteredFavorites.isEmpty) {
                filteredFavorites = List.from(favorites);
              } else {
                // If filters are applied, we need to preserve the filter logic
                // but update the list if elements were added or removed
                // This is just a placeholder - your actual filter logic may be different
                _updateFilteredListWithNewItems(favorites);
              }
            }

            if (filteredFavorites.isEmpty) {
              return AnimatedEmptyState(
                contentType: widget.contentType,
                onExplore: () {
                  final navProvider = context.read<NavigationProvider>();
                  navProvider.setIndex(2);
                },
              );
            }
            return Scaffold(
              body: widget.contentType == ContentTypes.IMAGE
                  ? WallpaperGridView(
                      wallpapers: filteredFavorites,
                      onItemTap: (index) {
                        NH.nameNavigateTo(AppRoutes.wallpaperDetail,
                            arguments: {'item': filteredFavorites[index]});
                      },
                    )
                  : widget.contentType == ContentTypes.TIKTOK
                      ? WallpaperGridView(
                          wallpapers: filteredFavorites,
                          onItemTap: (index) {
                            NH.navigateTo(TiktokGridView(
                              tiktok: filteredFavorites,
                              onItemTap: (index) {},
                              initalPage: index,
                            ));
                            // NH.nameNavigateTo(AppRoutes.tiktok, arguments: {
                            //   'source': filteredFavorites[index],
                            //   'initalPage': index
                            // });
                          },
                        )
                      : VideoGridView(
                          videos: filteredFavorites,
                          isGrid: widget.isGrid,
                          contentType: widget.contentType,
                          currentPlayingIndex: _currentPlayingIndex,
                          onHorizontalDragStart: (index) => setState(() {
                            _currentPlayingIndex = index;
                          }),
                          onHorizontalDragEnd: (index) => setState(() {
                            _currentPlayingIndex = index;
                          }),
                          onItemTap: (index) {
                            NH.nameNavigateTo(AppRoutes.detail,
                                arguments: {'item': filteredFavorites[index]});
                          },
                        ),
              floatingActionButton: GestureDetector(
                onTap: () {
                  FiltersBottomSheet.show(
                    context,
                    contentType: widget.contentType,
                    items: favorites, // Pass unfiltered list
                    onFiltersApplied: (filteredItems) {
                      setState(() {
                        filteredFavorites = filteredItems;
                        _filtersApplied = true; // Mark that filters are applied
                      });
                    },
                  );
                },
                child: CustomPadding(
                  bottomFactor: .12,
                  child: Container(
                    width: 25.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_rounded,
                            size: 18.sp, color: AppColors.backgroundColorLight),
                        CustomGap(widthFactor: .02),
                        TextWidget(
                          text: "Filter",
                          color: AppColors.backgroundColorLight,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Method to update filtered list while preserving filter logic
  void _updateFilteredListWithNewItems(List<ContentItem> newFullList) {
    // This is a simple example - you'll need to adjust based on your actual filtering logic
    // For example, if you're filtering by tags, categories, etc.

    // Get the URLs of items in the current filtered list
    final Set<String> filteredUrls =
        filteredFavorites.map((item) => item.contentUrl).toSet();

    // For new items in the full list that match filter criteria, add them
    for (final item in newFullList) {
      // This assumes your filter bottom sheet provides the logic to check if an item
      // should be included based on the current filters
      // Replace this with your actual filter logic check
      bool matchesCurrentFilters = true; // Replace with your filter check

      if (matchesCurrentFilters && !filteredUrls.contains(item.contentUrl)) {
        filteredFavorites.add(item);
      }
    }

    // Remove items from filtered list that no longer exist in the full list
    final Set<String> fullListUrls =
        newFullList.map((item) => item.contentUrl).toSet();

    filteredFavorites
        .removeWhere((item) => !fullListUrls.contains(item.contentUrl));
  }
}
