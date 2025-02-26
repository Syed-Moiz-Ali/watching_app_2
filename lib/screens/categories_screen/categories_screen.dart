import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/services/source_manager.dart';
import 'package:watching_app_2/widgets/custom_appbar.dart';
import 'package:watching_app_2/widgets/custom_image_widget.dart';
import 'package:watching_app_2/widgets/custom_padding.dart';
import 'package:watching_app_2/widgets/text_widget.dart';

import '../../models/categories_model.dart';

class AdultContentCategoriesScreen extends StatefulWidget {
  const AdultContentCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AdultContentCategoriesScreenState createState() =>
      _AdultContentCategoriesScreenState();
}

class _AdultContentCategoriesScreenState
    extends State<AdultContentCategoriesScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardsController;
  late Animation<double> _backgroundAnimation;

  // Adult content categories with appropriate icons, themes, and background images
  List<CategoryModel> _categories = [];

  // Track card hover state
  int? _hoveredIndex;
  final List<AnimationController> _hoverControllers = [];

  @override
  void initState() {
    super.initState();

    // Create animation for background
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _backgroundAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_backgroundController);

    // Repeat the background animation indefinitely
    _backgroundController.repeat();

    // Animation for cards appearance
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    fetchCategories();
    // Create hover animation controllers for each card

    // Start with a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsController.forward();
    });
  }

  fetchCategories() async {
    final loadedCategories = await SourceManager().loadCategories();
    setState(() {
      _categories = loadedCategories;
    });
    for (int i = 0; i < _categories.length; i++) {
      _hoverControllers.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      ));
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardsController.dispose();
    for (var controller in _hoverControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      // extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        elevation: 0,
        // backgroundColor: Colors.transparent,
        title: 'Explore',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 26),
            onPressed: () {},
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[700]!, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text(
                  '18+',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          // AnimatedBuilder(
          //   animation: _backgroundAnimation,
          //   builder: (context, child) {
          //     return Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //           colors: [
          //             Color(0xFF1A1A1A),
          //             Color(0xFF0D0D0D),
          //           ],
          //           stops: [0.3, 0.7],
          //           transform: GradientRotation(
          //               _backgroundAnimation.value * 0.5 * 3.14),
          //         ),
          //       ),
          //     );
          //   },
          // ),

          // Content
          SafeArea(
            child: _categories.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : CustomPadding(
                    horizontalFactor: .02,
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
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: .9,
                            ),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              // Staggered animation for each grid item
                              return AnimatedBuilder(
                                animation: _cardsController,
                                builder: (context, child) {
                                  // Stagger the animation based on index
                                  final double delayedStart =
                                      0.05 + (index * 0.08);
                                  final Animation<double> delayedAnimation =
                                      CurvedAnimation(
                                    parent: _cardsController,
                                    curve: Interval(
                                      delayedStart.clamp(0.0, 1.0),
                                      (delayedStart + 0.2).clamp(0.0, 1.0),
                                      curve: Curves.easeOutCubic,
                                    ),
                                  );

                                  // Create a multi-layered entrance animation
                                  return Transform.translate(
                                    offset: Offset(0.0,
                                        30 * (1.0 - delayedAnimation.value)),
                                    child: Opacity(
                                      opacity: delayedAnimation.value,
                                      child: Transform.scale(
                                        scale: 0.95 +
                                            (0.05 * delayedAnimation.value),
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
                                      // Apply card hover effect animation
                                      var category = _categories[index];
                                      return Transform.scale(
                                        scale: 1.0 +
                                            (0.03 *
                                                _hoverControllers[index].value),
                                        child:
                                            _buildCategoryCard(category, index),
                                      );
                                    },
                                  ),
                                ),
                              );
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

  void _onHoverStart(int index) {
    setState(() {
      _hoveredIndex = index;
    });
    _hoverControllers[index].forward();
  }

  void _onHoverEnd(int index) {
    setState(() {
      _hoveredIndex = null;
    });
    _hoverControllers[index].reverse();
  }

  Widget _buildCategoryCard(CategoryModel category, int index) {
    return Hero(
      tag: 'category_${category.id}',
      child: InkWell(
        onTap: () => _onCategoryTap(index),
        borderRadius: BorderRadius.circular(16),
        // splashColor: Colors.white10,
        // highlightColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with animated filter
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimatedBuilder(
                animation: _hoverControllers[index],
                builder: (context, child) {
                  return Stack(
                    children: [
                      CustomImageWidget(
                        imagePath: category.image,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextWidget(
                    text: category.title,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Animated hover border

            // Arrow indicator on hover
          ],
        ),
      ),
    );
  }

  void _onCategoryTap(int index) {
    // Trigger haptic feedback
    HapticFeedback.mediumImpact();

    // Navigate with premium transition effect
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CategoryDetailScreen(
            category: _categories[index],
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
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                  ),
                ),
                child: Container(
                  color: Colors.black,
                ),
              ),
              // Slide up the destination page
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}

// Category detail screen with full-screen image
class CategoryDetailScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryDetailScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          category.title,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen background image
          Image.network(
            category.image,
            fit: BoxFit.cover,
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
                stops: [0.0, 0.5, 0.8],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Icon(
                //   category['icon'],
                //   size: 60,
                //   color: Colors.white.withOpacity(0.8),
                // ),
                // SizedBox(height: 24),
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Premium adult content',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: category['colors'],
                    //   begin: Alignment.centerLeft,
                    //   end: Alignment.centerRight,
                    // ),
                    borderRadius: BorderRadius.circular(28),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: category['colors'][0].withOpacity(0.5),
                    //     blurRadius: 16,
                    //     offset: Offset(0, 8),
                    //   ),
                    // ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      highlightColor: Colors.white10,
                      splashColor: Colors.white24,
                      onTap: () {},
                      child: const Center(
                        child: Text(
                          'Explore Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
