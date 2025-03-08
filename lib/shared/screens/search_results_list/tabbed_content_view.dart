import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/navigation/routes.dart';
import '../../../data/models/content_item.dart';
import '../../../data/models/content_source.dart';
import '../../../features/videos/presentation/widgets/video_grid_view.dart';

class TabbedContentView extends StatefulWidget {
  final Map<String, List<ContentItem>> categoryResults;
  final List<ContentSource> sources;
  final bool isGrid;
  final String query;
  final Future Function(String sourceId)? onLoadMore;

  const TabbedContentView({
    super.key,
    required this.categoryResults,
    required this.sources,
    this.isGrid = false,
    required this.query,
    this.onLoadMore,
  });

  @override
  State<TabbedContentView> createState() => _TabbedContentViewState();
}

class _TabbedContentViewState extends State<TabbedContentView>
    with SingleTickerProviderStateMixin {
  String? _selectedSourceId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final Map<String, ScrollController> _scrollControllers = {};
  final PageController _pageController = PageController();
  int _currentPlayingIndex = -1;
  final Map<String, bool> _isLoading = {};

  @override
  void initState() {
    super.initState();
    final sourcesWithContent = widget.categoryResults.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();
    _selectedSourceId =
        sourcesWithContent.isNotEmpty ? sourcesWithContent[0].key : null;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    for (var entry in sourcesWithContent) {
      _scrollControllers[entry.key] = ScrollController();
      _isLoading[entry.key] = false;
    }

    _animationController.forward();
  }

  @override
  void didUpdateWidget(TabbedContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryResults != widget.categoryResults) {
      final newSourcesWithContent = widget.categoryResults.entries
          .where((entry) => entry.value.isNotEmpty)
          .toList();
      for (var entry in newSourcesWithContent) {
        _scrollControllers.putIfAbsent(entry.key, () => ScrollController());
        _isLoading.putIfAbsent(entry.key, () => false);
      }
      _scrollControllers
          .removeWhere((key, _) => !widget.categoryResults.containsKey(key));
      _isLoading
          .removeWhere((key, _) => !widget.categoryResults.containsKey(key));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollControllers.forEach((_, controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  void _switchSource(String sourceId, int index) {
    if (_selectedSourceId != sourceId) {
      setState(() {
        _selectedSourceId = sourceId;
        _animationController.reset();
      });

      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );

      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourcesWithContent = widget.categoryResults.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (sourcesWithContent.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 100.h,
      child: Stack(
        children: [
          _buildBackgroundEffect(sourcesWithContent),
          Column(
            children: [
              _buildPremiumSourceSelector(sourcesWithContent),
              Expanded(
                child: _buildContentPageView(sourcesWithContent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffect(
      List<MapEntry<String, List<ContentItem>>> sourcesWithContent) {
    if (sourcesWithContent.isEmpty || _selectedSourceId == null) {
      return const SizedBox();
    }

    final selectedEntry = sourcesWithContent.firstWhere(
      (entry) => entry.key == _selectedSourceId,
      orElse: () => sourcesWithContent[0],
    );

    final results = selectedEntry.value;
    if (results.isEmpty) return const SizedBox();

    return Positioned.fill(
      child: Opacity(
        opacity: .4,
        child: results[0].thumbnailUrl.isNotEmpty
            ? CustomImageWidget(
                imagePath: SMA.formatImage(
                    image: results[0].thumbnailUrl,
                    baseUrl: results[0].source.url),
                fit: BoxFit.cover,
              )
            : const SizedBox(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101218), Color(0xFF1D1F2B)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 60.sp, color: Colors.grey[400]),
            SizedBox(height: 16.sp),
            TextWidget(
              text: 'No content available',
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.sp),
            TextWidget(
              text: 'Try searching for something else',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSourceSelector(
      List<MapEntry<String, List<ContentItem>>> sourcesWithContent) {
    return Container(
      height: 40.sp,
      margin: EdgeInsets.only(top: 8.sp),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(1),
              Colors.black.withOpacity(1),
              Colors.black.withOpacity(0.1)
            ],
            stops: const [0.0, 0.05, 0.95, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
          child: Row(
            children: List.generate(sourcesWithContent.length, (index) {
              final entry = sourcesWithContent[index];
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
              final isSelected = _selectedSourceId == sourceId;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                child: GestureDetector(
                  onTap: () => _switchSource(sourceId, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint,
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withOpacity(.7)
                              ]
                            : [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.1)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40.sp),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(.3),
                                  blurRadius: 20,
                                  spreadRadius: -2,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                      border: Border.all(
                          color: isSelected
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.1),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isSelected)
                              Container(
                                width: 28.sp,
                                height: 28.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.primaryColor
                                            .withOpacity(.7),
                                        blurRadius: 1,
                                        spreadRadius: 1)
                                  ],
                                ),
                              ),
                            Container(
                              width: 26.sp,
                              height: 26.sp,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.3),
                                image: source.icon.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(source.icon),
                                        fit: BoxFit.contain)
                                    : null,
                              ),
                              child: source.icon.isEmpty
                                  ? Icon(Icons.video_library,
                                      color: Colors.white, size: 14.sp)
                                  : null,
                            ),
                          ],
                        ),
                        SizedBox(width: 10.sp),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: source.name,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.7),
                            ),
                            SizedBox(height: 4.sp),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.sp, vertical: 2.sp),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: TextWidget(
                                text: '${results.length} items',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 18.sp),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildContentPageView(
      List<MapEntry<String, List<ContentItem>>> sourcesWithContent) {
    if (_selectedSourceId == null) {
      return Center(
        child: TextWidget(
          text: 'Select a source to view content',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sourcesWithContent.length,
      itemBuilder: (context, index) {
        final entry = sourcesWithContent[index];
        final sourceId = entry.key;
        final results = entry.value;

        if (sourceId != _selectedSourceId) return const SizedBox();

        // Safely get or create scroll controller
        final scrollController = _scrollControllers[sourceId] ??
            (_scrollControllers[sourceId] = ScrollController());

        if (!scrollController.hasListeners) {
          scrollController.addListener(() {
            if (_isLoading[sourceId] == true) return;

            if (widget.onLoadMore != null &&
                results.isNotEmpty &&
                results.length >= 10 &&
                scrollController.position.pixels >=
                    scrollController.position.maxScrollExtent - 300) {
              _loadMoreContent(sourceId);
            }
          });
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.only(top: 8.sp, left: 12.sp, right: 12.sp),
            child: Stack(
              children: [
                VideoGridView(
                  controller: scrollController,
                  videos: results,
                  isGrid: widget.isGrid,
                  onItemTap: (itemIndex) {
                    final scaleController = AnimationController(
                        duration: const Duration(milliseconds: 200),
                        vsync: this);
                    final scaleAnimation =
                        Tween<double>(begin: 1.0, end: 0.95).animate(
                      CurvedAnimation(
                          parent: scaleController, curve: Curves.easeInOut),
                    );

                    scaleController.forward().then((_) {
                      scaleController.reverse().then((_) {
                        scaleController.dispose();
                        NH.nameNavigateTo(AppRoutes.detail,
                            arguments: {"item": results[itemIndex]});
                      });
                    });
                  },
                  currentPlayingIndex: _currentPlayingIndex,
                  onHorizontalDragStart: (index) => setState(() {
                    _currentPlayingIndex = index;
                  }),
                  onHorizontalDragEnd: (index) => setState(() {
                    _currentPlayingIndex = index;
                  }),
                ),
                if (_isLoading[sourceId] == true)
                  Positioned(
                    bottom: 20.sp,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadMoreContent(String sourceId) async {
    if (_isLoading[sourceId] == true || widget.onLoadMore == null) return;

    setState(() {
      _isLoading[sourceId] = true;
    });

    log('Starting load more for source: $sourceId, current item count: ${widget.categoryResults[sourceId]?.length}');

    try {
      await widget.onLoadMore!(sourceId);
      log('Load more completed for source: $sourceId, new item count: ${widget.categoryResults[sourceId]?.length}');
    } catch (e) {
      log('Load more failed for source: $sourceId, error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading[sourceId] = false;
        });
      }
    }
  }
}
