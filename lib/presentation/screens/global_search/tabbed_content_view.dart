// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/presentation/widgets/misc/tabbar.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../../core/navigation/routes.dart';
import '../../../data/models/content_item.dart';
import '../../../data/models/content_source.dart';
import '../../../data/models/tab_model.dart';
import '../../../data/scrapers/scraper_service.dart';
import '../videos_list/components/video_grid_view.dart';

class TabbedContentView extends StatefulWidget {
  final Map<String, List<ContentItem>> categoryResults;
  final List<ContentSource> sources;
  final bool isGrid;
  final String query;

  const TabbedContentView({
    super.key,
    required this.categoryResults,
    required this.sources,
    this.isGrid = false,
    required this.query,
  });

  @override
  _TabbedContentViewState createState() => _TabbedContentViewState();
}

class _TabbedContentViewState extends State<TabbedContentView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  Map<String, int> pageNoMap = {};
  late Map<String, List<ContentItem>> localCategoryResults; // New variable
  String? selectedSourceId; // Variable to store the selected source ID
  int _currentPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    // log('widget.categoryResults is ${widget.categoryResults}');
    localCategoryResults = Map.from(widget.categoryResults);

    final sourcesWithContent = localCategoryResults.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    _tabController = TabController(
      length: sourcesWithContent.length,
      vsync: this,
    );
    _scrollController.addListener(_scrollListener);

    // Initialize the pageNo for each content source
    for (var source in widget.sources) {
      pageNoMap[source.searchUrl] = 1; // Start with page 1 for each source
    }
    selectedSourceId =
        sourcesWithContent.isNotEmpty ? sourcesWithContent[0].key : null;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedSourceId = sourcesWithContent[_tabController.index].key;
        });
      }
    });
  }

  void _scrollListener() {
    if (kDebugMode) {
      print('hitting scroolll');
    }
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (kDebugMode) {
        print('hitting scroolll at end');
      }
      if (kDebugMode) {
        print('selectedSourceId is $selectedSourceId');
      }
      if (selectedSourceId != null) {
        // Check if more data is available (based on `pageNo` logic or API data)
        _loadMoreContent(selectedSourceId!);
      }
    }
  }

  void _loadMoreContent(String sourceId) {
    if (kDebugMode) {
      print('pageNoMap is ${pageNoMap[sourceId]}');
    }
    if (pageNoMap[sourceId] == null) return;

    int pageNo = pageNoMap[sourceId]! == 1 ? 2 : pageNoMap[sourceId]!;

    // Make the API call for the particular ContentSource using the incremented pageNo
    // Assume `fetchMoreData` is a function that will make the API call
    fetchMoreData(sourceId, pageNo).then((newItems) {
      if (kDebugMode) {
        print('newItems is $newItems');
      }
      if (newItems.isNotEmpty) {
        setState(() {
          // Append the new items to the existing content for this source
          localCategoryResults[sourceId]!.addAll(newItems);
          pageNoMap[sourceId] = pageNo + 1; // Increment pageNo for future calls
        });
      }
    }).catchError((error) {
      // Handle error
      if (kDebugMode) {
        print("Error loading more content: $error");
      }
    });
  }

  // Fetch more content for a specific source (assuming an API request)
  Future<List<ContentItem>> fetchMoreData(String sourceId, int pageNo) async {
    ContentSource source =
        widget.sources.firstWhere((source) => source.searchUrl == sourceId);
    ScraperService scraperService = ScraperService(source);
    final newVideos = await scraperService.search(widget.query, pageNo);

    // Filter out videos with empty thumbnails
    final filteredVideos = newVideos.where((item) {
      return item.thumbnailUrl.toString().trim().isNotEmpty &&
          item.thumbnailUrl.toString().trim() != 'NA';
    }).toList();
    return filteredVideos;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourcesWithContent = localCategoryResults.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (sourcesWithContent.isEmpty) {
      return Center(
        child: TextWidget(
          text: 'No content available',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[400],
        ),
      );
    }

    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        children: [
          // Premium TabBar
          _buildPremiumTabBar(sourcesWithContent),
          // TabBarView with animated content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: sourcesWithContent.map((entry) {
                // final sourceId = entry.key;
                final results = entry.value;
                return VideoGridView(
                  controller: _scrollController,
                  videos: results,
                  isGrid: widget.isGrid,
                  currentPlayingIndex: _currentPlayingIndex,
                  onItemTap: (index) {
                    NH.nameNavigateTo(AppRoutes.detail,
                        arguments: {"item": results[index]});
                    // NH.navigateTo(
                    //     DetailScreen(item: videos[index]));
                  },
                  onHorizontalDragStart: (index) => setState(() {
                    _currentPlayingIndex = index;
                  }),
                  onHorizontalDragEnd: (index) => setState(() {
                    _currentPlayingIndex = index;
                  }),
                );
                // _buildContentRow(results, sourceId);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTabBar(
      List<MapEntry<String, List<ContentItem>>> sourcesWithContent) {
    List<TabContent> tabList = sourcesWithContent.map((entry) {
      final sourceId = entry.key;
      final results = entry.value;
      final source = widget.sources.firstWhere(
        (s) => s.searchUrl == sourceId,
        orElse: () => ContentSource(
          name: 'Unknown Source',
          url: sourceId,
          type: '1',
          searchUrl: '',
          decodeType: '',
          nsfw: '',
          getType: '',
          isPreview: '',
          isEmbed: '',
          icon: '',
          pageType: '',
          query: {},
          pageIncriment: '',
        ),
      );

      return TabContent(
        title: '${source.name} (${results.length})',
        icon: source.icon,
        color: AppColors.backgroundColorLight,
      );
    }).toList();
    return FadeTransition(
      opacity: _animationController.drive(CurveTween(curve: Curves.easeInOut)),
      child: CustomTabBar(
        tabController: _tabController,
        onTabChanged: (value) {},
        tabContents: tabList,
      ),
    );
  }
}
