import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/presentation/provider/navigation_provider.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';

// Import your pages
import 'browse_content/browse_content.dart';
import 'categories/categories.dart';
import 'favorites/favorites.dart';
import 'settings.dart';
import 'sources/sources.dart';

class MinimalistNavBar extends StatefulWidget {
  final List<NavItem> items;
  final Color? accentColor;
  final Color? backgroundColor;
  final bool enableHaptics;
  final bool enableAnimations;
  final NavBarStyle style;

  const MinimalistNavBar({
    super.key,
    this.items = const [
      NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      NavItem(
          icon: Icons.grid_view_outlined,
          activeIcon: Icons.grid_view,
          label: 'Categories'),
      NavItem(
          icon: Icons.language_outlined,
          activeIcon: Icons.language,
          label: 'Sources'),
      NavItem(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: 'Favorites'),
      NavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile'),
    ],
    this.accentColor,
    this.backgroundColor,
    this.enableHaptics = true,
    this.enableAnimations = true,
    this.style = NavBarStyle.floating,
  });

  @override
  State<MinimalistNavBar> createState() => _MinimalistNavBarState();
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showBadge;
  final String? badgeText;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showBadge = false,
    this.badgeText,
  });
}

enum NavBarStyle { floating, docked, minimal }

class _MinimalistNavBarState extends State<MinimalistNavBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _indicatorController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  List<AnimationController> _itemControllers = [];
  List<Animation<double>> _itemAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    // Main slide animation for entry
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale animation for entry
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Indicator animation
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Individual item animations
    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 50)),
        vsync: this,
      ),
    );

    _itemAnimations = _itemControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOut),
          ),
        )
        .toList();
  }

  void _startEntryAnimation() async {
    // Staggered entry animation
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();

    // Animate items with stagger
    for (int i = 0; i < _itemControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      _itemControllers[i].forward();
    }
  }

  void _onItemTapped(int index) {
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    if (navProvider.currentIndex != index) {
      navProvider.setIndex(index);
      _animateIndicator(index);
    }
  }

  void _animateIndicator(int index) {
    _indicatorController.reset();
    _indicatorController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _indicatorController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentColor = widget.accentColor ?? AppColors.primaryColor;
    final backgroundColor = widget.backgroundColor ??
        (isDark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.9));

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        return AnimatedBuilder(
          animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildNavBar(
                    context, navProvider, accentColor, backgroundColor, isDark),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavBar(BuildContext context, NavigationProvider navProvider,
      Color accentColor, Color backgroundColor, bool isDark) {
    switch (widget.style) {
      case NavBarStyle.floating:
        return _buildFloatingNavBar(
            context, navProvider, accentColor, backgroundColor, isDark);
      case NavBarStyle.docked:
        return _buildDockedNavBar(
            context, navProvider, accentColor, backgroundColor, isDark);
      case NavBarStyle.minimal:
        return _buildMinimalNavBar(
            context, navProvider, accentColor, backgroundColor, isDark);
    }
  }

  Widget _buildFloatingNavBar(
      BuildContext context,
      NavigationProvider navProvider,
      Color accentColor,
      Color backgroundColor,
      bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 10.h,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: _buildNavItems(navProvider, accentColor, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildDockedNavBar(
      BuildContext context,
      NavigationProvider navProvider,
      Color accentColor,
      Color backgroundColor,
      bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 9.h,
          child: _buildNavItems(navProvider, accentColor, isDark),
        ),
      ),
    );
  }

  Widget _buildMinimalNavBar(
      BuildContext context,
      NavigationProvider navProvider,
      Color accentColor,
      Color backgroundColor,
      bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Container(
        height: 9.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: _buildNavItems(navProvider, accentColor, isDark),
      ),
    );
  }

  Widget _buildNavItems(
      NavigationProvider navProvider, Color accentColor, bool isDark) {
    return Stack(
      children: [
        // Animated indicator
        // AnimatedBuilder(
        //   animation: _indicatorAnimation,
        //   builder: (context, _) {
        //     final itemWidth = 100.w / widget.items.length;
        //     return Positioned(
        //       top: 1.h,
        //       left: navProvider.currentIndex *
        //               itemWidth /
        //               widget.items.length *
        //               100.w /
        //               100 +
        //           itemWidth * 0.2,
        //       child: AnimatedContainer(
        //         duration: const Duration(milliseconds: 300),
        //         width: itemWidth * 0.6,
        //         height: 0.5.h,
        //         decoration: BoxDecoration(
        //           color: accentColor,
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //       ),
        //     );
        //   },
        // ),

        // Navigation items
        Row(
          children: List.generate(widget.items.length, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedBuilder(
                  animation: _itemAnimations[index],
                  builder: (context, _) {
                    return Transform.translate(
                      offset:
                          Offset(0, 20 * (1 - _itemAnimations[index].value)),
                      child: Opacity(
                        opacity: _itemAnimations[index].value,
                        child: _buildNavItem(
                          index,
                          widget.items[index],
                          navProvider.currentIndex == index,
                          accentColor,
                          isDark,
                          navProvider.hasNotification && index == 3,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, NavItem item, bool isSelected,
      Color accentColor, bool isDark, bool hasNotification) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with badge
          SizedBox(
            height: 5.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? accentColor
                        : (isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey[600]),
                    size: isSelected ? 6.w : 5.5.w,
                  ),
                ),

                // Notification badge
                if (hasNotification || item.showBadge)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      constraints:
                          BoxConstraints(minWidth: 3.w, minHeight: 3.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 1,
                        ),
                      ),
                      child: item.badgeText != null
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              child: TextWidget(
                                text: item.badgeText!,
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),

          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600]),
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            child: TextWidget(
              text: item.label,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Navigation Screen with advanced features
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with WidgetsBindingObserver {
  late NavigationProvider _navProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _navProvider = NavigationProvider();
    _setupAdvancedFeatures();
  }

  void _setupAdvancedFeatures() {
    // Simulate notification system
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _navProvider.setNotification(true);
    });

    // Auto-clear notifications when favorites tab is visited
    _navProvider.addListener(() {
      if (_navProvider.currentIndex == 3 && _navProvider.hasNotification) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _navProvider.setNotification(false);
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Advanced feature: Handle app lifecycle
    switch (state) {
      case AppLifecycleState.paused:
        // Save current state when app goes to background
        break;
      case AppLifecycleState.resumed:
        // Restore state when app comes to foreground
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _navProvider,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey[50],
        extendBody: true,
        body: Consumer<NavigationProvider>(
          builder: (context, navProvider, _) {
            return IndexedStack(
              index: navProvider.currentIndex,
              children: const [
                BrowseContent(),
                Categories(),
                Sources(),
                Favorites(),
                Settings(),
              ],
            );
          },
        ),
        bottomNavigationBar: MinimalistNavBar(
          accentColor: AppColors.primaryColor,
          style: NavBarStyle.docked, // Change to docked or minimal as needed
          items: [
            const NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home'),
            const NavItem(
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view,
                label: 'Categories'),
            const NavItem(
                icon: Icons.language_outlined,
                activeIcon: Icons.language,
                label: 'Sources'),
            NavItem(
              icon: Icons.favorite_outline,
              activeIcon: Icons.favorite,
              label: 'Favorites',
              showBadge: _navProvider.hasNotification,
            ),
            const NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
