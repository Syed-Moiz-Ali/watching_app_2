import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/constants/colors.dart';
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
  minimal
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
    this.appBarStyle = AppBarStyle.standard,
    this.backgroundColor,
    this.gradientColors,
    this.bottom,
    this.appBarHeight = 70.0,
    this.automaticallyImplyLeading,
    this.isShowSearchbar = false,
    this.onSearch,
    this.onChanged,
    this.blurIntensity = 10.0,
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
    this.searchBarBorderRadius = 30.0,
    this.customSearchBar,
    this.scrollController,
    this.collapsibleTitle,
    this.titleFadeAnimation = true,
    this.brightness,
    this.shadowColor,
    this.statusBarTransparent = false,
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
  late Animation<double> _searchBarWidth;
  late Animation<double> _searchBarOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _rotation;
  bool _isSearchActive = false;

  // New variables for advanced features
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;
  bool _isScrolled = false;
  Color _dynamicColor = Colors.transparent;
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;
  final GlobalKey _appBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();

    // Search animation setup
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchBarWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _searchBarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Rotation animation setup
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Dynamic color animation setup
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.backgroundColor ?? AppColors.primaryColor,
    ).animate(_colorAnimationController);

    // Initialize scroll controller
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);

    // Set status bar style
    _updateStatusBarStyle();
  }

  void _updateStatusBarStyle() {
    if (widget.statusBarTransparent) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: widget.brightness ?? Brightness.dark,
      ));
    }
  }

  void _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.offset;
      _isScrolled = _scrollPosition > 0;

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
    _focusNode.dispose();
    _searchController.dispose();
    _colorAnimationController.dispose();

    // Only dispose scroll controller if we created it
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
      } else {
        _searchAnimationController.reverse();
        _rotationController.reverse();
        _focusNode.unfocus();
        _searchController.clear();
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

  Widget _buildStandardAppBar(BuildContext context, bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        boxShadow: widget.elevation > 0
            ? [
                BoxShadow(
                  color: (widget.shadowColor ?? Colors.black).withOpacity(0.05),
                  blurRadius: widget.elevation * 2,
                  offset: Offset(0, widget.elevation),
                ),
              ]
            : null,
        borderRadius: widget.borderRadius,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? Theme.of(context).dividerColor,
                width: 1.0,
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
                .withOpacity(0.25),
            borderRadius: widget.borderRadius,
            border: widget.showBorder
                ? Border.all(
                    color: widget.borderColor ?? Colors.white.withOpacity(0.2),
                    width: 1.0,
                  )
                : null,
            boxShadow: widget.elevation > 0
                ? [
                    BoxShadow(
                      color:
                          (widget.shadowColor ?? Colors.black).withOpacity(0.1),
                      blurRadius: widget.elevation * 2,
                      offset: Offset(0, widget.elevation),
                    ),
                  ]
                : null,
          ),
          child: _buildAppBarContent(context),
        ),
      ),
    );
  }

  Widget _buildGradientAppBar(BuildContext context, bool isDarkTheme) {
    final List<Color> colors = widget.gradientColors ??
        [
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor.withOpacity(0.7),
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: widget.borderRadius,
        boxShadow: widget.elevation > 0
            ? [
                BoxShadow(
                  color: (widget.shadowColor ?? Colors.black).withOpacity(0.1),
                  blurRadius: widget.elevation * 2,
                  offset: Offset(0, widget.elevation),
                ),
              ]
            : null,
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
            boxShadow: _isScrolled && widget.elevation > 0
                ? [
                    BoxShadow(
                      color:
                          (widget.shadowColor ?? Colors.black).withOpacity(0.1),
                      blurRadius: widget.elevation * 2,
                      offset: Offset(0, widget.elevation),
                    ),
                  ]
                : null,
            borderRadius: widget.borderRadius,
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
      child: _buildAppBarContent(context, forcedTransparency: true),
    );
  }

  Widget _buildCollapsibleAppBar(BuildContext context, bool isDarkTheme) {
    final double appBarHeight = math.max(
      widget.appBarHeight - (widget.shrinkOffset * 0.5),
      kToolbarHeight,
    );

    final double opacity =
        1.0 - (widget.shrinkOffset / (widget.expandedHeight ?? 200));
    final double scale =
        1.0 - (widget.shrinkOffset / (widget.expandedHeight ?? 400));

    return Container(
      height: appBarHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor?.withOpacity(
              widget.shrinkOffset > 0 ? 1.0 : 0.0,
            ) ??
            Theme.of(context).scaffoldBackgroundColor.withOpacity(
                  widget.shrinkOffset > 0 ? 1.0 : 0.0,
                ),
        boxShadow: widget.shrinkOffset > 0 && widget.elevation > 0
            ? [
                BoxShadow(
                  color: (widget.shadowColor ?? Colors.black).withOpacity(0.1),
                  blurRadius: widget.elevation * 2,
                  offset: Offset(0, widget.elevation),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (widget.parallaxEffect && widget.flexibleSpaceBackground != null)
            Positioned(
              top: -widget.shrinkOffset * 0.5,
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
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: widget.appBarStyle == AppBarStyle.glassmorphic
            ? widget.blurIntensity
            : 0,
        sigmaY: widget.appBarStyle == AppBarStyle.glassmorphic
            ? widget.blurIntensity
            : 0,
      ),
      child: AppBar(
        key: _appBarKey,
        forceMaterialTransparency:
            forcedTransparency || widget.appBarStyle == AppBarStyle.minimal,
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
            // Title
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
            // Search Bar
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

  Widget _buildTitle() {
    return Hero(
      tag: 'app_bar_title_${widget.title}',
      child: Material(
        color: Colors.transparent,
        child: TextWidget(
          text: widget.title,
          styleType: widget.styleType ?? TextStyleType.heading2,
          textAlign: widget.centerTitle ? TextAlign.center : TextAlign.start,
        ),
      ),
    );
  }

  Widget _buildSearchToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RotationTransition(
        turns: _rotation,
        child: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              _isSearchActive ? Icons.close_rounded : Icons.search_rounded,
              size: 24.sp,
              key: ValueKey<bool>(_isSearchActive),
            ),
          ),
          onPressed: _toggleSearch,
        ),
      ),
    );
  }
}
