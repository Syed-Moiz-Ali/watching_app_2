// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/presentation/widgets/appbars/app_bar.dart';
import '../../../data/models/tab_model.dart';
import '../../../core/services/source_manager.dart';
import '../../widgets/misc/tabbar.dart';
import 'components/content_list.dart';

class Sources extends StatefulWidget {
  const Sources({super.key});

  @override
  _SourcesState createState() => _SourcesState();
}

class _SourcesState extends State<Sources> with TickerProviderStateMixin {
  Map<String, List<ContentSource>> allSources = {};
  bool isLoading = true;
  final SourceManager sourceManager = SourceManager();

  String _currentCategory = "videos";
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Initialize fade animation

    loadAllSources();
  }

  Future<void> loadAllSources() async {
    setState(() => isLoading = true);

    List<String> contentTypes = ["videos", "tiktok", "photos", "manga"];

    for (String category in contentTypes) {
      final loadedSources = await sourceManager.loadSources(category);
      allSources[category] = loadedSources;
    }

    if (mounted) {
      setState(() => isLoading = false);
      // Start initial animations
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      String category;
      switch (_tabController.index) {
        case 0:
          category = "videos";
          break;
        case 1:
          category = "tiktok";
          break;
        case 2:
          category = "photos";
          break;
        case 3:
          category = "manga";
          break;
        default:
          category = "videos";
      }
      if (_currentCategory != category) {
        setState(() {
          _currentCategory = category;
          isLoading = false;
        });
        // Restart animations for tab switch
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarHeight: 15.h,
        elevation: 0,
        title: 'Content Sources',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: CustomTabBar(
            tabController: _tabController,
            tabContents: [
              TabContent(title: 'Videos', icon: Icons.video_collection),
              TabContent(title: 'TikTok', icon: Icons.music_note),
              TabContent(title: 'Photos', icon: Icons.photo),
              TabContent(title: 'Manga', icon: Icons.book),
            ],
            onTabChanged: (index) {
              _tabController.animateTo(index);
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const EnhancedShimmerLoadingList()
          else
            TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                ContentList(
                  sources: allSources["videos"] ?? [],
                  key: const ValueKey('content-list-videos'),
                ),
                ContentList(
                  sources: allSources["tiktok"] ?? [],
                  key: const ValueKey('content-list-tiktok'),
                ),
                ContentList(
                  sources: allSources["photos"] ?? [],
                  key: const ValueKey('content-list-photos'),
                ),
                ContentList(
                  sources: allSources["manga"] ?? [],
                  key: const ValueKey('content-list-manga'),
                ),
              ],
            ),
        ],
      ),
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
      period: const Duration(
          milliseconds: 1500), // Slightly slower for smoother effect
      child: ListView.builder(
        padding: EdgeInsets.all(2.h),
        itemCount: 8,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Container(
            height: 15.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // Slightly larger radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 60.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 30.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
