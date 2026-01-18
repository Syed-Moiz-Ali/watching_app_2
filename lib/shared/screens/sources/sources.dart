// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/shared/widgets/appbars/app_bar.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../data/models/tab_model.dart';
import '../../../core/services/source_manager.dart';
import '../../widgets/misc/tabbar.dart';
import 'components/content_list.dart';

// Constants for better maintainability
class SourcesConstants {
  static const Duration shimmerPeriod = Duration(milliseconds: 1400);
  static const int shimmerItemCount = 6;
  static const double borderRadius = 16.0;
  static const double cardElevation = 2.0;
}

// Data class for content type configuration
class ContentTypeConfig {
  final String key;
  final String title;
  final IconData icon;

  const ContentTypeConfig({
    required this.key,
    required this.title,
    required this.icon,
  });
}

// Configuration for all content types
class ContentTypeConfigs {
  static const List<ContentTypeConfig> all = [
    ContentTypeConfig(
      key: 'videos',
      title: 'Videos',
      icon: Icons.video_library_rounded,
    ),
    ContentTypeConfig(
      key: 'tiktok',
      title: 'TikTok',
      icon: Icons.music_note_rounded,
    ),
    ContentTypeConfig(
      key: 'photos',
      title: 'Photos',
      icon: Icons.photo_library_rounded,
    ),
    ContentTypeConfig(
      key: 'manga',
      title: 'Manga',
      icon: Icons.menu_book_rounded,
    ),
    ContentTypeConfig(
      key: 'anime',
      title: 'Anime',
      icon: Icons.video_collection_rounded,
    ),
  ];

  static ContentTypeConfig getByIndex(int index) {
    return all[index.clamp(0, all.length - 1)];
  }

  static int getIndexByKey(String key) {
    return all.indexWhere((config) => config.key == key);
  }
}

class Sources extends StatefulWidget {
  const Sources({super.key});

  @override
  State<Sources> createState() => _SourcesState();
}

class _SourcesState extends State<Sources> with TickerProviderStateMixin {
  final Map<String, List<ContentSource>> _allSources = {};
  final SourceManager _sourceManager = SourceManager();
  late TabController _tabController;

  bool _isLoading = true;
  String _currentCategory = ContentTypeConfigs.all.first.key;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadAllSources();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _initializeTabController() {
    _tabController = TabController(
      length: ContentTypeConfigs.all.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
  }

  Future<void> _loadAllSources() async {
    bool isNSFWEnabled = SMA.pref!.getBool("age_verified") ?? false;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final results =
          await Future.wait(ContentTypeConfigs.all.map((config) async {
        final loadedSources = await _sourceManager.loadSources(config.key);
        return MapEntry(
          config.key,
          loadedSources
              .where((source) =>
                  source.enabled == true &&
                  (isNSFWEnabled ? true : source.nsfw == '0'))
              .toList(),
        );
      }));

      _allSources.addEntries(results);
    } catch (e) {
      debugPrint('Error loading sources: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;

    final newConfig = ContentTypeConfigs.getByIndex(_tabController.index);
    if (_currentCategory != newConfig.key) {
      setState(() {
        _currentCategory = newConfig.key;
      });
    }
  }

  int get _totalSourcesCount {
    return _allSources.values.fold(0, (sum, sources) => sum + sources.length);
  }

  List<TabContent> get _tabContents {
    return ContentTypeConfigs.all.map((config) {
      final sources = _allSources[config.key] ?? [];
      return TabContent(
        title: config.title,
        icon: config.icon,
        length: sources.length.toString(),
      );
    }).toList();
  }

  List<Widget> get _tabViews {
    return ContentTypeConfigs.all.map((config) {
      final sources = _allSources[config.key] ?? [];
      return ContentList(
        sources: sources,
        key: ValueKey('content-list-${config.key}'),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      appBarHeight: 15.h,
      elevation: 0,
      title: 'Sources',
      actions: [_buildSourcesCounter()],
      bottom: _buildTabBar(),
      appBarStyle: AppBarStyle.standard,
    );
  }

  Widget _buildSourcesCounter() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done_rounded,
              size: 16,
              color: theme.primaryColor,
            ),
            SizedBox(width: 1.5.w),
            TextWidget(
              text: '$_totalSourcesCount',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }

  PreferredSize _buildTabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(10.h),
      child: CustomTabBarHorizontal(
        tabController: _tabController,
        tabContents: _tabContents,
        onTabChanged: (index) => _tabController.animateTo(index),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ModernShimmerLoadingList();
    }

    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: _tabViews,
    );
  }
}

// Modern minimalist shimmer loading
class ModernShimmerLoadingList extends StatelessWidget {
  const ModernShimmerLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: SourcesConstants.shimmerPeriod,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: SourcesConstants.shimmerItemCount,
        itemBuilder: (context, index) => _buildShimmerItem(context, isDark),
      ),
    );
  }

  Widget _buildShimmerItem(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.w),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(SourcesConstants.borderRadius),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SourcesConstants.borderRadius),
                  bottomLeft: Radius.circular(SourcesConstants.borderRadius),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShimmerLine(
                    width: 50.w,
                    height: 16,
                    isDark: isDark,
                  ),
                  SizedBox(height: 8),
                  _buildShimmerLine(
                    width: 70.w,
                    height: 12,
                    isDark: isDark,
                  ),
                  SizedBox(height: 8),
                  _buildShimmerLine(
                    width: 35.w,
                    height: 12,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine({
    required double width,
    required double height,
    required bool isDark,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
