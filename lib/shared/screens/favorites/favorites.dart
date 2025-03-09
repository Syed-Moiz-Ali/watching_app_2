// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/shared/widgets/misc/gap.dart';
import 'package:watching_app_2/shared/widgets/misc/tabbar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../data/models/tab_model.dart';
import '../../../presentation/provider/favorites_provider.dart';
import '../../../core/navigation/routes.dart';
import '../../widgets/appbars/app_bar.dart';
import '../../../features/videos/presentation/widgets/video_grid_view.dart';
import '../../widgets/misc/padding.dart';
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        return StreamBuilder<List<ContentItem>>(
          stream: favoritesProvider.watchFavoritesByType(widget.contentType),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: TextWidget(text: 'Error: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              favorites = snapshot.data ?? [];
              if (filteredFavorites.isEmpty) {
                // Only update filteredFavorites if no filters are applied
                filteredFavorites = List.from(favorites);
              }
            }

            if (filteredFavorites.isEmpty) {
              return AnimatedEmptyState(contentType: widget.contentType);
            }

            return Scaffold(
              body: VideoGridView(
                videos: filteredFavorites, // ✅ Use filtered list
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
                    items: favorites, // ✅ Pass unfiltered list
                    onFiltersApplied: (filteredItems) {
                      setState(() {
                        filteredFavorites = filteredItems; // ✅ Apply filters
                      });
                    },
                  );
                },
                child: CustomPadding(
                  bottomFactor: .1,
                  child: Container(
                    width: 13.w,
                    height: 13.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.backgroundColorDark,
                    ),
                    child: const Icon(Icons.menu,
                        size: 28, color: AppColors.backgroundColorLight),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AnimatedEmptyState extends StatelessWidget {
  final String contentType;

  const AnimatedEmptyState({super.key, required this.contentType});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 800),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_border_rounded,
                        size: 64, color: AppColors.primaryColor),
                  ),
                  SizedBox(height: 4.h),
                  TextWidget(
                    text: 'No $contentType favorites yet',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 1.h),
                  TextWidget(
                    text:
                        'Browse content and heart your favorites to see them here!',
                    textAlign: TextAlign.center,
                    maxLine: 4,
                    fontSize: 15.sp,
                  ),
                  SizedBox(height: 4.h),
                  PrimaryButton(
                    width: .4,
                    borderRadius: 10.h,
                    onTap: () {
                      // Navigate to explore/browse page
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.explore,
                            color: AppColors.backgroundColorLight),
                        const CustomGap(widthFactor: .02),
                        TextWidget(
                            text: 'Explore',
                            fontSize: 18.sp,
                            color: AppColors.backgroundColorLight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
