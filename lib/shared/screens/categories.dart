// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/navigation/app_navigator.dart';
import 'package:watching_app_2/core/navigation/routes.dart';

import 'package:watching_app_2/core/services/source_manager.dart';
import 'package:watching_app_2/shared/widgets/appbars/app_bar.dart';
import 'package:watching_app_2/shared/widgets/misc/image.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';

import '../../data/models/category_model.dart';
import '../../presentation/provider/search_provider.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardsController;
  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = []; // Filtered list

  final List<AnimationController> _hoverControllers = [];
  bool _isLoading = true;
  late AnimationController _shimmerController;

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardsController.dispose();
    _shimmerController.dispose();
    for (var controller in _hoverControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Enhanced background animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _backgroundController.repeat(reverse: true);

    // Enhanced cards animation
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Shimmer loading effect controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _shimmerController.repeat();

    // Fetch data with enhanced loading state
    fetchCategories();

    // Delayed animation start with smoother timing
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate minimum loading time for smooth transitions
    await Future.delayed(const Duration(milliseconds: 800));
    final loadedCategories = await SourceManager().loadCategories();

    if (mounted) {
      setState(() {
        _categories = loadedCategories;
        _filteredCategories =
            List.from(loadedCategories); // Initially show all categories

        _isLoading = false;
      });

      // Initialize hover controllers for each category
      for (int i = 0; i < _categories.length; i++) {
        _hoverControllers.add(AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 180),
        ));
      }
    }
  }

  void _filterCategories(String query) {
    // String query = .text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredCategories =
            List.from(_categories); // ✅ Show all data when query is empty
      } else {
        _filteredCategories = _categories
            .where((category) => category.title
                .toLowerCase()
                .contains(query)) // Case-insensitive search
            .toList();
      }
    });
  }

  // Premium badge widget
  // ignore: unused_element
  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red[900]!.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user,
              size: 16, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 8),
          TextWidget(
            text: 'PREMIUM',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ],
      ),
    );
  }

  // Enhanced animated background

  // Shimmer loading effect
  Widget _buildShimmerLoading() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPadding(
          horizontalFactor: .04,
          topFactor: .02,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title shimmer
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.grey[800]!,
                      Colors.grey[600]!,
                      Colors.grey[800]!,
                    ],
                    stops: [
                      0.0,
                      _shimmerController.value,
                      1.0,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),

              // Grid shimmer
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[900]!,
                            Colors.grey[800]!,
                            Colors.grey[900]!,
                          ],
                          stops: [
                            0.0,
                            _shimmerController.value,
                            1.0,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Enhanced animated category card
  Widget _buildAnimatedCategoryCard(int index) {
    // Staggered animation for each grid item
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        // Stagger the animation based on index with improved timing
        final double delayedStart = 0.05 + (index * 0.06);
        final Animation<double> delayedAnimation = CurvedAnimation(
          parent: _cardsController,
          curve: Interval(
            delayedStart.clamp(0.0, 1.0),
            (delayedStart + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        );

        // Multi-layered entrance animation with enhanced physics
        return Transform.translate(
          offset: Offset(0.0, 40 * (1.0 - delayedAnimation.value)),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: Transform.scale(
              scale: 0.92 + (0.08 * delayedAnimation.value),
              child: child,
            ),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHoverStart(index),
        onExit: (_) => _onHoverEnd(index),
        child: AnimatedBuilder(
          animation: _hoverControllers[index],
          builder: (context, child) {
            var category = _filteredCategories[index];
            // Enhanced hover effect with subtle lift and glow
            return Transform.scale(
              scale: 1.0 + (0.05 * _hoverControllers[index].value),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                          0.2 + (0.2 * _hoverControllers[index].value)),
                      blurRadius: 8 + (8 * _hoverControllers[index].value),
                      spreadRadius: 2 + (2 * _hoverControllers[index].value),
                    ),
                  ],
                ),
                child: _buildCategoryCard(category, index),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onHoverStart(int index) {
    _hoverControllers[index].forward();
    HapticFeedback.selectionClick();
  }

  void _onHoverEnd(int index) {
    _hoverControllers[index].reverse();
  }

  // Enhanced category card
  Widget _buildCategoryCard(CategoryModel category, int index) {
    return Hero(
      tag: 'category_${category.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCategoryTap(index),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white10,
          highlightColor: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image with enhanced effects
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: _hoverControllers[index],
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Image with subtle zoom effect on hover
                        Transform.scale(
                          scale: 1.0 + (0.1 * _hoverControllers[index].value),
                          child: CustomImageWidget(
                            imagePath: category.image,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Enhanced gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3 +
                                    (0.3 * _hoverControllers[index].value)),
                                Colors.black.withOpacity(0.7 +
                                    (0.1 * _hoverControllers[index].value)),
                              ],
                              stops: const [0.0, 0.5, 0.9],
                            ),
                          ),
                        ),

                        // Premium indicator
                        Positioned(
                          top: 12,
                          right: 12,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _hoverControllers[index].value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextWidget(
                                text: 'PREMIUM',
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Content with enhanced typography
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Dynamic subtitle animation
                    AnimatedBuilder(
                      animation: _hoverControllers[index],
                      builder: (context, child) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _hoverControllers[index].value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextWidget(
                              text: 'Exclusive Content',
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),

                    // Title with enhanced styling
                    TextWidget(
                      text: category.title,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),

                    // View count indicator
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          color: Colors.white.withOpacity(0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        TextWidget(
                          text: '${(index + 1) * 1250}+ views',
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Animated overlay for hover interaction
              AnimatedBuilder(
                animation: _hoverControllers[index],
                builder: (context, child) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _hoverControllers[index].value * 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(int index) {
    // Enhanced haptic feedback
    HapticFeedback.mediumImpact();

    // Premium navigation transition
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) {
          return EnhancedCategoryDetailScreen(
            category: _filteredCategories[index],
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuint,
          );

          return Stack(
            children: [
              // Fade in background
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
                  ),
                ),
                child: Container(
                  color: Colors.black,
                ),
              ),
              // Enhanced slide up with subtle scale
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.98,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        elevation: 0,
        // backgroundColor: Colors.transparent,
        title: 'Explore',
        isShowSearchbar: true,
        onChanged: (value) {
          _filterCategories(value);
          // searchVideos(value);
        },
      ),
      body: Stack(
        children: [
          // Enhanced animated background
          // _buildAnimatedBackground(),

          // Elegant overlay gradient
          // _buildOverlayGradient(),

          // Main content
          SafeArea(
            child: _isLoading
                ? _buildShimmerLoading()
                : CustomPadding(
                    horizontalFactor: .04,
                    topFactor: .02,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium section title
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 16, left: 4),
                        //   child: TextWidget(
                        //     text: 'Premium Collections',
                        //     fontSize: 18.sp,
                        //     fontWeight: FontWeight.w600,
                        //     color: Colors.white,
                        //   ),
                        // ),

                        // Enhanced grid view
                        Expanded(
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _filteredCategories.length,
                            itemBuilder: (context, index) {
                              return _buildAnimatedCategoryCard(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Enhanced category detail screen with premium styling
class EnhancedCategoryDetailScreen extends StatefulWidget {
  const EnhancedCategoryDetailScreen({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  State<EnhancedCategoryDetailScreen> createState() =>
      _EnhancedCategoryDetailScreenState();
}

class _EnhancedCategoryDetailScreenState
    extends State<EnhancedCategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    // Start entrance animation
    _animationController.forward();
  }

  // Helper method to build stat items
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        TextWidget(
          text: text,
          fontSize: 14.sp,
          color: Colors.white.withOpacity(0.7),
        ),
      ],
    );
  }

  // Helper method to build gradient button
  Widget _buildGradientButton(String text, IconData icon, bool isPrimary) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        context.read<SearchProvider>().setAllCategoryResults({});
        NH.nameNavigateTo(AppRoutes.searchResult,
            arguments: {"query": widget.category.title.toLowerCase()});
        // Action functionality
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPrimary
                ? [Colors.blue[700]!, Colors.blue[900]!]
                : [Colors.grey[800]!, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              TextWidget(
                text: text,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build circle buttons
  Widget _buildCircleButton(IconData icon) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {
          HapticFeedback.lightImpact();
          // Action functionality
        },
      ),
    );
  }

  // Helper method to build review items

  @override
  Widget build(BuildContext context) {
    // Parallax effect calculations
    final parallaxOffset = _scrollOffset * 0.4;
    final headerOpacity = (1 - (_scrollOffset / 150).clamp(0.0, 1.0));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Bookmark functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Share functionality
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Parallax background image
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -parallaxOffset),
                  child: Hero(
                    tag: 'category_${widget.category.id}',
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: CustomImageWidget(
                        imagePath: widget.category.image,
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: double.infinity,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Premium gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.85],
                ),
              ),
            ),

            // Main content
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Staggered animations for content elements
                final titleAnimation = CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
                );

                final subtitleAnimation = CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                );

                final buttonAnimation = CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                );

                final contentAnimation = CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                );

                return ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Header space
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4),

                    // Header info with parallax effect
                    Opacity(
                      opacity: headerOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Premium badge
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.4),
                                end: Offset.zero,
                              ).animate(subtitleAnimation),
                              child: FadeTransition(
                                opacity: subtitleAnimation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red[700]!,
                                        Colors.red[900]!
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: TextWidget(
                                    text: 'EXCLUSIVE PREMIUM',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title with animation
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(titleAnimation),
                              child: FadeTransition(
                                opacity: titleAnimation,
                                child: TextWidget(
                                  text: widget.category.title,
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Stats row
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(subtitleAnimation),
                              child: FadeTransition(
                                opacity: subtitleAnimation,
                                child: Row(
                                  children: [
                                    _buildStatItem(
                                        Icons.visibility, '10.2K views'),
                                    const SizedBox(width: 20),
                                    _buildStatItem(Icons.star, '4.8 rating'),
                                    const SizedBox(width: 20),
                                    _buildStatItem(
                                        Icons.access_time, 'Updated daily'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Action buttons
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(buttonAnimation),
                              child: FadeTransition(
                                opacity: buttonAnimation,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildGradientButton(
                                        'Explore Now',
                                        Icons.play_arrow,
                                        true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildCircleButton(Icons.add),
                                    const SizedBox(width: 12),
                                    _buildCircleButton(Icons.bookmark_border),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Content sections
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(contentAnimation),
                      child: FadeTransition(
                        opacity: contentAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // About section
                              TextWidget(
                                text: 'About This Collection',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              TextWidget(
                                text:
                                    'Experience our exclusive premium collection featuring the best ${widget.category.title.toLowerCase()} content. Updated daily with carefully curated material for our premium members.',
                                fontSize: 16.sp,
                                maxLine: 10,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(height: 30),

                              // // Featured section
                              //  TextWidget(text:
                              //   'Featured Content',

                              //     fontSize: 20.sp,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.white,

                              // ),
                              // const SizedBox(height: 16),

                              // // Featured items grid
                              // SizedBox(
                              //   height: 200,
                              //   child: ListView.builder(
                              //     scrollDirection: Axis.horizontal,
                              //     physics: const BouncingScrollPhysics(),
                              //     itemCount: 4,
                              //     itemBuilder: (context, index) {
                              //       return Container(
                              //         width: 160,
                              //         margin: const EdgeInsets.only(right: 16),
                              //         decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.circular(16),
                              //           image: DecorationImage(
                              //             image: NetworkImage(
                              //               'https://picsum.photos/200/300?random=$index',
                              //             ),
                              //             fit: BoxFit.cover,
                              //           ),
                              //         ),
                              //         child: Container(
                              //           decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(16),
                              //             gradient: LinearGradient(
                              //               begin: Alignment.topCenter,
                              //               end: Alignment.bottomCenter,
                              //               colors: [
                              //                 Colors.transparent,
                              //                 Colors.black.withOpacity(0.8),
                              //               ],
                              //             ),
                              //           ),
                              //           padding: const EdgeInsets.all(12),
                              //           child: Column(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.end,
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               TextWidget(text:
                              //                 'Item ${index + 1}',
                              //                 style: const TextStyle(
                              //                   fontSize: 16,
                              //                   fontWeight: FontWeight.bold,
                              //                   color: Colors.white,
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 4),
                              //               TextWidget(text:
                              //                 'Premium content',
                              //                 style: TextStyle(
                              //                   fontSize: 12,
                              //                   color: Colors.white
                              //                       .withOpacity(0.7),
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // ),
                              const SizedBox(height: 30),

                              // Reviews section
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //      TextWidget(text:
                              //       'User Reviews',

                              //         fontSize: 20.sp,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.white,

                              //     ),
                              //     TextButton(
                              //       onPressed: () {},
                              //       child: const TextWidget(text:
                              //         'See All',
                              //         style: TextStyle(
                              //           color: Colors.blue,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(height: 16),

                              // // Review items
                              // _buildReviewItem(
                              //   'Emily Johnson',
                              //   'https://picsum.photos/200/300?random=10',
                              //   'Absolutely love this premium content! Worth every penny of my subscription.',
                              //   4.8,
                              // ),
                              // const SizedBox(height: 16),
                              // _buildReviewItem(
                              //   'Michael Smith',
                              //   'https://picsum.photos/200/300?random=11',
                              //   'High quality content that keeps me coming back. Daily updates are fantastic.',
                              //   4.5,
                              // ),

                              // const SizedBox(height: 50),

                              // // Related categories
                              // const TextWidget(text:
                              //   'You May Also Like',
                              //   style: TextStyle(
                              //     fontSize: 20,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              // const SizedBox(height: 16),

                              // // Related categories grid
                              // GridView.builder(
                              //   shrinkWrap: true,
                              //   physics: const NeverScrollableScrollPhysics(),
                              //   gridDelegate:
                              //       const SliverGridDelegateWithFixedCrossAxisCount(
                              //     crossAxisCount: 2,
                              //     childAspectRatio: 1.5,
                              //     crossAxisSpacing: 16,
                              //     mainAxisSpacing: 16,
                              //   ),
                              //   itemCount: 4,
                              //   itemBuilder: (context, index) {
                              //     return Container(
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(16),
                              //         image: DecorationImage(
                              //           image: NetworkImage(
                              //             'https://picsum.photos/200/300?random=${20 + index}',
                              //           ),
                              //           fit: BoxFit.cover,
                              //         ),
                              //       ),
                              //       child: Container(
                              //         decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.circular(16),
                              //           gradient: LinearGradient(
                              //             begin: Alignment.topCenter,
                              //             end: Alignment.bottomCenter,
                              //             colors: [
                              //               Colors.transparent,
                              //               Colors.black.withOpacity(0.7),
                              //             ],
                              //           ),
                              //         ),
                              //         padding: const EdgeInsets.all(12),
                              //         child: Align(
                              //           alignment: Alignment.bottomLeft,
                              //           child: TextWidget(text:
                              //             'Related ${index + 1}',
                              //             style: const TextStyle(
                              //               fontSize: 16,
                              //               fontWeight: FontWeight.bold,
                              //               color: Colors.white,
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // ),

                              // const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
