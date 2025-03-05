// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:watching_app_2/core/enums/app_enums.dart';
import 'package:watching_app_2/core/navigation/navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';
import 'package:watching_app_2/presentation/widgets/appbars/custom_appbar.dart';

import '../../../core/constants/color_constants.dart';
import '../../../data/models/content_item.dart';
import '../../../data/models/content_source.dart';
import '../../../data/scrapers/scraper_service.dart';
import '../../widgets/buttons/custom_floatingaction_button.dart';
import '../../widgets/loading/pagination_loading_indicator.dart';
import '../../widgets/misc/text_widget.dart';
import 'components/video_grid_view.dart';

class VideoListScreen extends StatefulWidget {
  final ContentSource source;

  const VideoListScreen({super.key, required this.source});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late ScraperService scraperService;
  List<ContentItem> videos = [];
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scraperService = ScraperService(widget.source);
      _currentQuery = widget.source.query.entries.first.value;

      // Add scroll listener
      _scrollController.addListener(_scrollListener);

      loadVideos();
    });
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
        loadMoreVideos();
      }
    }
  }

  Future<void> loadVideos({String? selectedQuery}) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = widget.source.pageIncriment.isNotEmpty
          ? int.parse(widget.source.pageIncriment)
          : 1; // Reset page number
      _hasMoreData = true; // Reset more data flag
    });

    if (selectedQuery != null) {
      _currentQuery = selectedQuery;
    }

    try {
      final newVideos =
          await scraperService.getContent(_currentQuery, _currentPage);
      setState(() {
        videos = newVideos.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;
        // If no videos returned or fewer than expected, assume no more data
        if (newVideos.isEmpty) {
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
  Future<void> loadMoreVideos() async {
    if (!_hasMoreData || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final nextPage = widget.source.pageIncriment.isNotEmpty
          ? _currentPage + int.parse(widget.source.pageIncriment)
          : _currentPage + 1;
      final newVideos =
          await scraperService.getContent(_currentQuery, nextPage);

      // Filter out videos with empty thumbnails
      final filteredVideos = newVideos.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      setState(() {
        if (filteredVideos.isNotEmpty) {
          videos.addAll(filteredVideos);
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

  Future<void> searchVideos(String value) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = widget.source.pageIncriment.isNotEmpty
          ? int.parse(widget.source.pageIncriment)
          : 1; // Reset page number
      _currentQuery = value; // Update current query
      _hasMoreData = true; // Reset more data flag
    });

    try {
      final newVideos = await scraperService.search(value, _currentPage);
      setState(() {
        videos = newVideos.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;
        // If no videos returned or fewer than expected, assume no more data
        if (newVideos.isEmpty) {
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
          searchVideos(value);
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
                  : videos.isEmpty
                      ? const Center(
                          child: TextWidget(
                            text: 'No data found',
                            styleType: TextStyleType.subheading,
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: VideoGridView(
                                controller: _scrollController,
                                videos: videos,
                                isGrid: isGrid,
                                currentPlayingIndex: _currentPlayingIndex,
                                onItemTap: (index) {
                                  NH.nameNavigateTo(AppRoutes.detail,
                                      arguments: {"item": videos[index]});
                                  // NH.navigateTo(
                                  //     DetailScreen(item: videos[index]));
                                },
                                onHorizontalDragStart: (index) => setState(() {
                                  _currentPlayingIndex = index;
                                }),
                                onHorizontalDragEnd: (index) => setState(() {
                                  _currentPlayingIndex = index;
                                }),
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
          _buildToggleButton(),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        source: widget.source,
        onSelected: (query) => loadVideos(selectedQuery: query),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      bottom: 10,
      left: 20,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(1000),
        ),
        child: IconButton(
          icon: Icon(
            isGrid ? Icons.list : Icons.grid_view,
            color: AppColors.backgroundColorLight,
          ),
          onPressed: () => setState(() => isGrid = !isGrid),
        ),
      ),
    );
  }
}
