import 'package:flutter/material.dart';
import 'package:watching_app_2/features/tiktok/widgets/tiktok_gridview.dart';

import '../../../../core/enums/enums.dart';
import '../../../../data/models/content_item.dart';
import '../../../../data/models/content_source.dart';
import '../../../../data/scrapers/scraper_service.dart';

import '../../../../shared/widgets/loading/loading_indicator.dart';
import '../../../../shared/widgets/loading/pagination_indicator.dart';
import '../../../../shared/widgets/misc/text_widget.dart';

class TikTok extends StatefulWidget {
  final ContentSource source;
  final int? initalPage;

  const TikTok({super.key, required this.source, this.initalPage});

  @override
  State<TikTok> createState() => _WallpapersState();
}

class _WallpapersState extends State<TikTok> {
  late ScraperService scraperService;
  List<ContentItem> tiktok = [];
  bool isLoading = true;
  bool isLoadingMore = false; // Flag for loading more items
  String? error;
  bool isGrid = false;
  int _currentPage = 1; // Track the current page
  String _currentQuery = ''; // Track the current query
  bool _hasMoreData = true; // Flag to check if more data is available
  late PageController _scrollController; // Scroll controller

  @override
  void initState() {
    super.initState();
    _scrollController = PageController(
        viewportFraction: 1, initialPage: widget.initalPage ?? 0);

    scraperService = ScraperService(widget.source);
    _currentQuery = widget.source.query.entries.first.value;

    // Add scroll listener
    _scrollController.addListener(_scrollListener);

    loadTiktokVideos();
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
        loadMoreTikTokVideos();
      }
    }
  }

  Future<void> loadTiktokVideos({String? selectedQuery}) async {
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
      final newTikTokList =
          await scraperService.getTikTokContent(_currentQuery, _currentPage);
      setState(() {
        tiktok = newTikTokList.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;
        // If no videos returned or fewer than expected, assume no more data
        if (newTikTokList.isEmpty) {
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
  Future<void> loadMoreTikTokVideos() async {
    if (!_hasMoreData || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newTikTokList =
          await scraperService.getTikTokContent(_currentQuery, nextPage);

      // Filter out videos with empty thumbnails
      final tiktokFilterdList = newTikTokList.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      setState(() {
        if (tiktokFilterdList.isNotEmpty) {
          tiktok.addAll(tiktokFilterdList);
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
      final newTikTokList = await scraperService.search(value, _currentPage);
      setState(() {
        tiktok = newTikTokList.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;
        // If no videos returned or fewer than expected, assume no more data
        if (newTikTokList.isEmpty) {
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
      // appBar: CustomAppBar(
      //   automaticallyImplyLeading: true,
      //   title: widget.source.name,
      //   isShowSearchbar: true,
      //   onSearch: (value) {
      //     searchWallpaper(value);
      //   },
      // ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CustomLoadingIndicator(
                    loadingText: "Loading tiktoks...",
                  ),
                )
              : error != null
                  ? Center(child: TextWidget(text: error!))
                  : tiktok.isEmpty
                      ? const Center(
                          child: TextWidget(
                            text: 'No data found',
                            styleType: TextStyleType.subheading,
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: TiktokGridView(
                                tiktok: tiktok,
                                controller: _scrollController,
                                onItemTap: (index) {
                                  // NH.navigateTo(MinimalistWallpaperDetail(
                                  //   item: tiktok[
                                  //       index], // Replace with actual image URL
                                  // ));
                                  // NH.nameNavigateTo(AppRoutes.wallpaperDetail,
                                  //     arguments: {'item': tiktok[index]});
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
      // floatingActionButton: CustomFloatingActionButton(
      //   source: widget.source,
      //   onSelected: (query) => loadTiktokVideos(selectedQuery: query),
      // ),
    );
  }
}
