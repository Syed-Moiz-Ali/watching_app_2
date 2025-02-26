import 'package:flutter/material.dart';

import '../../core/enums/app_enums.dart';
import '../../core/navigation/navigator.dart';
import '../../models/content_item.dart';
import '../../models/content_source.dart';
import '../../services/scrapers/scraper_service.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_floatingaction_button.dart';
import '../../widgets/pagination_loading_indicator.dart';
import '../../widgets/text_widget.dart';
import '../wallpaper_detail/wallpaper_detail.dart';
import 'components/wallpaper_grid_view.dart';

class WallpapersList extends StatefulWidget {
  final ContentSource source;

  const WallpapersList({super.key, required this.source});

  @override
  State<WallpapersList> createState() => _WallpapersListState();
}

class _WallpapersListState extends State<WallpapersList> {
  late ScraperService scraperService;
  List<ContentItem> wallpapers = [];
  bool isLoading = true;
  bool isLoadingMore = false; // Flag for loading more items
  String? error;
  int _currentPlayingIndex = -1;
  bool isGrid = false;
  int _currentPage = 1; // Track the current page
  String _currentQuery = ''; // Track the current query
  bool _hasMoreData = true; // Flag to check if more data is available
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller

  @override
  void initState() {
    super.initState();
    scraperService = ScraperService(widget.source);
    _currentQuery = widget.source.query.entries.first.value;

    // Add scroll listener
    _scrollController.addListener(_scrollListener);

    loadWallpapers();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener to detect when user reaches the end of the list
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
      _currentPage = 1; // Reset page number
      _hasMoreData = true; // Reset more data flag
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
        // If no videos returned or fewer than expected, assume no more data
        if (newWallpapers.isEmpty) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load videos: $e';
        isLoading = false;
      });
    }
  }

  // New method to load more videos when scrolling ends
  Future<void> loadMoreWallpapers() async {
    if (!_hasMoreData || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newWallpapers =
          await scraperService.getContent(_currentQuery, nextPage);

      // Filter out videos with empty thumbnails
      final filteredWallpapers = newWallpapers.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      setState(() {
        if (filteredWallpapers.isNotEmpty) {
          wallpapers.addAll(filteredWallpapers);
          _currentPage = nextPage;
        } else {
          _hasMoreData = false; // No more data available
        }
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load more videos: $e';
        isLoadingMore = false;
      });
    }
  }

  Future<void> searchWallpaper(String value) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = 1; // Reset page number
      _currentQuery = value; // Update current query
      _hasMoreData = true; // Reset more data flag
    });

    try {
      final newWallpapers = await scraperService.search(value, _currentPage);
      setState(() {
        wallpapers = newWallpapers.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;
        // If no videos returned or fewer than expected, assume no more data
        if (newWallpapers.isEmpty) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load videos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          isLoading
              ? const Center(
                  child: PaginationLoadingIndicator(
                    loadingText: "Loading videos...",
                  ),
                )
              : error != null
                  ? Center(child: Text(error!))
                  : wallpapers.isEmpty
                      ? const Center(
                          child: TextWidget(
                            text: 'No data found',
                            styleType: TextStyleType.subheading,
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: WallpaperGridView(
                                wallpapers: wallpapers,
                                controller: _scrollController,
                                onItemTap: (index) {
                                  // showModalBottomSheet(
                                  //     isScrollControlled: true,
                                  //     context: context,
                                  //     builder: (context) {
                                  //       return UltraPremiumWallpaperDetail(
                                  //         item: wallpapers[
                                  //             index], // Replace with actual image URL
                                  //       );
                                  //     });
                                  NH.navigateTo(UltraPremiumWallpaperDetail(
                                    item: wallpapers[
                                        index], // Replace with actual image URL
                                  ));
                                },
                              ),
                            ),
                            // Enhanced loading animation when loading more items
                            if (isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: PaginationLoadingIndicator(
                                  loadingText: "Loading more videos...",
                                ),
                              ),
                          ],
                        ),
          // _buildToggleButton(),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        source: widget.source,
        onSelected: (query) => loadWallpapers(selectedQuery: query),
      ),
    );
  }
}
