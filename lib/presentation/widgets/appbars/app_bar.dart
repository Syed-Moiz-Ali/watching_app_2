import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import '../../../core/common/utils/common_widgets.dart';
import '../../../core/enums/enums.dart';
import '../../provider/theme_provider.dart';
import '../misc/padding.dart';
import '../inputs/search_bar.dart';
import '../misc/text_widget.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.prefixIcon,
    this.elevation = 0.0,
    this.centerTitle = false,
    this.styleType,
    this.backgroundColor,
    this.bottom,
    this.appBarHeight = 70.0,
    this.automaticallyImplyLeading,
    this.isShowSearchbar = false,
    this.onSearch,
  });

  final List<Widget> actions;
  final bool? automaticallyImplyLeading;
  final bool centerTitle;
  final double elevation;
  final Widget? prefixIcon;
  final TextStyleType? styleType;
  final double appBarHeight;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool isShowSearchbar;
  final String title;
  final Function(String)? onSearch;

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
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _rotationController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
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
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
            boxShadow: widget.elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: widget.elevation * 2,
                      offset: Offset(0, widget.elevation),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                scrolledUnderElevation: 0,
                // backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                toolbarHeight: widget.appBarHeight,
                title: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Title
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SizedBox(
                        height: widget.appBarHeight,
                        child: Row(
                          mainAxisAlignment: widget.centerTitle
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            if (widget.automaticallyImplyLeading == true)
                              _buildBackButton(),
                            Expanded(
                              child: _buildTitle(),
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
                          child: PremiumSearchBar(
                              isShowSearchBar: widget.isShowSearchbar,
                              onSearch: (query) {
                                if (widget.onSearch != null) {
                                  widget.onSearch!(query);
                                  _toggleSearch();
                                }
                              }),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomPadding(
        rightFactor: .03,
        child: Hero(
          tag: 'back_button',
          child: Material(
            color: Colors.transparent,
            child: CommonWidgets.navigationBackIcon(),
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
          overflow: TextOverflow.ellipsis,
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
