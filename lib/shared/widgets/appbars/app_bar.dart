import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/constants/colors.dart';
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
  breathingSpace
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
    this.appBarStyle = AppBarStyle.ultraMinimal,
    this.backgroundColor,
    this.gradientColors,
    this.bottom,
    this.appBarHeight = 64.0, // Reduced for better proportions
    this.automaticallyImplyLeading,
    this.isShowSearchbar = false,
    this.onSearch,
    this.onChanged,
    this.blurIntensity = 8.0, // Reduced for subtlety
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
    this.searchBarBorderRadius = 24.0, // More refined
    this.customSearchBar,
    this.scrollController,
    this.collapsibleTitle,
    this.titleFadeAnimation = true,
    this.brightness,
    this.shadowColor,
    this.statusBarTransparent = true, // Default true for minimal
    this.minimalistSpacing = 20.0, // New parameter for consistent spacing
    this.breathingRoom = true, // New parameter for spacious feel
    this.perfectAlignment = true, // New parameter for pixel-perfect alignment
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

  // New minimalist design parameters
  final double minimalistSpacing;
  final bool breathingRoom;
  final bool perfectAlignment;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late TextEditingController _searchController;
  late AnimationController _searchAnimationController;
  late AnimationController _rotationController;
  late AnimationController _microInteractionController;
  late Animation<double> _searchBarWidth;
  late Animation<double> _searchBarOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _rotation;
  late Animation<double> _microScale;
  late Animation<double> _breathingAnimation;
  bool _isSearchActive = false;

  // Enhanced variables for minimalist design
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;
  bool _isScrolled = false;
  Color _dynamicColor = Colors.transparent;
  late AnimationController _colorAnimationController;
  late AnimationController _breathingController;
  late Animation<Color?> _colorAnimation;
  final GlobalKey _appBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();

    // Enhanced search animation with easing
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Faster for responsiveness
    );

    _searchBarWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeOutCubic, // Premium easing
      ),
    );

    _searchBarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Micro-interaction animation
    _microInteractionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _microScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _microInteractionController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Subtle rotation for search toggle
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _rotation = Tween<double>(begin: 0.0, end: 0.200).animate(
      // Reduced rotation
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Breathing animation for floating style
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.appBarStyle == AppBarStyle.breathingSpace) {
      _breathingController.repeat(reverse: true);
    }

    // Dynamic color animation with refined timing
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Snappier response
    );

    // Initialize scroll controller
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);

    // Defer theme-dependent operations until after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeThemeDependentAnimations();
      _updateStatusBarStyle();
    });
  }

  void _initializeThemeDependentAnimations() {
    // Now it's safe to access Theme.of(context)
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.backgroundColor ?? _getMinimalistBackgroundColor(),
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Color _getMinimalistBackgroundColor() {
    // Add null check for context
    if (!mounted) return Colors.transparent;

    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A0A0A) // Pure black for OLED
        : const Color(0xFFFAFAFA); // Off-white for comfort
  }

  void _updateStatusBarStyle() {
    // Add null check for context
    if (!mounted) return;

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: widget.brightness ??
    //       (Theme.of(context).brightness == Brightness.dark
    //           ? Brightness.light
    //           : Brightness.dark),
    //   systemNavigationBarColor: Colors.transparent,
    //   systemNavigationBarIconBrightness: widget.brightness ??
    //       (Theme.of(context).brightness == Brightness.dark
    //           ? Brightness.light
    //           : Brightness.dark),
    // ));
  }

  void _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.offset;
      _isScrolled = _scrollPosition > 20; // Increased threshold for better UX

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
    _searchAnimationController.dispose();
    _rotationController.dispose();
    _microInteractionController.dispose();
    _breathingController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    _colorAnimationController.dispose();

    if (widget.scrollController == null) {
      _scrollController.removeListener(_scrollListener);
      _scrollController.dispose();
    }

    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _searchAnimationController.forward();
        _rotationController.forward();
        _focusNode.requestFocus();
        HapticFeedback.lightImpact(); // Tactile feedback
      } else {
        _searchAnimationController.reverse();
        _rotationController.reverse();
        _focusNode.unfocus();
        _searchController.clear();
        HapticFeedback.selectionClick();
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
      case AppBarStyle.ultraMinimal:
        return _buildUltraMinimalAppBar(context, isDarkTheme);
      case AppBarStyle.floating:
        return _buildFloatingAppBar(context, isDarkTheme);
      case AppBarStyle.breathingSpace:
        return _buildBreathingSpaceAppBar(context, isDarkTheme);
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

  Widget _buildUltraMinimalAppBar(BuildContext context, bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 0.5, // Hairline border
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: widget.appBarHeight,
          padding: EdgeInsets.symmetric(
            horizontal: widget.minimalistSpacing,
            vertical: widget.breathingRoom ? 8.0 : 4.0,
          ),
          child: _buildUltraMinimalContent(context),
        ),
      ),
    );
  }

  Widget _buildFloatingAppBar(BuildContext context, bool isDarkTheme) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: widget.minimalistSpacing,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: widget.appBarHeight - 16,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildMinimalistContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingSpaceAppBar(BuildContext context, bool isDarkTheme) {
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
                  color: Theme.of(context).dividerColor.withOpacity(0.05),
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              child: Container(
                height: widget.appBarHeight + (widget.breathingRoom ? 20 : 0),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.minimalistSpacing + 4,
                  vertical: widget.breathingRoom ? 16.0 : 8.0,
                ),
                child: _buildMinimalistContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStandardAppBar(BuildContext context, bool isDarkTheme) {
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
                .withOpacity(0.15), // Reduced opacity for subtlety
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
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          height: widget.appBarHeight,
          padding: EdgeInsets.symmetric(horizontal: widget.minimalistSpacing),
          child: _buildMinimalistContent(context),
        ),
      ),
    );
  }

  Widget _buildCollapsibleAppBar(BuildContext context, bool isDarkTheme) {
    final double appBarHeight = math.max(
      widget.appBarHeight - (widget.shrinkOffset * 0.3), // Reduced shrink rate
      kToolbarHeight,
    );

    final double opacity =
        (1.0 - (widget.shrinkOffset / (widget.expandedHeight ?? 200)))
            .clamp(0.0, 1.0);
    final double scale =
        (1.0 - (widget.shrinkOffset / (widget.expandedHeight ?? 400)))
            .clamp(0.8, 1.0); // Minimum scale

    return Container(
      height: appBarHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor?.withOpacity(
              widget.shrinkOffset > 50 ? 0.95 : 0.0,
            ) ??
            _getMinimalistBackgroundColor().withOpacity(
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

  Widget _buildUltraMinimalContent(BuildContext context) {
    return Row(
      children: [
        if (widget.automaticallyImplyLeading == true && !_isSearchActive)
          _buildMinimalistBackButton(),
        if (!_isSearchActive) ...[
          if (widget.automaticallyImplyLeading != true)
            SizedBox(width: widget.perfectAlignment ? 4.0 : 0),
          Expanded(child: _buildMinimalistTitle()),
        ],
        if (_isSearchActive)
          Expanded(
            child: FadeTransition(
              opacity: _searchBarOpacity,
              child: ScaleTransition(
                scale: _searchBarWidth,
                child: _buildMinimalistSearchBar(),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isShowSearchbar) _buildMinimalistSearchToggle(),
            ...widget.actions.map((action) => Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: action,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimalistContent(BuildContext context) {
    return Row(
      children: [
        if (widget.automaticallyImplyLeading == true && !_isSearchActive)
          _buildMinimalistBackButton(),
        if (!_isSearchActive) ...[
          if (widget.automaticallyImplyLeading != true)
            SizedBox(width: widget.perfectAlignment ? 8.0 : 0),
          Expanded(child: _buildMinimalistTitle()),
        ],
        if (_isSearchActive)
          Expanded(
            child: FadeTransition(
              opacity: _searchBarOpacity,
              child: ScaleTransition(
                scale: _searchBarWidth,
                child: _buildMinimalistSearchBar(),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isShowSearchbar) _buildMinimalistSearchToggle(),
            ...widget.actions.map((action) => Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: action,
                )),
          ],
        ),
      ],
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

  Widget _buildMinimalistBackButton() {
    return GestureDetector(
      onTapDown: (_) => _microInteractionController.forward(),
      onTapUp: (_) => _microInteractionController.reverse(),
      onTapCancel: () => _microInteractionController.reverse(),
      onTap: widget.onBackButtonPressed ?? () => Navigator.of(context).pop(),
      child: ScaleTransition(
        scale: _microScale,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
          ),
        ),
      ),
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

  Widget _buildMinimalistTitle() {
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
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

  Widget _buildTitle() {
    return TextWidget(
      text: widget.title,
      styleType: widget.styleType ?? TextStyleType.subheading,
      fontWeight: FontWeight.w700,
      textAlign: widget.centerTitle ? TextAlign.center : TextAlign.start,
    );
  }

  Widget _buildMinimalistSearchBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(widget.searchBarBorderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
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
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalistSearchToggle() {
    return GestureDetector(
      onTapDown: (_) => _microInteractionController.forward(),
      onTapUp: (_) => _microInteractionController.reverse(),
      onTapCancel: () => _microInteractionController.reverse(),
      onTap: _toggleSearch,
      child: AnimatedBuilder(
        animation: Listenable.merge([_microScale, _rotation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _microScale.value,
            child: Transform.rotate(
              angle: _rotation.value * .1,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isSearchActive
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isSearchActive ? Icons.close_rounded : Icons.search_rounded,
                  size: 20,
                  color: _isSearchActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color?.withOpacity(0.8),
                ),
              ),
            ),
          );
        },
      ),
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
