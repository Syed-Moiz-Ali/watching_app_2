import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'dart:math' as math;

import '../../../core/common/utils/common_widgets.dart';
import '../../../core/enums/enums.dart';
import '../../../presentation/provider/theme_provider.dart';
import '../misc/padding.dart';
import '../inputs/search_bar.dart';
import '../misc/text_widget.dart';

enum AppBarStyle {
  standard,
  collapsible,
  glassmorphic,
  gradient,
  dynamic,
  minimal,
  ultraMinimal,
  floating,
  breathingSpace,
  premium, // New enhanced style
  neuomorphic, // New style for depth
  glassPremium, // Enhanced glassmorphism
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.prefixIcon,
    this.elevation = 0.0,
    this.centerTitle = false,
    this.styleType,
    this.appBarStyle = AppBarStyle.premium,
    this.backgroundColor,
    this.gradientColors,
    this.bottom,
    this.appBarHeight = 68.0, // Optimized height
    this.automaticallyImplyLeading,
    this.isShowSearchbar = false,
    this.onSearch,
    this.onSearchClosed,
    this.onChanged,
    this.blurIntensity = 12.0,
    this.expandedHeight,
    this.shrinkOffset = 0.0,
    this.flexibleSpaceBackground,
    this.parallaxEffect = false,
    this.borderRadius,
    this.showBorder = false,
    this.borderColor,
    this.customLeading,
    this.pinnedToTop = false,
    this.onBackButtonPressed,
    this.searchHintText = 'Search...',
    this.searchBarBorderRadius = 28.0, // Enhanced radius
    this.customSearchBar,
    this.scrollController,
    this.collapsibleTitle,
    this.titleFadeAnimation = true,
    this.brightness,
    this.shadowColor,
    this.statusBarTransparent = true,
    this.minimalistSpacing = 24.0, // Premium spacing
    this.breathingRoom = true,
    this.perfectAlignment = true,
    this.premiumShadows = true, // New parameter
    this.enhancedAnimations = true, // New parameter
    this.microInteractions = true, // New parameter
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool? automaticallyImplyLeading;
  final bool centerTitle;
  final double elevation;
  final Widget? prefixIcon;
  final TextStyleType? styleType;
  final double appBarHeight;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final PreferredSizeWidget? bottom;
  final bool isShowSearchbar;
  final Function(String)? onSearch;
  final Function()? onSearchClosed;
  final Function(String)? onChanged;
  final double blurIntensity;
  final double? expandedHeight;
  final double shrinkOffset;
  final Widget? flexibleSpaceBackground;
  final bool parallaxEffect;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final Color? borderColor;
  final Widget? customLeading;
  final bool pinnedToTop;
  final VoidCallback? onBackButtonPressed;
  final String searchHintText;
  final double searchBarBorderRadius;
  final Widget? customSearchBar;
  final ScrollController? scrollController;
  final Widget? collapsibleTitle;
  final bool titleFadeAnimation;
  final Brightness? brightness;
  final Color? shadowColor;
  final bool statusBarTransparent;
  final AppBarStyle appBarStyle;

  // Enhanced minimalist design parameters
  final double minimalistSpacing;
  final bool breathingRoom;
  final bool perfectAlignment;
  final bool premiumShadows;
  final bool enhancedAnimations;
  final bool microInteractions;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late TextEditingController _searchController;

  // Enhanced animation controllers
  late AnimationController _searchAnimationController;
  late AnimationController _rotationController;
  late AnimationController _microInteractionController;
  late AnimationController _colorAnimationController;
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late AnimationController _rippleController;

  // Enhanced animations
  late Animation<double> _searchBarWidth;
  late Animation<double> _searchBarOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _rotation;
  late Animation<double> _microScale;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isSearchActive = false;

  // Enhanced variables for premium design
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;
  bool _isScrolled = false;
  final GlobalKey _appBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _initializeAnimations();
    _setupScrollController();
    _deferredInitialization();
  }

  void _initializeComponents() {
    _focusNode = FocusNode();
    _searchController = TextEditingController();
  }

  void _initializeAnimations() {
    // Enhanced search animation with premium easing
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _searchBarWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _searchBarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _titleOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutQuart),
      ),
    );

    // Enhanced micro-interaction animation
    _microInteractionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _microScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _microInteractionController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Premium rotation for search toggle
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _rotation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Enhanced breathing animation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.01).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Glow animation for premium effects
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Ripple animation for interactions
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Enhanced color animation
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Start ambient animations
    if (widget.appBarStyle == AppBarStyle.breathingSpace) {
      _breathingController.repeat(reverse: true);
    }

    if (widget.appBarStyle == AppBarStyle.premium ||
        widget.appBarStyle == AppBarStyle.glassPremium) {
      _glowController.repeat(reverse: true);
    }
  }

  void _setupScrollController() {
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _deferredInitialization() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeThemeDependentAnimations();
      _updateStatusBarStyle();
    });
  }

  void _initializeThemeDependentAnimations() {
    if (!mounted) return;

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.backgroundColor ?? _getPremiumBackgroundColor(),
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeOutQuart,
    ));
  }

  Color _getPremiumBackgroundColor() {
    if (!mounted) return Colors.transparent;

    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color(0xFF0F0F0F).withOpacity(0.95)
        : const Color(0xFFFBFBFB).withOpacity(0.95);
  }

  void _updateStatusBarStyle() {
    if (!mounted) return;
    // Status bar styling implementation
  }

  void _scrollListener() {
    if (!mounted) return;

    setState(() {
      _scrollPosition = _scrollController.offset;
      _isScrolled = _scrollPosition > 30;

      if (widget.appBarStyle == AppBarStyle.dynamic) {
        if (_isScrolled && !_colorAnimationController.isCompleted) {
          _colorAnimationController.forward();
        } else if (!_isScrolled && !_colorAnimationController.isDismissed) {
          _colorAnimationController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _disposeAnimations();
    _disposeComponents();
    super.dispose();
  }

  void _disposeAnimations() {
    _searchAnimationController.dispose();
    _rotationController.dispose();
    _microInteractionController.dispose();
    _breathingController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    _colorAnimationController.dispose();
  }

  void _disposeComponents() {
    _focusNode.dispose();
    _searchController.dispose();

    if (widget.scrollController == null) {
      _scrollController.removeListener(_scrollListener);
      _scrollController.dispose();
    }
  }

  void _toggleSearch() {
    if (widget.microInteractions) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _searchAnimationController.forward();
        _rotationController.forward();
        _focusNode.requestFocus();
        if (widget.enhancedAnimations) {
          _rippleController.forward();
        }
      } else {
        _searchAnimationController.reverse();
        _rotationController.reverse();
        _focusNode.unfocus();
        _searchController.clear();
        _rippleController.reset();
        if (widget.onSearchClosed != null) {
          widget.onSearchClosed!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, bool>(
      selector: (context, provider) => provider.isDarkTheme,
      builder: (context, isDarkTheme, _) {
        return _buildAppBarByStyle(context, isDarkTheme);
      },
    );
  }

  Widget _buildAppBarByStyle(BuildContext context, bool isDarkTheme) {
    switch (widget.appBarStyle) {
      case AppBarStyle.premium:
        return _buildPremiumAppBar(context, isDarkTheme);
      case AppBarStyle.neuomorphic:
        return _buildNeuomorphicAppBar(context, isDarkTheme);
      case AppBarStyle.glassPremium:
        return _buildGlassPremiumAppBar(context, isDarkTheme);
      case AppBarStyle.ultraMinimal:
        return _buildEnhancedUltraMinimalAppBar(context, isDarkTheme);
      case AppBarStyle.floating:
        return _buildEnhancedFloatingAppBar(context, isDarkTheme);
      case AppBarStyle.breathingSpace:
        return _buildEnhancedBreathingSpaceAppBar(context, isDarkTheme);
      case AppBarStyle.collapsible:
        return _buildCollapsibleAppBar(context, isDarkTheme);
      case AppBarStyle.glassmorphic:
        return _buildGlassmorphicAppBar(context, isDarkTheme);
      case AppBarStyle.gradient:
        return _buildGradientAppBar(context, isDarkTheme);
      case AppBarStyle.dynamic:
        return _buildDynamicAppBar(context, isDarkTheme);
      case AppBarStyle.minimal:
        return _buildMinimalAppBar(context, isDarkTheme);
      case AppBarStyle.standard:
      default:
        return _buildStandardAppBar(context, isDarkTheme);
    }
  }

  Widget _buildPremiumAppBar(BuildContext context, bool isDarkTheme) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getPremiumBackgroundColor(),
                _getPremiumBackgroundColor().withOpacity(0.8),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.08),
                width: 1,
              ),
            ),
            boxShadow: widget.premiumShadows
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkTheme ? 0.2 : 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                    if (widget.enhancedAnimations)
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(
                              0.05 * _glowAnimation.value,
                            ),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                  ]
                : null,
          ),
          child: SafeArea(
            child: Container(
              height: widget.appBarHeight,
              padding: EdgeInsets.symmetric(
                horizontal: widget.minimalistSpacing,
                vertical: widget.breathingRoom ? 12.0 : 8.0,
              ),
              child: _buildPremiumContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeuomorphicAppBar(BuildContext context, bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          // Outer shadow
          BoxShadow(
            color: isDarkTheme
                ? Colors.black.withOpacity(0.6)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(8, 8),
            spreadRadius: -2,
          ),
          // Inner shadow (highlight)
          BoxShadow(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(-8, -8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: widget.appBarHeight,
          padding: EdgeInsets.symmetric(
            horizontal: widget.minimalistSpacing,
            vertical: 12.0,
          ),
          child: _buildPremiumContent(context),
        ),
      ),
    );
  }

  Widget _buildGlassPremiumAppBar(BuildContext context, bool isDarkTheme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurIntensity,
          sigmaY: widget.blurIntensity,
        ),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (widget.backgroundColor ??
                            Theme.of(context).scaffoldBackgroundColor)
                        .withOpacity(0.1 + (0.05 * _glowAnimation.value)),
                    (widget.backgroundColor ??
                            Theme.of(context).scaffoldBackgroundColor)
                        .withOpacity(0.05 + (0.03 * _glowAnimation.value)),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(
                    isDarkTheme ? 0.1 : 0.2 + (0.1 * _glowAnimation.value),
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                  if (widget.enhancedAnimations)
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(
                            0.1 * _glowAnimation.value,
                          ),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                ],
              ),
              child: SafeArea(
                child: Container(
                  height: widget.appBarHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.minimalistSpacing,
                    vertical: 12.0,
                  ),
                  child: _buildPremiumContent(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedUltraMinimalAppBar(
      BuildContext context, bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: widget.appBarHeight,
          padding: EdgeInsets.symmetric(
            horizontal: widget.minimalistSpacing,
            vertical: widget.breathingRoom ? 12.0 : 8.0,
          ),
          child: _buildPremiumContent(context),
        ),
      ),
    );
  }

  Widget _buildEnhancedFloatingAppBar(BuildContext context, bool isDarkTheme) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: widget.minimalistSpacing,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardColor.withOpacity(0.95),
                Theme.of(context).cardColor.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkTheme ? 0.4 : 0.08),
                blurRadius: 25,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDarkTheme ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: widget.appBarHeight - 24,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildPremiumContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBreathingSpaceAppBar(
      BuildContext context, bool isDarkTheme) {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.03),
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              child: Container(
                height: widget.appBarHeight + (widget.breathingRoom ? 24 : 0),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.minimalistSpacing + 8,
                  vertical: widget.breathingRoom ? 20.0 : 12.0,
                ),
                child: _buildPremiumContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumContent(BuildContext context) {
    return Row(
      children: [
        if (widget.automaticallyImplyLeading == true && !_isSearchActive)
          _buildPremiumBackButton(),
        if (!_isSearchActive) ...[
          if (widget.automaticallyImplyLeading != true)
            SizedBox(width: widget.perfectAlignment ? 8.0 : 0),
          Expanded(child: _buildPremiumTitle()),
        ],
        if (_isSearchActive)
          Expanded(
            child: FadeTransition(
              opacity: _searchBarOpacity,
              child: ScaleTransition(
                scale: _searchBarWidth,
                child: _buildPremiumSearchBar(),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isShowSearchbar) _buildPremiumSearchToggle(),
            ...widget.actions.map((action) => Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: action,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumBackButton() {
    return GestureDetector(
      onTapDown: widget.microInteractions
          ? (_) => _microInteractionController.forward()
          : null,
      onTapUp: widget.microInteractions
          ? (_) => _microInteractionController.reverse()
          : null,
      onTapCancel: widget.microInteractions
          ? () => _microInteractionController.reverse()
          : null,
      onTap: () {
        if (widget.microInteractions) {
          HapticFeedback.lightImpact();
        }
        if (widget.onBackButtonPressed != null) {
          widget.onBackButtonPressed!();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: AnimatedBuilder(
        animation:
            widget.microInteractions ? _microScale : kAlwaysCompleteAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.microInteractions ? _microScale.value : 1.0,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.9),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumTitle() {
    return Column(
      crossAxisAlignment: widget.centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _titleOpacity,
          child: TextWidget(
            text: widget.title,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        if (widget.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: FadeTransition(
              opacity: _titleOpacity,
              child: TextWidget(
                text: widget.subtitle!,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumSearchBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardColor.withOpacity(0.9),
            Theme.of(context).cardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(widget.searchBarBorderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.searchBarBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSearch,
            style: SMA.baseTextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: widget.searchHintText,
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSearchToggle() {
    return GestureDetector(
      onTapDown: widget.microInteractions
          ? (_) => _microInteractionController.forward()
          : null,
      onTapUp: widget.microInteractions
          ? (_) => _microInteractionController.reverse()
          : null,
      onTapCancel: widget.microInteractions
          ? () => _microInteractionController.reverse()
          : null,
      onTap: _toggleSearch,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.microInteractions ? _microScale : kAlwaysCompleteAnimation,
          _rotation,
          widget.enhancedAnimations
              ? _rippleAnimation
              : kAlwaysCompleteAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.microInteractions ? _microScale.value : 1.0,
            child: Transform.rotate(
              angle: _rotation.value * 2 * math.pi,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple effect
                  if (widget.enhancedAnimations)
                    Transform.scale(
                      scale: _rippleAnimation.value * 2,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(
                                0.1 * (1 - _rippleAnimation.value),
                              ),
                        ),
                      ),
                    ),

                  // Main button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _isSearchActive
                          ? LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.15),
                                Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.08),
                              ],
                            )
                          : null,
                      color: _isSearchActive ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isSearchActive
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Theme.of(context).dividerColor.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: _isSearchActive
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isSearchActive
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      size: 20,
                      color: _isSearchActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).iconTheme.color?.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Add remaining methods from the original implementation
  Widget _buildStandardAppBar(BuildContext context, bool isDarkTheme) {
    // Implementation for standard app bar
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        boxShadow: widget.elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkTheme ? 0.2 : 0.04),
                  blurRadius: widget.elevation * 3,
                  offset: Offset(0, widget.elevation),
                  spreadRadius: 0,
                ),
              ]
            : null,
        borderRadius: widget.borderRadius,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ??
                    Theme.of(context).dividerColor.withOpacity(0.1),
                width: 0.5,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: _buildAppBarContent(context),
      ),
    );
  }

  Widget _buildGlassmorphicAppBar(BuildContext context, bool isDarkTheme) {
    // Implementation for glassmorphic app bar
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurIntensity,
          sigmaY: widget.blurIntensity,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: (widget.backgroundColor ?? Theme.of(context).primaryColor)
                .withOpacity(0.15),
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(isDarkTheme ? 0.1 : 0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkTheme ? 0.2 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: _buildAppBarContent(context),
        ),
      ),
    );
  }

  Widget _buildGradientAppBar(BuildContext context, bool isDarkTheme) {
    // Implementation for gradient app bar
    final List<Color> colors = widget.gradientColors ??
        [
          Theme.of(context).primaryColor.withOpacity(0.8),
          Theme.of(context).primaryColor.withOpacity(0.4),
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 1.0],
        ),
        borderRadius: widget.borderRadius,
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: _buildAppBarContent(context),
      ),
    );
  }

  Widget _buildDynamicAppBar(BuildContext context, bool isDarkTheme) {
    // Implementation for dynamic app bar
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            boxShadow: _isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkTheme ? 0.2 : 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ]
                : null,
            borderRadius: widget.borderRadius,
            border: _isScrolled
                ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: _buildAppBarContent(context),
          ),
        );
      },
    );
  }

  Widget _buildMinimalAppBar(BuildContext context, bool isDarkTheme) {
    // Implementation for minimal app bar
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          height: widget.appBarHeight,
          padding: EdgeInsets.symmetric(horizontal: widget.minimalistSpacing),
          child: _buildPremiumContent(context),
        ),
      ),
    );
  }

  Widget _buildCollapsibleAppBar(BuildContext context, bool isDarkTheme) {
    // Implementation for collapsible app bar
    final double appBarHeight = math.max(
      widget.appBarHeight - (widget.shrinkOffset * 0.3),
      kToolbarHeight,
    );

    final double opacity =
        (1.0 - (widget.shrinkOffset / (widget.expandedHeight ?? 200)))
            .clamp(0.0, 1.0);
    final double scale =
        (1.0 - (widget.shrinkOffset / (widget.expandedHeight ?? 400)))
            .clamp(0.8, 1.0);

    return Container(
      height: appBarHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor?.withOpacity(
              widget.shrinkOffset > 50 ? 0.95 : 0.0,
            ) ??
            _getPremiumBackgroundColor().withOpacity(
              widget.shrinkOffset > 50 ? 0.95 : 0.0,
            ),
        boxShadow: widget.shrinkOffset > 50
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkTheme ? 0.2 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ]
            : null,
        border: widget.shrinkOffset > 50
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          if (widget.parallaxEffect && widget.flexibleSpaceBackground != null)
            Positioned(
              top: -widget.shrinkOffset * 0.3,
              left: 0,
              right: 0,
              child: SizedBox(
                height: (widget.expandedHeight ?? 200),
                child: widget.flexibleSpaceBackground!,
              ),
            ),
          _buildAppBarContent(
            context,
            collapsibleHeight: appBarHeight,
            opacity: opacity,
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarContent(
    BuildContext context, {
    double? collapsibleHeight,
    double opacity = 1.0,
    double scale = 1.0,
    bool forcedTransparency = false,
  }) {
    return AppBar(
      key: _appBarKey,
      forceMaterialTransparency: forcedTransparency,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: collapsibleHeight ?? widget.appBarHeight,
      centerTitle: widget.centerTitle,
      leading: _isSearchActive
          ? null
          : widget.customLeading ??
              (widget.automaticallyImplyLeading == true
                  ? _buildBackButton()
                  : null),
      title: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: widget.titleFadeAnimation
                ? _titleOpacity
                : const AlwaysStoppedAnimation(1.0),
            child: SizedBox(
              height: collapsibleHeight ?? widget.appBarHeight,
              child: widget.appBarStyle == AppBarStyle.collapsible &&
                      widget.collapsibleTitle != null
                  ? Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: widget.collapsibleTitle,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: widget.centerTitle
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        if (!widget.centerTitle &&
                            widget.automaticallyImplyLeading != true &&
                            widget.customLeading == null)
                          const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: widget.centerTitle
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              _buildTitle(),
                              if (widget.subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: TextWidget(
                                    text: widget.subtitle!,
                                    styleType: TextStyleType.body2,
                                    textAlign: widget.centerTitle
                                        ? TextAlign.center
                                        : TextAlign.start,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (widget.isShowSearchbar)
            FadeTransition(
              opacity: _searchBarOpacity,
              child: ScaleTransition(
                scale: _searchBarWidth,
                child: widget.customSearchBar ??
                    PremiumSearchBar(
                      isShowSearchBar: widget.isShowSearchbar,
                      onSearch: (query) {
                        if (widget.onSearch != null) {
                          widget.onSearch!(query);
                          _toggleSearch();
                        }
                      },
                      onChanged: (query) {
                        if (widget.onChanged != null) {
                          widget.onChanged!(query);
                        }
                      },
                    ),
              ),
            ),
        ],
      ),
      actions: [
        if (widget.isShowSearchbar) _buildSearchToggle(),
        ...widget.actions,
      ],
      elevation: 0,
      bottom: widget.bottom,
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomPadding(
        leftFactor: .03,
        child: Hero(
          tag: 'back_button',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: widget.onBackButtonPressed ??
                  () {
                    Navigator.of(context).pop();
                  },
              child: CommonWidgets.navigationBackIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return TextWidget(
      text: widget.title,
      styleType: widget.styleType ?? TextStyleType.subheading,
      fontWeight: FontWeight.w700,
      textAlign: widget.centerTitle ? TextAlign.center : TextAlign.start,
    );
  }

  Widget _buildSearchToggle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_microScale, _rotation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _microScale.value,
          child: Transform.rotate(
            angle: _rotation.value * 2 * math.pi,
            child: IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                _isSearchActive ? Icons.close_rounded : Icons.search_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
