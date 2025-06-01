// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
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
  static const Duration shimmerPeriod = Duration(milliseconds: 1500);
  static const int shimmerItemCount = 8;
  static const double borderRadius = 12.0;
  static const double shadowOpacity = 0.05;
  static const double shadowBlurRadius = 10.0;
  static const Offset shadowOffset = Offset(0, 2);
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
        key: 'videos', title: 'Videos', icon: Icons.video_collection),
    ContentTypeConfig(key: 'tiktok', title: 'TikTok', icon: Icons.music_note),
    ContentTypeConfig(key: 'photos', title: 'Photos', icon: Icons.photo),
    ContentTypeConfig(key: 'manga', title: 'Manga', icon: Icons.book),
    ContentTypeConfig(key: 'anime', title: 'Anime', icon: Icons.book),
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
    bool isNSFWEnabled = SMA.pref!.getBool("ageVerificationEnabled") ?? false;
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
      // Handle error appropriately - could show snackbar, etc.
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
      title: 'Content Sources',
      actions: [_buildSourcesCounter()],
      bottom: _buildTabBar(),
      appBarStyle: AppBarStyle.standard,
    );
  }

  Widget _buildSourcesCounter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, size: 20),
          SizedBox(width: 1.w),
          TextWidget(
            text: 'Active Sources: $_totalSourcesCount',
            fontSize: 15.sp,
          ),
        ],
      ),
    );
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
      return const EnhancedShimmerLoadingList();
    }

    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: _tabViews,
    );
  }
}

class EnhancedShimmerLoadingList extends StatelessWidget {
  const EnhancedShimmerLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: SourcesConstants.shimmerPeriod,
      child: ListView.builder(
        padding: EdgeInsets.all(2.h),
        itemCount: SourcesConstants.shimmerItemCount,
        itemBuilder: (context, index) => _buildShimmerItem(),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Container(
        height: 15.h,
        decoration: _buildShimmerItemDecoration(),
        child: Row(
          children: [
            _buildShimmerImage(),
            SizedBox(width: 3.w),
            Expanded(child: _buildShimmerContent()),
            SizedBox(width: 2.w),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildShimmerItemDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(SourcesConstants.borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(SourcesConstants.shadowOpacity),
          blurRadius: SourcesConstants.shadowBlurRadius,
          offset: SourcesConstants.shadowOffset,
        ),
      ],
    );
  }

  Widget _buildShimmerImage() {
    return Container(
      width: 30.w,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SourcesConstants.borderRadius),
          bottomLeft: Radius.circular(SourcesConstants.borderRadius),
        ),
      ),
    );
  }

  Widget _buildShimmerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildShimmerLine(width: 40.w, height: 2.h),
        SizedBox(height: 1.h),
        _buildShimmerLine(width: 60.w, height: 1.5.h),
        SizedBox(height: 1.h),
        _buildShimmerLine(width: 30.w, height: 1.5.h),
      ],
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
