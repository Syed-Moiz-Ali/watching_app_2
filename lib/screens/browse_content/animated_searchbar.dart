import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    required this.recentSearches,
    required this.onRecentSearchesUpdated,
    this.hintText = 'Search your content...',
    this.primaryColor = const Color(0xFF3D5AFE), // Modern indigo
    this.backgroundColor = const Color(0xFF1E1E2E), // Dark background
    this.textColor = Colors.white,
  });

  final Color backgroundColor;
  final String hintText;
  final VoidCallback onFilterTap;
  final Function(List<String>) onRecentSearchesUpdated;
  final Function(String) onSearch;
  final Color primaryColor;
  final List<String> recentSearches;
  final Color textColor;

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with TickerProviderStateMixin {
  late AnimationController _bounceAnimController;
  late Animation<double> _bounceAnimation;
  late AnimationController _focusAnimController;
  late Animation<double> _focusAnimation;
  bool _isSearchFocused = false;
  OverlayEntry? _overlayEntry;
  late AnimationController _recentSearchesAnimController;
  late Animation<double> _recentSearchesAnimation;
  // Animations
  late AnimationController _searchBarAnimController;

  late Animation<double> _searchBarAnimation;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _shimmerAnimController;
  late Animation<double> _shimmerAnimation;
  bool _showRecentSearches = false;

  @override
  void dispose() {
    _removeRecentSearchesOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchBarAnimController.dispose();
    _focusAnimController.dispose();
    _bounceAnimController.dispose();
    _shimmerAnimController.dispose();
    _recentSearchesAnimController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _searchFocusNode.addListener(_handleFocusChange);

    // Entry animation
    _searchBarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarAnimController,
      curve: Curves.easeOutQuint,
    );

    // Focus animation
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _focusAnimation = CurvedAnimation(
      parent: _focusAnimController,
      curve: Curves.easeOutCirc,
    );

    // Bounce animation
    _bounceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _bounceAnimation = CurvedAnimation(
      parent: _bounceAnimController,
      curve: Curves.elasticOut,
    );

    // Shimmer animation
    _shimmerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerAnimController,
      curve: Curves.easeInOutSine,
    );

    // Recent searches animation
    _recentSearchesAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _recentSearchesAnimation = CurvedAnimation(
      parent: _recentSearchesAnimController,
      curve: Curves.easeOutCubic,
    );

    // Start entry animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchBarAnimController.forward();
    });
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardVisibilityController.onChange.listen((bool visible) {
      if (kDebugMode) {
        print('Keyboard visibility update. Is visible: $visible');
      }
      if (visible) {
        _searchFocusNode.requestFocus(); // Set focus when keyboard appears
      } else {
        _searchFocusNode.unfocus(); // Remove focus when keyboard disappears
      }
    });
  }

  void _handleFocusChange() {
    log("Focus changed: ${_searchFocusNode.hasFocus}");
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
      if (_isSearchFocused) {
        _focusAnimController.forward();
        _bounceAnimController.forward(from: 0.0);
        if (widget.recentSearches.isNotEmpty) {
          _showRecentSearches = true;
          _recentSearchesAnimController.forward();
          _showRecentSearchesOverlay();
        }
      } else {
        _focusAnimController.reverse();
        if (_showRecentSearches) {
          _recentSearchesAnimController.reverse().then((_) {
            setState(() {
              _showRecentSearches = false;
              _removeRecentSearchesOverlay();
            });
          });
        }
      }
    });
  }

  void _showRecentSearchesOverlay() {
    _removeRecentSearchesOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _recentSearchesAnimation,
        builder: (context, child) {
          final Offset offset = renderBox.localToGlobal(Offset.zero);

          return Positioned(
            top: offset.dy + size.height + 8,
            left: offset.dx,
            width: size.width,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _recentSearchesAnimation.value)),
              child: Opacity(
                opacity: _recentSearchesAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: _buildRecentSearchesContainer(),
                ),
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeRecentSearchesOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;

    List<String> updatedSearches = List.from(widget.recentSearches);

    // Remove if already exists
    updatedSearches.remove(query);

    // Add to the beginning
    updatedSearches.insert(0, query);

    // Limit to 5 recent searches
    if (updatedSearches.length > 5) {
      updatedSearches = updatedSearches.sublist(0, 5);
    }

    widget.onRecentSearchesUpdated(updatedSearches);
  }

  Widget _buildSearchBarContainer() {
    // Calculate interpolated values based on focus state
    final double horizontalPadding =
        _isSearchFocused ? 12 : 16 + (4 * (1 - _focusAnimation.value));
    final double verticalPadding =
        _isSearchFocused ? 8 : 12 + (4 * (1 - _focusAnimation.value));
    final double borderRadius =
        _isSearchFocused ? 16 : 24 - (8 * _focusAnimation.value);
    final double elevation =
        _isSearchFocused ? 12 : 3 + (9 * _focusAnimation.value);

    // Shimmer effect colors
    final Color shimmerColor = _isSearchFocused
        ? HSLColor.fromColor(widget.primaryColor)
            .withLightness(0.6 + 0.2 * _shimmerAnimation.value.clamp(0.0, 1.0))
            .toColor()
        : widget.primaryColor.withOpacity(0.7);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.backgroundColor,
            HSLColor.fromColor(widget.backgroundColor)
                .withLightness(HSLColor.fromColor(widget.backgroundColor)
                        .lightness
                        .clamp(0.0, 1.0) +
                    0.05)
                .toColor(),
          ],
        ),
        border: Border.all(
          color: _isSearchFocused
              ? shimmerColor.withOpacity(0.8)
              : widget.backgroundColor.withOpacity(0.2),
          width: _isSearchFocused ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isSearchFocused
                ? shimmerColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.15),
            blurRadius: elevation * 2,
            spreadRadius: elevation / 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildSearchContent(borderRadius),
    );
  }

  Widget _buildSearchContent(double borderRadius) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildSearchIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                onEditingComplete: () {
                  widget.onSearch(_searchController.text);
                  _addToRecentSearches(_searchController.text);
                  _searchFocusNode.unfocus();
                },
                // onSubmitted: (value) {
                //   widget.onSearch(value);
                //   _addToRecentSearches(value);
                //   _searchFocusNode.unfocus();
                // },
                onChanged: (value) {
                  setState(() {});
                },
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: widget.textColor.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            _buildClearButton(),
            // _buildFilterButton(),
            // _buildDivider(),
            // _buildVoiceButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchIcon() {
    final double iconScale = 1.0 + (_bounceAnimation.value * 0.15);

    return Transform.scale(
      scale: iconScale,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.greyColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          // gradient: _isSearchFocused ? gradient : null,
          boxShadow: _isSearchFocused
              ? [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.search_rounded,
          color: AppColors.greyColor.withOpacity(0.8),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return AnimatedOpacity(
      opacity: _searchController.text.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        onPressed: () {
          _searchController.clear();
          // widget.onSearch('');
          setState(() {});
        },
        icon: const Icon(
          Icons.close_rounded,
          size: 20,
        ),
        style: IconButton.styleFrom(
          foregroundColor: widget.textColor.withOpacity(0.7),
          backgroundColor: widget.backgroundColor.withOpacity(0.2),
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
        ),
      ),
    );
  }

  Widget _buildRecentSearchesContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.primaryColor.withOpacity(0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: widget.backgroundColor.withOpacity(0.85),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        color: widget.textColor.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onRecentSearchesUpdated([]);
                        _removeRecentSearchesOverlay();
                        setState(() {
                          _showRecentSearches = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: widget.primaryColor,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.recentSearches
                    .map((search) => _buildRecentSearchItem(search)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return InkWell(
      onTap: () {
        _searchController.text = search;
        widget.onSearch(search);
        _searchFocusNode.unfocus();
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 18,
              color: widget.textColor.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                search,
                style: TextStyle(
                  color: widget.textColor.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                List<String> updatedSearches = List.from(widget.recentSearches);
                updatedSearches.remove(search);
                widget.onRecentSearchesUpdated(updatedSearches);

                if (updatedSearches.isEmpty) {
                  _removeRecentSearchesOverlay();
                  setState(() {
                    _showRecentSearches = false;
                  });
                }
              },
              icon: Icon(
                Icons.close_rounded,
                size: 16,
                color: widget.textColor.withOpacity(0.5),
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _searchBarAnimation,
        _focusAnimation,
        _bounceAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _searchBarAnimation.value)),
          child: Opacity(
            opacity: _searchBarAnimation.value,
            child: _buildSearchBarContainer(),
          ),
        );
      },
    );
  }
}
