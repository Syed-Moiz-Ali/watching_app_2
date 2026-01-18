// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/services/source_manager.dart';
import 'package:watching_app_2/shared/screens/categories/components/category_card.dart';
import 'package:watching_app_2/shared/widgets/appbars/app_bar.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/tab_model.dart';
import '../../widgets/misc/tabbar.dart';
import 'components/category_detail.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with TickerProviderStateMixin {
  late TabController _tabController;
  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  List<CategoryModel> _stars = [];
  List<CategoryModel> _filteredStars = [];

  bool _isLoading = true;
  bool _isSearching = false;
  String _currentSearchQuery = '';

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize TabController
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Fetch data
    _fetchData();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {});
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for smooth loading state
    await Future.delayed(const Duration(milliseconds: 600));

    final loadedCategories = await SourceManager().loadCategories();
    final loadedStars = await SourceManager().loadStars();

    if (mounted) {
      setState(() {
        _categories = loadedCategories;
        _filteredCategories = List.from(loadedCategories);
        _stars = loadedStars;
        _filteredStars = List.from(loadedStars);
        _isLoading = false;
      });
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _currentSearchQuery = query;
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredCategories = List.from(_categories);
        _filteredStars = List.from(_stars);
      } else {
        if (_tabController.index == 0) {
          _filteredCategories = _categories
              .where((category) =>
                  category.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
        } else {
          _filteredStars = _stars
              .where((star) =>
                  star.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      }
    });
  }

  // Modern minimal shimmer loading
  Widget _buildShimmerLoading() {
    return CustomPadding(
      horizontalFactor: .04,
      topFactor: .02,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildShimmerCard(index);
        },
      ),
    );
  }

  Widget _buildShimmerCard(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          // Text placeholders
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 60.w,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey[150],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: 1500.ms,
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey[300]!.withOpacity(0.5),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 100));
  }

  // Empty state when no results found
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(curve: Curves.easeOutBack),

            SizedBox(height: 24),

            // Title
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -0.3,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            SizedBox(height: 12),

            // Description
            Text(
              _isSearching
                  ? 'We couldn\'t find any ${_tabController.index == 0 ? 'categories' : 'stars'} matching "$_currentSearchQuery"'
                  : 'No ${_tabController.index == 0 ? 'categories' : 'stars'} available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            SizedBox(height: 32),

            // Action button
            if (_isSearching)
              TextButton.icon(
                onPressed: () {
                  _filterCategories('');
                },
                icon: Icon(Icons.clear_rounded, size: 18),
                label: Text('Clear Search'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    curve: Curves.easeOutBack,
                  ),
          ],
        ),
      ),
    );
  }

  // Animated category grid
  Widget _buildAnimatedCategoryCard(
      List<CategoryModel> filteredData, int index) {
    return CategoryCard(
      category: filteredData[index],
      index: index,
      onTap: (index) => _onCategoryTap(filteredData[index]),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + (index * 50)),
          duration: 500.ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 100 + (index * 50)),
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          delay: Duration(milliseconds: 100 + (index * 50)),
          curve: Curves.easeOutBack,
        );
  }

  void _onCategoryTap(CategoryModel data) {
    HapticFeedback.mediumImpact();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PremiumCategoryDetailScreen(category: data);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesTab(List<CategoryModel> filteredData) {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (filteredData.isEmpty) {
      return _buildEmptyState();
    }

    return CustomPadding(
      horizontalFactor: .04,
      topFactor: .02,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          return _buildAnimatedCategoryCard(filteredData, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        appBarHeight: 15.h,
        elevation: 0,
        title: 'Explore',
        isShowSearchbar: true,
        bottom: _buildTabBar(),
        appBarStyle: AppBarStyle.standard,
        onChanged: (value) {
          _filterCategories(value);
        },
        onSearchClosed: () {
          setState(() {
            _filteredCategories = _categories;
            _filteredStars = _stars;
            _isSearching = false;
            _currentSearchQuery = '';
          });
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: _tabViews,
    );
  }

  List<Widget> get _tabViews {
    return [
      _buildCategoriesTab(_filteredCategories),
      _buildCategoriesTab(_filteredStars)
    ];
  }

  PreferredSize _buildTabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(10.h),
      child: CustomTabBar(
        tabController: _tabController,
        tabContents: _tabContents,
        onTabChanged: (index) => _tabController.animateTo(index),
      ),
    );
  }

  List<TabContent> get _tabContents {
    return [
      TabContent(
        title: 'Categories',
        icon: Icons.category_rounded,
        length: _filteredCategories.length.toString(),
      ),
      TabContent(
        title: 'Stars',
        icon: Icons.star_rounded,
        length: _filteredStars.length.toString(),
      ),
    ];
  }
}
