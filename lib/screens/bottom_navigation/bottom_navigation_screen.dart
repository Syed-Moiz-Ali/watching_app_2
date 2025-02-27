import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/provider/bottom_navigation_provider.dart';
import 'package:watching_app_2/screens/categories_screen/categories_screen.dart';
import 'package:watching_app_2/screens/source_list/source_list_screen.dart';
import 'package:watching_app_2/widgets/text_widget.dart';

import '../browse_content/browse_content.dart';
import '../settings/settings_screen.dart';

// Create a provider class to manage the navigation state

class UltraPremiumNavBar extends StatefulWidget {
  final List<String> labels;
  final List<IconData> icons;
  final Color? accentColor;
  final Color? backgroundColor;
  final bool enableBlur;

  const UltraPremiumNavBar({
    super.key,
    this.labels = const [
      'Home',
      'Categories',
      'Websites',
      'Favorites',
      'Profile'
    ],
    this.icons = const [
      Icons.home_rounded,
      Icons.category_rounded,
      Icons.language_rounded,
      Icons.favorite_rounded,
      Icons.person_rounded
    ],
    this.accentColor,
    this.backgroundColor,
    this.enableBlur = true,
  });

  @override
  State<UltraPremiumNavBar> createState() => _UltraPremiumNavBarState();
}

class _UltraPremiumNavBarState extends State<UltraPremiumNavBar>
    with TickerProviderStateMixin {
  // Animation controllers for each animation type
  late final AnimationController _entryAnimController;
  late final AnimationController _pulseAnimController;
  late final List<AnimationController> _iconAnimControllers;
  late final AnimationController _indicatorAnimController;
  late final List<AnimationController> _hoverControllers;

  // Animations
  late final Animation<double> _entryAnimation;
  late final Animation<double> _pulseAnimation;
  late final List<Animation<double>> _iconScaleAnimations;
  late final List<Animation<double>> _iconRotateAnimations;
  late final List<Animation<double>> _iconOpacityAnimations;
  late Animation<Offset> _indicatorPosition;
  late Animation<double> _indicatorWidth;
  late final List<Animation<double>> _hoverAnimations;

  // Other state variables
  int _previousIndex = 0;
  bool _didInitializeAnimations = false;

  @override
  void initState() {
    super.initState();
    final navProvider =
        Provider.of<BottomNavigationProvider>(context, listen: false);
    _previousIndex = navProvider.currentIndex;
    _initializeAnimations();
    _didInitializeAnimations = true;

    // Start entry animation
    _entryAnimController.forward();

    // Start pulse animation for continuous effect
    _pulseAnimController.repeat(reverse: true);

    // Initialize current tab animation
    _iconAnimControllers[navProvider.currentIndex].forward();

    // Position the indicator at the current index
    _updateIndicatorPosition(navProvider.currentIndex, animate: false);
  }

  void _initializeAnimations() {
    // Entry animation (bottom to top with bounce)
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entryAnimation = CurvedAnimation(
      parent: _entryAnimController,
      curve: Curves.elasticOut,
    );

    // Subtle background pulse animation
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimController,
        curve: Curves.easeInOut,
      ),
    );

    // Icon animations for each tab
    _iconAnimControllers = List.generate(
      widget.icons.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    // Multiple animations per icon for rich visual effect
    _iconScaleAnimations = _iconAnimControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutBack,
            ),
          ),
        )
        .toList();

    _iconRotateAnimations = _iconAnimControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 0.05).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOutSine,
            ),
          ),
        )
        .toList();

    _iconOpacityAnimations = _iconAnimControllers
        .map(
          (controller) => Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOut,
            ),
          ),
        )
        .toList();

    // Sliding indicator animation
    _indicatorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initial indicator setup will happen in updateIndicatorPosition
    _indicatorPosition = Tween<Offset>(
      begin: Offset(_previousIndex.toDouble(), 0),
      end: Offset(_previousIndex.toDouble(), 0),
    ).animate(
      CurvedAnimation(
        parent: _indicatorAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _indicatorWidth = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _indicatorAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Hover animations
    _hoverControllers = List.generate(
      widget.icons.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _hoverAnimations = _hoverControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOut,
            ),
          ),
        )
        .toList();
  }

  void _updateIndicatorPosition(int index, {bool animate = true}) {
    // Update the indicator position animation
    _indicatorPosition = Tween<Offset>(
      begin: Offset(_previousIndex.toDouble(), 0),
      end: Offset(index.toDouble(), 0),
    ).animate(
      CurvedAnimation(
        parent: _indicatorAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Update indicator width for stretch effect
    _indicatorWidth = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_indicatorAnimController);

    if (animate) {
      _indicatorAnimController.reset();
      _indicatorAnimController.forward();
    }

    _previousIndex = index;
  }

  @override
  void dispose() {
    _entryAnimController.dispose();
    _pulseAnimController.dispose();
    for (final controller in _iconAnimControllers) {
      controller.dispose();
    }
    for (final controller in _hoverControllers) {
      controller.dispose();
    }
    _indicatorAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final accentColor = widget.accentColor ?? theme.primaryColor;
    final backgroundColor = widget.backgroundColor ??
        (isDarkMode
            ? Colors.grey[900]!.withOpacity(0.7)
            : Colors.white.withOpacity(0.7));

    final itemWidth = 95.w / widget.icons.length;

    return Consumer<BottomNavigationProvider>(
      builder: (context, navProvider, child) {
        // Check if the index has changed since our last build
        if (_previousIndex != navProvider.currentIndex &&
            _didInitializeAnimations) {
          // Reverse previous animation
          _iconAnimControllers[_previousIndex].reverse();

          // Start new animation
          _iconAnimControllers[navProvider.currentIndex].forward();

          // Update indicator position
          _updateIndicatorPosition(navProvider.currentIndex);

          // Haptic feedback
          HapticFeedback.mediumImpact();
        }

        return AnimatedBuilder(
          animation: Listenable.merge([_entryAnimation, _pulseAnimation]),
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.h),
              child: Transform.translate(
                offset: Offset(0, 100 * (1 - _entryAnimation.value)),
                child: Transform.scale(
                  scale: 0.97 + (0.03 * _entryAnimation.value),
                  child: child,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: widget.enableBlur
                  ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated indicator
                    AnimatedBuilder(
                      animation: _indicatorAnimController,
                      builder: (context, _) {
                        return Positioned(
                          bottom: 0,
                          left: _indicatorPosition.value.dx * itemWidth +
                              (itemWidth -
                                      (itemWidth *
                                          0.6 *
                                          _indicatorWidth.value)) /
                                  2,
                          child: Container(
                            width: itemWidth * 0.6 * _indicatorWidth.value,
                            height: 0.4.h,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Navigation items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        widget.icons.length,
                        (index) => _buildNavItem(
                          index,
                          widget.icons[index],
                          widget.labels[index],
                          accentColor,
                          isDarkMode,
                          hasNotification:
                              navProvider.hasNotification && index == 3,
                          isSelected: navProvider.currentIndex == index,
                          onTap: () => navProvider.setIndex(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color accentColor,
    bool isDarkMode, {
    required bool hasNotification,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Calculate base colors
    final baseColor = isDarkMode ? Colors.white : Colors.grey[800]!;
    final selectedColor = accentColor;
    final unselectedColor = baseColor.withOpacity(0.7);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _hoverControllers[index].forward(),
        onExit: (_) => _hoverControllers[index].reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _iconAnimControllers[index],
            _hoverControllers[index],
          ]),
          builder: (context, _) {
            final scaleValue = _iconScaleAnimations[index].value;
            final rotateValue = _iconRotateAnimations[index].value;
            final opacityValue = _iconOpacityAnimations[index].value;
            final hoverValue = _hoverAnimations[index].value;

            final currentColor = isSelected
                ? selectedColor
                : Color.lerp(unselectedColor, selectedColor, hoverValue)!;

            return Container(
              width: 90.w / widget.icons.length,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                // color: isSelected || hoverValue > 0
                //     ? (isDarkMode
                //         ? selectedColor
                //             .withOpacity(0.1 * (isSelected ? 1.0 : hoverValue))
                //         : selectedColor.withOpacity(
                //             0.08 * (isSelected ? 1.0 : hoverValue)))
                //     : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animations
                  SizedBox(
                    height: 6.h,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Icon ripple effect (on selected)
                        if (isSelected)
                          AnimatedBuilder(
                            animation: _pulseAnimController,
                            builder: (context, _) {
                              return Opacity(
                                opacity: 0.1 + (0.05 * _pulseAnimation.value),
                                child: Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 12.w,
                                    height: 12.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selectedColor.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // Main icon
                        Transform.scale(
                          scale: scaleValue,
                          child: Transform.rotate(
                            angle: rotateValue,
                            child: Icon(
                              icon,
                              color: currentColor,
                              size: 6.5.w,
                            ),
                          ),
                        ),

                        // Notification indicator
                        if (hasNotification)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
                                  width: 0.3.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Label
                  Opacity(
                    opacity: opacityValue,
                    child: TextWidget(
                      text: label,
                      color: currentColor,
                      fontSize: 13.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Usage Example
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BottomNavigationProvider()..setNotification(true),
      child: const _NavigationExampleContent(),
    );
  }
}

class _NavigationExampleContent extends StatelessWidget {
  const _NavigationExampleContent();

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavigationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      extendBody: true,
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: [
          const BrowseContent(),
          const AdultContentCategoriesScreen(),
          // _buildPage('Categories Page', Colors.teal),
          // _buildPage('Websites Page', Colors.blue),
          const SourceListScreen(),
          _buildPage('Favorites Page', Colors.redAccent),
          const PremiumSettingsScreen(),
        ],
      ),
      bottomNavigationBar: const UltraPremiumNavBar(
        accentColor:
            AppColors.secondaryColor, // Change to match your brand color
        enableBlur: true,
      ),
    );
  }

  Widget _buildPage(String title, Color color) {
    return Container(
      color: color.withOpacity(0.2),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
