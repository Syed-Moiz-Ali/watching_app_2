import 'package:flutter/material.dart';
import 'package:watching_app_2/shared/widgets/loading/loading_indicator.dart';

import '../../../../core/enums/enums.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../data/models/content_item.dart';
import '../../../../data/models/content_source.dart';
import '../../../../data/scrapers/scraper_service.dart';
import '../../../../shared/widgets/appbars/app_bar.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/loading/pagination_indicator.dart';
import '../../../../shared/widgets/misc/text_widget.dart';
import '../../../wallpapers/presentation/widgets/wallpaper_grid_view.dart';
import 'manga_detail/manga_detail.dart';

class Manga extends StatefulWidget {
  final ContentSource source;
  const Manga({super.key, required this.source});

  @override
  State<Manga> createState() => _MangaState();
}

class _MangaState extends State<Manga> {
  late ScraperService scraperService;
  List<ContentItem> mangas = [];
  bool isLoading = true;
  bool isLoadingMore = false; // Flag for loading more items
  String? error;
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

    loadMangas();
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
        loadMoreMangas();
      }
    }
  }

  Future<void> loadMangas({String? selectedQuery}) async {
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
        mangas = newWallpapers.where((item) {
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
  Future<void> loadMoreMangas() async {
    if (!_hasMoreData || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newMangas =
          await scraperService.getContent(_currentQuery, nextPage);

      // Filter out videos with empty thumbnails
      final filtertedManga = newMangas.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      setState(() {
        if (filtertedManga.isNotEmpty) {
          mangas.addAll(filtertedManga);
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
      final newMangas = await scraperService.search(value, _currentPage);
      setState(() {
        mangas = newMangas.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;
        // If no videos returned or fewer than expected, assume no more data
        if (newMangas.isEmpty) {
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
                  child: CustomLoadingIndicator(
                    loadingText: "Loading videos...",
                  ),
                )
              : error != null
                  ? Center(child: Text(error!))
                  : mangas.isEmpty
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
                                wallpapers: mangas,
                                controller: _scrollController,
                                onItemTap: (index) {
                                  NH.navigateTo(MangaDetailScreen(
                                    item: mangas[
                                        index], // Replace with actual image URL
                                  ));
                                  // NH.nameNavigateTo(AppRoutes.wallpaperDetail,
                                  //     arguments: {'item': mangas[index]});
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
        onSelected: (query) => loadMangas(selectedQuery: query),
      ),
    );
  }
}
