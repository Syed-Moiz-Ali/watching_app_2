// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/data/database/local_database.dart';
import 'package:watching_app_2/presentation/widgets/misc/gap.dart';
import 'package:watching_app_2/presentation/widgets/misc/tabbar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:watching_app_2/presentation/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../data/models/tab_model.dart';
import '../../provider/favorites_provider.dart';
import '../../../core/navigation/routes.dart';
import '../../widgets/appbars/app_bar.dart';
import '../videos/components/video_grid_view.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Theme.of(context);

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        // Show loading indicator while initializing
        if (favoritesProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 2.h),
                const TextWidget(
                  text: 'Loading your favorites...',
                ),
              ],
            ),
          );
        }

        // Use FutureBuilder to get favorites by type
        return FutureBuilder<List<ContentItem>>(
            future: favoritesProvider.getFavoritesByType(widget.contentType),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(
              //     child: CircularProgressIndicator(),
              //   );
              // }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 2.h),
                      const TextWidget(
                        text: 'Oops! Something went wrong',
                      ),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: TextWidget(
                          text: 'Error loading favorites: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh),
                        label: const TextWidget(text: 'Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final favorites = snapshot.data ?? [];

              if (favorites.isEmpty) {
                return AnimatedEmptyState(contentType: widget.contentType);
              }

              return AnimationConfiguration.synchronized(
                duration: const Duration(milliseconds: 800),
                child: VideoGridView(
                  videos: favorites,
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
                    // NH.navigateTo(DetailScreen(item: favorites[index]));
                    NH.nameNavigateTo(AppRoutes.detail,
                        arguments: {'item': favorites[index]});
                  },
                ),
              );
            });
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
