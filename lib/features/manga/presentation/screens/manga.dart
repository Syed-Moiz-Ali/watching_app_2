// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/shared/widgets/loading/loading_indicator.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../data/database/local_database.dart';
import '../../../../data/models/content_item.dart';
import '../../../../data/models/content_source.dart';
import '../../../../data/scrapers/scraper_service.dart';
import '../../../../shared/widgets/appbars/app_bar.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../wallpapers/presentation/widgets/wallpaper_grid_view.dart';
import 'manga_detail/manga_detail.dart';

class Manga extends StatefulWidget {
  final ContentSource source;
  const Manga({super.key, required this.source});

  @override
  State<Manga> createState() => _MangaState();
}

class _MangaState extends State<Manga> with TickerProviderStateMixin {
  late ScraperService scraperService;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _statsController;

  List<ContentItem> mangas = [];
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
    loadMangas();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _statsController.dispose();
    super.dispose();
  }

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
      _currentPage = 1;
      _hasMoreData = true;
    });

    if (selectedQuery != null) {
      _currentQuery = selectedQuery;
    }

    try {
      final newMangas =
          await scraperService.getContent(_currentQuery, _currentPage);
      setState(() {
        mangas = newMangas.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;

        if (newMangas.isEmpty) {
          _hasMoreData = false;
        }
      });

      _fadeController.forward();
      _statsController.forward();
    } catch (e) {
      setState(() {
        error = 'Failed to load manga: $e';
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreMangas() async {
    if (!_hasMoreData || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    _slideController.forward();

    try {
      final nextPage = _currentPage + 1;
      final newMangas =
          await scraperService.getContent(_currentQuery, nextPage);

      final filteredManga = newMangas.where((item) {
        return item.thumbnailUrl.toString().trim().isNotEmpty &&
            item.thumbnailUrl.toString().trim() != 'NA';
      }).toList();

      setState(() {
        if (filteredManga.isNotEmpty) {
          mangas.addAll(filteredManga);
          _currentPage = nextPage;
        } else {
          _hasMoreData = false;
        }
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load more manga: $e';
        isLoadingMore = false;
      });
    } finally {
      _slideController.reverse();
    }
  }

  Future<void> searchManga(String value) async {
    setState(() {
      isLoading = true;
      error = null;
      _currentPage = 1;
      _currentQuery = value;
      _hasMoreData = true;
    });

    _fadeController.reset();
    _statsController.reset();

    try {
      final newMangas = await scraperService.search(value, _currentPage);
      setState(() {
        mangas = newMangas.where((item) {
          return item.thumbnailUrl.toString().trim().isNotEmpty &&
              item.thumbnailUrl.toString().trim() != 'NA';
        }).toList();
        isLoading = false;

        if (newMangas.isEmpty) {
          _hasMoreData = false;
        }
      });

      _fadeController.forward();
      _statsController.forward();
    } catch (e) {
      setState(() {
        error = 'Failed to search manga: $e';
        isLoading = false;
      });
    }
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
          searchManga(value);
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
                  theme.primaryColor.withOpacity(0.03),
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
        onSelected: (query) => loadMangas(selectedQuery: query),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, bool isDark) {
    if (error != null) {
      return _buildErrorState(theme);
    }

    if (mangas.isEmpty && !isLoading) {
      return _buildEmptyState(theme);
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Column(
            children: [
              // Enhanced header info with manga-specific design
              // _buildMangaHeaderInfo(theme, isDark),

              // Manga grid
              Expanded(
                child: WallpaperGridView(
                  wallpapers: mangas,
                  controller: _scrollController,
                  contentType: ContentTypes.MANGA,
                  onItemTap: (index) {
                    HapticFeedback.lightImpact();
                    NH.navigateTo(MangaDetailScreen(
                      item: mangas[index],
                    ));
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
                    const Color(0xFFF59E0B).withOpacity(0.12),
                    const Color(0xFFF59E0B).withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Loading more manga...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
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
          loadingText: "Loading manga...",
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
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load manga',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'Something went wrong while loading manga series',
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
              onPressed: () => loadMangas(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
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
                    const Color(0xFFF59E0B).withOpacity(0.15),
                    const Color(0xFFF59E0B).withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: Color(0xFFF59E0B),
                size: 64,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No manga found',
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
                  ? 'Try searching for different manga titles or authors'
                  : 'No manga series available right now. Check back later!',
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
                  loadMangas();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
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
