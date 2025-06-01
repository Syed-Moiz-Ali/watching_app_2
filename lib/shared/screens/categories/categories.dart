// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/services/source_manager.dart';
import 'package:watching_app_2/shared/screens/categories/components/category_card.dart';
import 'package:watching_app_2/shared/widgets/appbars/app_bar.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';
import '../../../data/models/category_model.dart';
import 'components/category_detail.dart';

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
        _filteredCategories = List.from(_categories);
      } else {
        _filteredCategories = _categories
            .where((category) => category.title
                .toLowerCase()
                .contains(query)) // Case-insensitive search
            .toList();
      }
    });
  }

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
                ),
                child: CategoryCard(
                  category: category,
                  index: index,
                  onTap: (index) => _onCategoryTap(index),
                ),
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

  void _onCategoryTap(int index) {
    // Enhanced haptic feedback
    HapticFeedback.mediumImpact();

    // Premium navigation transition
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PremiumCategoryDetailScreen(
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
        },
      ),
      body: Stack(
        children: [
          SafeArea(
            child: _isLoading
                ? _buildShimmerLoading()
                : CustomPadding(
                    horizontalFactor: .04,
                    topFactor: .02,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
