// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching_app_2/models/content_source.dart';
import 'package:watching_app_2/widgets/custom_appbar.dart';
import '../../services/source_manager.dart';
import '../../widgets/custom_tabbar.dart';
import 'components/content_list.dart';

class SourceListScreen extends StatefulWidget {
  const SourceListScreen({super.key});

  @override
  _SourceListScreenState createState() => _SourceListScreenState();
}

class _SourceListScreenState extends State<SourceListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SourceManager sourceManager = SourceManager();
  bool isLoading = true;
  List<ContentSource> sources = [];
  String _currentCategory = "videos";
  final Map<String, List<ContentSource>> _cachedSources = {};

  // Page controller for custom page transitions
  late PageController _pageController;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Initialize page controller with initial page
    _pageController = PageController(initialPage: 0);

    // Initialize animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    loadSources("videos"); // Load default tab (videos)
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      // Animate to the selected page when tab is tapped
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

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
        _currentCategory = category;
        loadSources(category);
      }
    }
  }

  Future<void> loadSources(String category) async {
    // If we have cached data, show it immediately to prevent UI flicker
    if (_cachedSources.containsKey(category)) {
      setState(() {
        sources = _cachedSources[category]!;
        isLoading = false;
      });
      _fadeController.forward(from: 0.0);
    } else {
      setState(() => isLoading = true);
    }

    // Load data in background
    final loadedSources = await sourceManager.loadSources(category);

    // Small artificial delay for smoother transition
    await Future.delayed(const Duration(milliseconds: 300));

    // Cache the results
    _cachedSources[category] = loadedSources;

    // Only update state if this is still the current category
    if (_currentCategory == category && mounted) {
      setState(() {
        sources = loadedSources;
        isLoading = false;
      });
      _fadeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        appBarHeight: 15.h,
        elevation: 0,
        title: 'Content Sources',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: CustomTabBar(
            tabController: _tabController,
            onTabChanged: (index) {
              // Handle tab change in _handleTabSelection
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // Custom PageView instead of TabBarView for more control over animations
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              // Keep tab controller in sync with page changes
              _tabController.animateTo(index);
            },
            itemCount: 4,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: isLoading
                    ? const EnhancedShimmerLoadingList()
                    : ContentList(
                        sources: sources,
                        key: ValueKey('content-list-$index-${sources.length}'),
                      ),
              );
            },
          ),

          // Overlay loading indicator
          if (isLoading)
            FadeTransition(
              opacity: _fadeAnimation,
              child: const EnhancedShimmerLoadingList(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

class EnhancedShimmerLoadingList extends StatelessWidget {
  const EnhancedShimmerLoadingList({Key? key}) : super(key: key);

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
